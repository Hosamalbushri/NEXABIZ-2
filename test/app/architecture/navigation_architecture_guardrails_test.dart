import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/core/capabilities/capability_metadata.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability_registry.dart';
import 'package:nexabiz/core/navigation/nexabiz_navigation_contribution.dart';
import 'package:nexabiz/core/navigation/nexabiz_navigation_registry.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_definition.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_id.dart';
import 'package:nexabiz/app/router/nexabiz_router_adapter.dart';
import 'package:nexabiz/app/router/nexabiz_flutter_route_definition.dart';

class _MockCapability implements NexaBizCapability {
  @override
  final String capabilityId;
  @override
  final NexaBizNavigationContribution? navigationContribution;

  _MockCapability(this.capabilityId, this.navigationContribution);

  @override
  CapabilityMetadata get metadata =>
      CapabilityMetadata(nameKey: capabilityId, iconIdentifier: 'app');

  @override
  List<String> get dependsOn => const [];
}

class _MockNavContribution implements NexaBizNavigationContribution {
  @override
  final NexaBizRouteId rootRouteId;
  @override
  final List<NexaBizRouteDefinition> routes;

  _MockNavContribution(this.rootRouteId, this.routes);
}

void main() {
  group('Navigation Architecture Guardrails (NAV-01..06)', () {
    test(
      'NAV-01 & NAV-05: Navigation registry locks metadata and prevents post-lock mutation',
      () {
        final capRegistry = NexaBizCapabilityRegistry();
        capRegistry.register(
          _MockCapability(
            'dashboard',
            _MockNavContribution(
              const NexaBizRouteId(
                namespace: 'dashboard',
                routeName: 'dashboard',
              ),
              [
                NexaBizFlutterRouteDefinition(
                  routeId: NexaBizRouteId(
                    namespace: 'dashboard',
                    routeName: 'dashboard',
                  ),
                  path: '/dashboard',
                  pageBuilder: (context) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
        capRegistry.validateAndLock();

        final navRegistry = NexaBizNavigationRegistry();
        expect(navRegistry.isLocked, isFalse);

        navRegistry.collectAndLock(capRegistry);
        expect(navRegistry.isLocked, isTrue);

        expect(
          () => navRegistry.collectAndLock(capRegistry),
          throwsStateError,
          reason:
              'Navigation registry must throw StateError if collected after locking.',
        );
      },
    );

    test('NAV-03: Route identities must be unique across capabilities', () {
      final capRegistry = NexaBizCapabilityRegistry();
      capRegistry.register(
        _MockCapability(
          'cap1',
          _MockNavContribution(
            const NexaBizRouteId(namespace: 'cap1', routeName: 'dup_route'),
            [
              NexaBizFlutterRouteDefinition(
                routeId: NexaBizRouteId(
                  namespace: 'cap1',
                  routeName: 'dup_route',
                ),
                path: '/path1',
                pageBuilder: (context) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
      capRegistry.register(
        _MockCapability(
          'cap2',
          _MockNavContribution(
            const NexaBizRouteId(namespace: 'cap1', routeName: 'dup_route'),
            [
              NexaBizFlutterRouteDefinition(
                routeId: NexaBizRouteId(
                  namespace: 'cap1',
                  routeName: 'dup_route',
                ),
                path: '/path2',
                pageBuilder: (context) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
      capRegistry.validateAndLock();

      final navRegistry = NexaBizNavigationRegistry();
      expect(
        () => navRegistry.collectAndLock(capRegistry),
        throwsStateError,
        reason: 'Duplicate route IDs must trigger StateError.',
      );
    });

    test('NAV-04: Effective URI paths must be unique across capabilities', () {
      final capRegistry = NexaBizCapabilityRegistry();
      capRegistry.register(
        _MockCapability(
          'cap1',
          _MockNavContribution(
            const NexaBizRouteId(namespace: 'cap1', routeName: 'route1'),
            [
              NexaBizFlutterRouteDefinition(
                routeId: NexaBizRouteId(namespace: 'cap1', routeName: 'route1'),
                path: '/conflict_path',
                pageBuilder: (context) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
      capRegistry.register(
        _MockCapability(
          'cap2',
          _MockNavContribution(
            const NexaBizRouteId(namespace: 'cap2', routeName: 'route2'),
            [
              NexaBizFlutterRouteDefinition(
                routeId: NexaBizRouteId(namespace: 'cap2', routeName: 'route2'),
                path: '/conflict_path',
                pageBuilder: (context) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
      capRegistry.validateAndLock();

      final navRegistry = NexaBizNavigationRegistry();
      expect(
        () => navRegistry.collectAndLock(capRegistry),
        throwsStateError,
        reason: 'Conflicting transport paths must trigger StateError.',
      );
    });

    test(
      'NAV-06: Primary platform branches map to canonical router adapter configuration',
      () {
        final capRegistry = NexaBizCapabilityRegistry();
        final primaryPaths = [
          '/dashboard',
          '/services',
          '/reports',
          '/settings',
        ];

        final routes = [
          for (final p in primaryPaths)
            NexaBizFlutterRouteDefinition(
              routeId: NexaBizRouteId(
                namespace: 'platform',
                routeName: p.replaceAll('/', ''),
              ),
              path: p,
              pageBuilder: (context) => const SizedBox.shrink(),
            ),
        ];

        capRegistry.register(
          _MockCapability(
            'platform',
            _MockNavContribution(
              const NexaBizRouteId(
                namespace: 'platform',
                routeName: 'dashboard',
              ),
              routes,
            ),
          ),
        );
        capRegistry.validateAndLock();

        final navRegistry = NexaBizNavigationRegistry();
        navRegistry.collectAndLock(capRegistry);

        final adapter = NexaBizGoRouterAdapter(navRegistry);
        final router = adapter.createRouter();
        expect(router, isNotNull);
        router.dispose();
      },
    );

    test('NAV-07: Restrict system exit calls (no raw exit(0), SystemNavigator.pop only in AppExitPopScope)', () async {
      final libDir = Directory('/home/hosam/StudioProjects/nexabiz/lib');
      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        expect(
          content.contains('exit(0)') || content.contains('exit(1)'),
          isFalse,
          reason: 'Raw dart:io exit() calls are forbidden in application code: ${file.path}',
        );

        if (content.contains('SystemNavigator.pop')) {
          expect(
            file.path.endsWith('lib/app/shell/app_exit_scope.dart'),
            isTrue,
            reason: 'SystemNavigator.pop() is strictly restricted to lib/app/shell/app_exit_scope.dart: ${file.path}',
          );
        }
      }
    });
  });
}
