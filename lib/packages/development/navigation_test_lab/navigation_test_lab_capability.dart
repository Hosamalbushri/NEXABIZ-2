import '../../../core/capabilities/capability_metadata.dart';
import '../../../core/capabilities/nexabiz_capability.dart';
import '../../../core/navigation/nexabiz_navigation_contribution.dart';
import '../../../core/navigation/nexabiz_route_definition.dart';
import '../../../core/navigation/nexabiz_route_id.dart';
import '../../../app/router/nexabiz_flutter_route_definition.dart';
import 'presentation/navigation_test_destructive_screen.dart';
import 'presentation/navigation_test_lab_dashboard.dart';
import 'presentation/navigation_test_node_screen.dart';
import 'presentation/navigation_test_param_screen.dart';

/// Capability introducing the development-only Navigation Test Lab.
/// Contributes deep branching routes under the isolated `/dev/navigation/...` namespace.
class NavigationTestLabCapability implements NexaBizCapability {
  @override
  String get capabilityId => 'navigation_test_lab';

  @override
  CapabilityMetadata get metadata => const CapabilityMetadata(
        nameKey: 'Navigation Test Lab',
        iconIdentifier: 'compass',
      );

  @override
  List<String> get dependsOn => const [];

  @override
  NexaBizNavigationContribution? get navigationContribution =>
      _NavigationTestLabContribution();
}

class _NavigationTestLabContribution implements NexaBizNavigationContribution {
  @override
  NexaBizRouteId get rootRouteId => const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'navigation_lab_root',
      );

  @override
  List<NexaBizRouteDefinition> get routes => [
        // Root Dashboard
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(
            namespace: 'navigation_test_lab',
            routeName: 'navigation_lab_root',
          ),
          path: '/dev/navigation',
          pageBuilder: (context) => const NavigationTestLabDashboard(),
        ),

        // Branch A Routes
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(namespace: 'navigation_test_lab', routeName: 'node_a'),
          path: '/dev/navigation/a',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Branch A Root',
            routePath: '/dev/navigation/a',
            parentPath: '/dev/navigation',
            depth: 1,
            branch: 'A',
            children: [
              TestNodeChild('Node A1', '/dev/navigation/a/a1'),
              TestNodeChild('Node A2', '/dev/navigation/a/a2'),
            ],
          ),
        ),
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(namespace: 'navigation_test_lab', routeName: 'node_a1'),
          path: '/dev/navigation/a/a1',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Node A1',
            routePath: '/dev/navigation/a/a1',
            parentPath: '/dev/navigation/a',
            depth: 2,
            branch: 'A',
            children: [
              TestNodeChild('Node A1.1', '/dev/navigation/a/a1/a1-1'),
              TestNodeChild('Node A1.2 (Sibling)', '/dev/navigation/a/a1/a1-2'),
            ],
          ),
        ),
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(
            namespace: 'navigation_test_lab',
            routeName: 'node_a1_1',
          ),
          path: '/dev/navigation/a/a1/a1-1',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Node A1.1',
            routePath: '/dev/navigation/a/a1/a1-1',
            parentPath: '/dev/navigation/a/a1',
            depth: 3,
            branch: 'A',
            children: [
              TestNodeChild('Node A1.1.1 (Deepest)', '/dev/navigation/a/a1/a1-1/a1-1-1'),
            ],
          ),
        ),
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(
            namespace: 'navigation_test_lab',
            routeName: 'node_a1_1_1',
          ),
          path: '/dev/navigation/a/a1/a1-1/a1-1-1',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Node A1.1.1',
            routePath: '/dev/navigation/a/a1/a1-1/a1-1-1',
            parentPath: '/dev/navigation/a/a1/a1-1',
            depth: 4,
            branch: 'A',
            children: [],
          ),
        ),
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(
            namespace: 'navigation_test_lab',
            routeName: 'node_a1_2',
          ),
          path: '/dev/navigation/a/a1/a1-2',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Node A1.2',
            routePath: '/dev/navigation/a/a1/a1-2',
            parentPath: '/dev/navigation/a/a1',
            depth: 3,
            branch: 'A',
            children: [],
          ),
        ),
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(namespace: 'navigation_test_lab', routeName: 'node_a2'),
          path: '/dev/navigation/a/a2',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Node A2',
            routePath: '/dev/navigation/a/a2',
            parentPath: '/dev/navigation/a',
            depth: 2,
            branch: 'A',
            children: [
              TestNodeChild('Node A2.1', '/dev/navigation/a/a2/a2-1'),
            ],
          ),
        ),
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(
            namespace: 'navigation_test_lab',
            routeName: 'node_a2_1',
          ),
          path: '/dev/navigation/a/a2/a2-1',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Node A2.1',
            routePath: '/dev/navigation/a/a2/a2-1',
            parentPath: '/dev/navigation/a/a2',
            depth: 3,
            branch: 'A',
            children: [],
          ),
        ),

        // Branch B Routes
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(namespace: 'navigation_test_lab', routeName: 'node_b'),
          path: '/dev/navigation/b',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Branch B Root',
            routePath: '/dev/navigation/b',
            parentPath: '/dev/navigation',
            depth: 1,
            branch: 'B',
            children: [
              TestNodeChild('Node B1', '/dev/navigation/b/b1'),
              TestNodeChild('Node B2', '/dev/navigation/b/b2'),
            ],
          ),
        ),
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(namespace: 'navigation_test_lab', routeName: 'node_b1'),
          path: '/dev/navigation/b/b1',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Node B1',
            routePath: '/dev/navigation/b/b1',
            parentPath: '/dev/navigation/b',
            depth: 2,
            branch: 'B',
            children: [
              TestNodeChild('Node B1.1', '/dev/navigation/b/b1/b1-1'),
              TestNodeChild('Node B1.2', '/dev/navigation/b/b1/b1-2'),
            ],
          ),
        ),
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(
            namespace: 'navigation_test_lab',
            routeName: 'node_b1_1',
          ),
          path: '/dev/navigation/b/b1/b1-1',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Node B1.1',
            routePath: '/dev/navigation/b/b1/b1-1',
            parentPath: '/dev/navigation/b/b1',
            depth: 3,
            branch: 'B',
            children: [],
          ),
        ),
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(
            namespace: 'navigation_test_lab',
            routeName: 'node_b1_2',
          ),
          path: '/dev/navigation/b/b1/b1-2',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Node B1.2',
            routePath: '/dev/navigation/b/b1/b1-2',
            parentPath: '/dev/navigation/b/b1',
            depth: 3,
            branch: 'B',
            children: [],
          ),
        ),
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(namespace: 'navigation_test_lab', routeName: 'node_b2'),
          path: '/dev/navigation/b/b2',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Node B2',
            routePath: '/dev/navigation/b/b2',
            parentPath: '/dev/navigation/b',
            depth: 2,
            branch: 'B',
            children: [
              TestNodeChild('Node B2.1', '/dev/navigation/b/b2/b2-1'),
            ],
          ),
        ),
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(
            namespace: 'navigation_test_lab',
            routeName: 'node_b2_1',
          ),
          path: '/dev/navigation/b/b2/b2-1',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Node B2.1',
            routePath: '/dev/navigation/b/b2/b2-1',
            parentPath: '/dev/navigation/b/b2',
            depth: 3,
            branch: 'B',
            children: [],
          ),
        ),

        // Branch C Routes
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(namespace: 'navigation_test_lab', routeName: 'node_c'),
          path: '/dev/navigation/c',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Branch C Root',
            routePath: '/dev/navigation/c',
            parentPath: '/dev/navigation',
            depth: 1,
            branch: 'C',
            children: [
              TestNodeChild('Node C1', '/dev/navigation/c/c1'),
              TestNodeChild('Node C2', '/dev/navigation/c/c2'),
            ],
          ),
        ),
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(namespace: 'navigation_test_lab', routeName: 'node_c1'),
          path: '/dev/navigation/c/c1',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Node C1',
            routePath: '/dev/navigation/c/c1',
            parentPath: '/dev/navigation/c',
            depth: 2,
            branch: 'C',
            children: [
              TestNodeChild('Node C1.1', '/dev/navigation/c/c1/c1-1'),
            ],
          ),
        ),
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(
            namespace: 'navigation_test_lab',
            routeName: 'node_c1_1',
          ),
          path: '/dev/navigation/c/c1/c1-1',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Node C1.1',
            routePath: '/dev/navigation/c/c1/c1-1',
            parentPath: '/dev/navigation/c/c1',
            depth: 3,
            branch: 'C',
            children: [
              TestNodeChild('Node C1.1.1 (Deepest)', '/dev/navigation/c/c1/c1-1/c1-1-1'),
            ],
          ),
        ),
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(
            namespace: 'navigation_test_lab',
            routeName: 'node_c1_1_1',
          ),
          path: '/dev/navigation/c/c1/c1-1/c1-1-1',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Node C1.1.1',
            routePath: '/dev/navigation/c/c1/c1-1/c1-1-1',
            parentPath: '/dev/navigation/c/c1/c1-1',
            depth: 4,
            branch: 'C',
            children: [],
          ),
        ),
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(namespace: 'navigation_test_lab', routeName: 'node_c2'),
          path: '/dev/navigation/c/c2',
          pageBuilder: (context) => const NavigationTestNodeScreen(
            nodeName: 'Node C2',
            routePath: '/dev/navigation/c/c2',
            parentPath: '/dev/navigation/c',
            depth: 2,
            branch: 'C',
            children: [],
          ),
        ),

        // Parameter Route Test
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(namespace: 'navigation_test_lab', routeName: 'node_param_100'),
          path: '/dev/navigation/param/100',
          pageBuilder: (context) => const NavigationTestParamScreen(itemId: '100'),
        ),
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(namespace: 'navigation_test_lab', routeName: 'node_param_200'),
          path: '/dev/navigation/param/200',
          pageBuilder: (context) => const NavigationTestParamScreen(itemId: '200'),
        ),

        // Destructive Navigation Test
        NexaBizFlutterRouteDefinition(
          routeId: const NexaBizRouteId(
            namespace: 'navigation_test_lab',
            routeName: 'node_destructive',
          ),
          path: '/dev/navigation/destructive',
          pageBuilder: (context) => const NavigationTestDestructiveScreen(),
        ),
      ];
}

/// Helper child node descriptor for test lab screen trees.
class TestNodeChild {
  final String label;
  final String path;
  const TestNodeChild(this.label, this.path);
}
