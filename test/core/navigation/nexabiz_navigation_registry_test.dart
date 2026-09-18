import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/core/capabilities/capability_metadata.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability.dart';
import 'package:nexabiz/core/capabilities/nexabiz_capability_registry.dart';
import 'package:nexabiz/core/navigation/nexabiz_navigation_contribution.dart';
import 'package:nexabiz/core/navigation/nexabiz_navigation_registry.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_definition.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_id.dart';

class _TestNavContribution implements NexaBizNavigationContribution {
  @override
  final NexaBizRouteId rootRouteId;
  @override
  final List<NexaBizRouteDefinition> routes;

  _TestNavContribution({required this.rootRouteId, required this.routes});
}

class _TestNavCapability implements NexaBizCapability {
  @override
  final String capabilityId;
  @override
  final CapabilityMetadata metadata;
  @override
  final List<String> dependsOn;
  @override
  final NexaBizNavigationContribution? navigationContribution;

  _TestNavCapability({required this.capabilityId, this.navigationContribution})
    : dependsOn = const [],
      metadata = CapabilityMetadata(
        nameKey: 'test.$capabilityId',
        iconIdentifier: 'test',
      );
}

void main() {
  group('NexaBizNavigationRegistry', () {
    late NexaBizCapabilityRegistry capRegistry;
    late NexaBizNavigationRegistry navRegistry;

    setUp(() {
      capRegistry = NexaBizCapabilityRegistry();
      navRegistry = NexaBizNavigationRegistry();
    });

    test('successfully collects valid capability navigation contributions', () {
      const rootId = NexaBizRouteId(namespace: 'test', routeName: 'root');
      final routeDef = NexaBizRouteDefinition(routeId: rootId, path: '/test');

      final cap = _TestNavCapability(
        capabilityId: 'test',
        navigationContribution: _TestNavContribution(
          rootRouteId: rootId,
          routes: [routeDef],
        ),
      );

      capRegistry.register(cap);
      capRegistry.validateAndLock();

      navRegistry.collectAndLock(capRegistry);
      expect(navRegistry.isLocked, isTrue);
      expect(navRegistry.routes.length, equals(1));
      expect(navRegistry.getRoute(rootId).path, equals('/test'));
      expect(navRegistry.getRouteByPath('/test').routeId, equals(rootId));
    });

    test('rejects un-locked capability registry', () {
      expect(() => navRegistry.collectAndLock(capRegistry), throwsStateError);
    });

    for (final entry in <String, String>{
      'empty': '',
      'whitespace': ' \t',
      'relative': 'test',
      'protocol-relative': '//test',
      'duplicate separator': '/test//page',
      'backslash': r'/test\page',
      'dot segment': '/test/./page',
      'parent segment': '/test/../page',
      'query': '/test?value=1',
      'fragment': '/test#section',
      'trailing slash': '/test/',
      'embedded whitespace': '/test page',
    }.entries) {
      test('rejects ${entry.key} path without normalization', () {
        const rootId = NexaBizRouteId(namespace: 'test', routeName: 'root');
        capRegistry.register(
          _TestNavCapability(
            capabilityId: 'test',
            navigationContribution: _TestNavContribution(
              rootRouteId: rootId,
              routes: [
                NexaBizRouteDefinition(routeId: rootId, path: entry.value),
              ],
            ),
          ),
        );
        capRegistry.validateAndLock();
        expect(
          () => navRegistry.collectAndLock(capRegistry),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('noncanonical transport path'),
            ),
          ),
        );
        expect(navRegistry.isLocked, isFalse);
        expect(() => navRegistry.getRouteByPath(entry.value), throwsStateError);
      });
    }

    test('accepts the canonical slash root path', () {
      const rootId = NexaBizRouteId(namespace: 'test', routeName: 'root');
      capRegistry.register(
        _TestNavCapability(
          capabilityId: 'test',
          navigationContribution: _TestNavContribution(
            rootRouteId: rootId,
            routes: [const NexaBizRouteDefinition(routeId: rootId, path: '/')],
          ),
        ),
      );
      capRegistry.validateAndLock();
      navRegistry.collectAndLock(capRegistry);
      expect(navRegistry.getRoute(rootId).path, '/');
    });

    test('rejects path aliases under the current case-insensitive router', () {
      const rootId = NexaBizRouteId(namespace: 'test', routeName: 'root');
      capRegistry.register(
        _TestNavCapability(
          capabilityId: 'test',
          navigationContribution: _TestNavContribution(
            rootRouteId: rootId,
            routes: [
              const NexaBizRouteDefinition(routeId: rootId, path: '/test'),
              const NexaBizRouteDefinition(
                routeId: NexaBizRouteId(namespace: 'test', routeName: 'other'),
                path: '/TEST',
              ),
            ],
          ),
        ),
      );
      capRegistry.validateAndLock();
      expect(
        () => navRegistry.collectAndLock(capRegistry),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Conflicting transport path'),
          ),
        ),
      );
      expect(navRegistry.isLocked, isFalse);
    });

    test('rejects noncanonical declared root route metadata', () {
      capRegistry.register(
        _TestNavCapability(
          capabilityId: 'test',
          navigationContribution: _TestNavContribution(
            rootRouteId: const NexaBizRouteId(
              namespace: 'test',
              routeName: 'root.other',
            ),
            routes: [
              const NexaBizRouteDefinition(
                routeId: NexaBizRouteId(namespace: 'test', routeName: 'root'),
                path: '/test',
              ),
            ],
          ),
        ),
      );
      capRegistry.validateAndLock();
      expect(
        () => navRegistry.collectAndLock(capRegistry),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('canonical lower snake case segments'),
          ),
        ),
      );
      expect(navRegistry.isLocked, isFalse);
    });

    for (final segment in [
      '',
      ' ',
      ' padded',
      'padded ',
      'CamelCase',
      'dot.name',
      'dash-name',
      '1start',
    ]) {
      for (final invalidNamespace in [true, false]) {
        test(
          'rejects noncanonical ${invalidNamespace ? 'namespace' : 'route name'} ${segment.codeUnits}',
          () {
            const rootId = NexaBizRouteId(namespace: 'test', routeName: 'root');
            final invalidId = NexaBizRouteId(
              namespace: invalidNamespace ? segment : 'test',
              routeName: invalidNamespace ? 'page' : segment,
            );
            capRegistry.register(
              _TestNavCapability(
                capabilityId: 'test',
                navigationContribution: _TestNavContribution(
                  rootRouteId: rootId,
                  routes: [
                    const NexaBizRouteDefinition(
                      routeId: rootId,
                      path: '/test',
                    ),
                    NexaBizRouteDefinition(routeId: invalidId, path: '/page'),
                  ],
                ),
              ),
            );
            capRegistry.validateAndLock();
            expect(
              () => navRegistry.collectAndLock(capRegistry),
              throwsA(
                isA<StateError>().having(
                  (error) => error.message,
                  'message',
                  contains('canonical lower snake case segments'),
                ),
              ),
            );
            expect(navRegistry.isLocked, isFalse);
          },
        );
      }
    }

    test('rejects a namespace not owned by its contributing capability', () {
      const rootId = NexaBizRouteId(namespace: 'test', routeName: 'root');
      capRegistry.register(
        _TestNavCapability(
          capabilityId: 'test',
          navigationContribution: _TestNavContribution(
            rootRouteId: rootId,
            routes: [
              const NexaBizRouteDefinition(routeId: rootId, path: '/test'),
              const NexaBizRouteDefinition(
                routeId: NexaBizRouteId(namespace: 'other', routeName: 'page'),
                path: '/page',
              ),
            ],
          ),
        ),
      );
      capRegistry.validateAndLock();
      expect(
        () => navRegistry.collectAndLock(capRegistry),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('namespace must match owning capability'),
          ),
        ),
      );
      expect(navRegistry.isLocked, isFalse);
    });

    test('failed collection leaves no indexes and can be retried', () {
      const rootId = NexaBizRouteId(namespace: 'test', routeName: 'root');
      final validRoute = NexaBizRouteDefinition(routeId: rootId, path: '/test');
      final routes = [validRoute, validRoute];
      capRegistry.register(
        _TestNavCapability(
          capabilityId: 'test',
          navigationContribution: _TestNavContribution(
            rootRouteId: rootId,
            routes: routes,
          ),
        ),
      );
      capRegistry.validateAndLock();

      expect(() => navRegistry.collectAndLock(capRegistry), throwsStateError);
      expect(navRegistry.isLocked, isFalse);
      expect(() => navRegistry.getRoute(rootId), throwsStateError);
      routes.removeLast();
      navRegistry.collectAndLock(capRegistry);
      routes.clear();
      expect(navRegistry.routes, [validRoute]);
      expect(navRegistry.getRoute(rootId), same(validRoute));
      expect(navRegistry.getRouteByPath('/test'), same(validRoute));
      expect(() => navRegistry.routes.clear(), throwsUnsupportedError);
      expect(() => navRegistry.collectAndLock(capRegistry), throwsStateError);
    });

    test('missing root validation leaves the registry retryable', () {
      const rootId = NexaBizRouteId(namespace: 'test', routeName: 'root');
      const otherId = NexaBizRouteId(namespace: 'test', routeName: 'other');
      final routes = [NexaBizRouteDefinition(routeId: otherId, path: '/other')];
      capRegistry.register(
        _TestNavCapability(
          capabilityId: 'test',
          navigationContribution: _TestNavContribution(
            rootRouteId: rootId,
            routes: routes,
          ),
        ),
      );
      capRegistry.validateAndLock();
      expect(() => navRegistry.collectAndLock(capRegistry), throwsStateError);
      routes.add(NexaBizRouteDefinition(routeId: rootId, path: '/test'));
      navRegistry.collectAndLock(capRegistry);
      expect(navRegistry.routes.length, 2);
    });

    test('rejects empty contributions and invalid relative paths', () {
      const rootId = NexaBizRouteId(namespace: 'test', routeName: 'root');
      for (final routes in <List<NexaBizRouteDefinition>>[
        [],
        [NexaBizRouteDefinition(routeId: rootId, path: 'relative')],
        [NexaBizRouteDefinition(routeId: rootId, path: ' ')],
      ]) {
        final capabilities = NexaBizCapabilityRegistry();
        capabilities.register(
          _TestNavCapability(
            capabilityId: 'test',
            navigationContribution: _TestNavContribution(
              rootRouteId: rootId,
              routes: routes,
            ),
          ),
        );
        capabilities.validateAndLock();
        final navigation = NexaBizNavigationRegistry();
        expect(() => navigation.collectAndLock(capabilities), throwsStateError);
        expect(navigation.isLocked, isFalse);
      }
    });

    test('rejects duplicate route IDs across capabilities', () {
      const sharedRouteId = NexaBizRouteId(
        namespace: 'cap1',
        routeName: 'page',
      );

      final cap1 = _TestNavCapability(
        capabilityId: 'cap1',
        navigationContribution: _TestNavContribution(
          rootRouteId: sharedRouteId,
          routes: [
            NexaBizRouteDefinition(routeId: sharedRouteId, path: '/page1'),
          ],
        ),
      );

      final cap2 = _TestNavCapability(
        capabilityId: 'cap2',
        navigationContribution: _TestNavContribution(
          rootRouteId: sharedRouteId,
          routes: [
            NexaBizRouteDefinition(routeId: sharedRouteId, path: '/page2'),
          ],
        ),
      );

      capRegistry.register(cap1);
      capRegistry.register(cap2);
      capRegistry.validateAndLock();

      expect(() => navRegistry.collectAndLock(capRegistry), throwsStateError);
    });

    test('rejects conflicting paths across route definitions', () {
      const routeId1 = NexaBizRouteId(namespace: 'cap1', routeName: 'root');
      const routeId2 = NexaBizRouteId(namespace: 'cap2', routeName: 'root');

      final cap1 = _TestNavCapability(
        capabilityId: 'cap1',
        navigationContribution: _TestNavContribution(
          rootRouteId: routeId1,
          routes: [
            NexaBizRouteDefinition(routeId: routeId1, path: '/duplicate-path'),
          ],
        ),
      );

      final cap2 = _TestNavCapability(
        capabilityId: 'cap2',
        navigationContribution: _TestNavContribution(
          rootRouteId: routeId2,
          routes: [
            NexaBizRouteDefinition(routeId: routeId2, path: '/duplicate-path'),
          ],
        ),
      );

      capRegistry.register(cap1);
      capRegistry.register(cap2);
      capRegistry.validateAndLock();

      expect(() => navRegistry.collectAndLock(capRegistry), throwsStateError);
    });

    test('rejects declared rootRouteId when missing from routes list', () {
      const rootId = NexaBizRouteId(namespace: 'missing', routeName: 'root');
      const otherId = NexaBizRouteId(namespace: 'missing', routeName: 'other');

      final cap = _TestNavCapability(
        capabilityId: 'missing',
        navigationContribution: _TestNavContribution(
          rootRouteId: rootId,
          routes: [NexaBizRouteDefinition(routeId: otherId, path: '/other')],
        ),
      );

      capRegistry.register(cap);
      capRegistry.validateAndLock();

      expect(() => navRegistry.collectAndLock(capRegistry), throwsStateError);
    });

    test('prevents reading before locking', () {
      expect(() => navRegistry.routes, throwsStateError);
      expect(
        () => navRegistry.getRoute(
          const NexaBizRouteId(namespace: 'a', routeName: 'b'),
        ),
        throwsStateError,
      );
      expect(() => navRegistry.getRouteByPath('/test'), throwsStateError);
    });
  });
}
