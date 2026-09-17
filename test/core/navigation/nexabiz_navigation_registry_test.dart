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

  _TestNavContribution({
    required this.rootRouteId,
    required this.routes,
  });
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

  _TestNavCapability({
    required this.capabilityId,
    this.navigationContribution,
  })  : dependsOn = const [],
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
        capabilityId: 'testCap',
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

    test('rejects duplicate route IDs across capabilities', () {
      const sharedRouteId = NexaBizRouteId(namespace: 'common', routeName: 'page');

      final cap1 = _TestNavCapability(
        capabilityId: 'cap1',
        navigationContribution: _TestNavContribution(
          rootRouteId: sharedRouteId,
          routes: [NexaBizRouteDefinition(routeId: sharedRouteId, path: '/page1')],
        ),
      );

      final cap2 = _TestNavCapability(
        capabilityId: 'cap2',
        navigationContribution: _TestNavContribution(
          rootRouteId: sharedRouteId,
          routes: [NexaBizRouteDefinition(routeId: sharedRouteId, path: '/page2')],
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
          routes: [NexaBizRouteDefinition(routeId: routeId1, path: '/duplicate-path')],
        ),
      );

      final cap2 = _TestNavCapability(
        capabilityId: 'cap2',
        navigationContribution: _TestNavContribution(
          rootRouteId: routeId2,
          routes: [NexaBizRouteDefinition(routeId: routeId2, path: '/duplicate-path')],
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
        capabilityId: 'badCap',
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
        () => navRegistry.getRoute(const NexaBizRouteId(namespace: 'a', routeName: 'b')),
        throwsStateError,
      );
    });
  });
}
