import '../../../core/capabilities/capability_metadata.dart';
import '../../../core/capabilities/nexabiz_capability.dart';
import '../../../core/navigation/nexabiz_navigation_contribution.dart';
import '../../../core/navigation/nexabiz_route_definition.dart';
import '../../../core/navigation/nexabiz_route_id.dart';
import '../../../app/router/nexabiz_flutter_route_definition.dart';
import '../../../l10n/app_localizations.dart';
import 'presentation/navigation_test_destructive_screen.dart';
import 'presentation/navigation_test_lab_dashboard.dart';
import 'presentation/navigation_test_node_screen.dart';
import 'presentation/navigation_test_param_screen.dart';
import 'presentation/nested_navigation_test_page.dart';

/// Capability introducing the development-only Navigation Test Lab.
/// Contributes deep branching routes under the isolated `/dev/navigation/...` namespace.
class NavigationTestLabCapability implements NexaBizCapability {
  @override
  String get capabilityId => 'navigation_test_lab';

  @override
  CapabilityMetadata get metadata => const CapabilityMetadata(
    nameKey: 'navLabTitle',
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
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_a',
      ),
      path: '/dev/navigation/a',
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabBranchRootTitle('A'),
        routePath: '/dev/navigation/a',
        parentPath: '/dev/navigation',
        depth: 1,
        branch: 'A',
        children: [
          TestNodeChild(
            AppLocalizations.of(context).navLabNodeTitle('A1'),
            '/dev/navigation/a/a1',
          ),
          TestNodeChild(
            AppLocalizations.of(context).navLabNodeTitle('A2'),
            '/dev/navigation/a/a2',
          ),
        ],
      ),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_a1',
      ),
      path: '/dev/navigation/a/a1',
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabNodeTitle('A1'),
        routePath: '/dev/navigation/a/a1',
        parentPath: '/dev/navigation/a',
        depth: 2,
        branch: 'A',
        children: [
          TestNodeChild(
            AppLocalizations.of(context).navLabNodeTitle('A1.1'),
            '/dev/navigation/a/a1/a1-1',
          ),
          TestNodeChild(
            AppLocalizations.of(context).navLabNodeSiblingTitle('A1.2'),
            '/dev/navigation/a/a1/a1-2',
          ),
        ],
      ),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_a1_1',
      ),
      path: '/dev/navigation/a/a1/a1-1',
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabNodeTitle('A1.1'),
        routePath: '/dev/navigation/a/a1/a1-1',
        parentPath: '/dev/navigation/a/a1',
        depth: 3,
        branch: 'A',
        children: [
          TestNodeChild(
            AppLocalizations.of(context).navLabNodeDeepestTitle('A1.1.1'),
            '/dev/navigation/a/a1/a1-1/a1-1-1',
          ),
        ],
      ),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_a1_1_1',
      ),
      path: '/dev/navigation/a/a1/a1-1/a1-1-1',
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabNodeTitle('A1.1.1'),
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
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabNodeTitle('A1.2'),
        routePath: '/dev/navigation/a/a1/a1-2',
        parentPath: '/dev/navigation/a/a1',
        depth: 3,
        branch: 'A',
        children: [],
      ),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_a2',
      ),
      path: '/dev/navigation/a/a2',
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabNodeTitle('A2'),
        routePath: '/dev/navigation/a/a2',
        parentPath: '/dev/navigation/a',
        depth: 2,
        branch: 'A',
        children: [
          TestNodeChild(
            AppLocalizations.of(context).navLabNodeTitle('A2.1'),
            '/dev/navigation/a/a2/a2-1',
          ),
        ],
      ),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_a2_1',
      ),
      path: '/dev/navigation/a/a2/a2-1',
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabNodeTitle('A2.1'),
        routePath: '/dev/navigation/a/a2/a2-1',
        parentPath: '/dev/navigation/a/a2',
        depth: 3,
        branch: 'A',
        children: [],
      ),
    ),

    // Branch B Routes
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_b',
      ),
      path: '/dev/navigation/b',
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabBranchRootTitle('B'),
        routePath: '/dev/navigation/b',
        parentPath: '/dev/navigation',
        depth: 1,
        branch: 'B',
        children: [
          TestNodeChild(
            AppLocalizations.of(context).navLabNodeTitle('B1'),
            '/dev/navigation/b/b1',
          ),
          TestNodeChild(
            AppLocalizations.of(context).navLabNodeTitle('B2'),
            '/dev/navigation/b/b2',
          ),
        ],
      ),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_b1',
      ),
      path: '/dev/navigation/b/b1',
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabNodeTitle('B1'),
        routePath: '/dev/navigation/b/b1',
        parentPath: '/dev/navigation/b',
        depth: 2,
        branch: 'B',
        children: [
          TestNodeChild(
            AppLocalizations.of(context).navLabNodeTitle('B1.1'),
            '/dev/navigation/b/b1/b1-1',
          ),
          TestNodeChild(
            AppLocalizations.of(context).navLabNodeTitle('B1.2'),
            '/dev/navigation/b/b1/b1-2',
          ),
        ],
      ),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_b1_1',
      ),
      path: '/dev/navigation/b/b1/b1-1',
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabNodeTitle('B1.1'),
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
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabNodeTitle('B1.2'),
        routePath: '/dev/navigation/b/b1/b1-2',
        parentPath: '/dev/navigation/b/b1',
        depth: 3,
        branch: 'B',
        children: [],
      ),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_b2',
      ),
      path: '/dev/navigation/b/b2',
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabNodeTitle('B2'),
        routePath: '/dev/navigation/b/b2',
        parentPath: '/dev/navigation/b',
        depth: 2,
        branch: 'B',
        children: [
          TestNodeChild(
            AppLocalizations.of(context).navLabNodeTitle('B2.1'),
            '/dev/navigation/b/b2/b2-1',
          ),
        ],
      ),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_b2_1',
      ),
      path: '/dev/navigation/b/b2/b2-1',
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabNodeTitle('B2.1'),
        routePath: '/dev/navigation/b/b2/b2-1',
        parentPath: '/dev/navigation/b/b2',
        depth: 3,
        branch: 'B',
        children: [],
      ),
    ),

    // Branch C Routes
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_c',
      ),
      path: '/dev/navigation/c',
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabBranchRootTitle('C'),
        routePath: '/dev/navigation/c',
        parentPath: '/dev/navigation',
        depth: 1,
        branch: 'C',
        children: [
          TestNodeChild(
            AppLocalizations.of(context).navLabNodeTitle('C1'),
            '/dev/navigation/c/c1',
          ),
          TestNodeChild(
            AppLocalizations.of(context).navLabNodeTitle('C2'),
            '/dev/navigation/c/c2',
          ),
        ],
      ),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_c1',
      ),
      path: '/dev/navigation/c/c1',
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabNodeTitle('C1'),
        routePath: '/dev/navigation/c/c1',
        parentPath: '/dev/navigation/c',
        depth: 2,
        branch: 'C',
        children: [
          TestNodeChild(
            AppLocalizations.of(context).navLabNodeTitle('C1.1'),
            '/dev/navigation/c/c1/c1-1',
          ),
        ],
      ),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_c1_1',
      ),
      path: '/dev/navigation/c/c1/c1-1',
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabNodeTitle('C1.1'),
        routePath: '/dev/navigation/c/c1/c1-1',
        parentPath: '/dev/navigation/c/c1',
        depth: 3,
        branch: 'C',
        children: [
          TestNodeChild(
            AppLocalizations.of(context).navLabNodeDeepestTitle('C1.1.1'),
            '/dev/navigation/c/c1/c1-1/c1-1-1',
          ),
        ],
      ),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_c1_1_1',
      ),
      path: '/dev/navigation/c/c1/c1-1/c1-1-1',
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabNodeTitle('C1.1.1'),
        routePath: '/dev/navigation/c/c1/c1-1/c1-1-1',
        parentPath: '/dev/navigation/c/c1/c1-1',
        depth: 4,
        branch: 'C',
        children: [],
      ),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_c2',
      ),
      path: '/dev/navigation/c/c2',
      pageBuilder: (context) => NavigationTestNodeScreen(
        nodeName: AppLocalizations.of(context).navLabNodeTitle('C2'),
        routePath: '/dev/navigation/c/c2',
        parentPath: '/dev/navigation/c',
        depth: 2,
        branch: 'C',
        children: [],
      ),
    ),

    // Parameter Route Test
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_param_100',
      ),
      path: '/dev/navigation/param/100',
      pageBuilder: (context) => const NavigationTestParamScreen(itemId: '100'),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'node_param_200',
      ),
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
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'nested_root',
      ),
      path: '/navigation-test-lab',
      pageBuilder: (context) =>
          const NestedNavigationTestPage(node: NestedNavigationTestNode.root),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'nested_details',
      ),
      parentRouteId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'nested_root',
      ),
      path: '/navigation-test-lab/details',
      pageBuilder: (context) => const NestedNavigationTestPage(
        node: NestedNavigationTestNode.details,
      ),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'nested_audit',
      ),
      parentRouteId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'nested_details',
      ),
      path: '/navigation-test-lab/details/audit',
      pageBuilder: (context) =>
          const NestedNavigationTestPage(node: NestedNavigationTestNode.audit),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'nested_settings',
      ),
      parentRouteId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'nested_root',
      ),
      path: '/navigation-test-lab/settings',
      pageBuilder: (context) => const NestedNavigationTestPage(
        node: NestedNavigationTestNode.settings,
      ),
    ),
    NexaBizFlutterRouteDefinition(
      routeId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'nested_advanced',
      ),
      parentRouteId: const NexaBizRouteId(
        namespace: 'navigation_test_lab',
        routeName: 'nested_settings',
      ),
      path: '/navigation-test-lab/settings/advanced',
      pageBuilder: (context) => const NestedNavigationTestPage(
        node: NestedNavigationTestNode.advanced,
      ),
    ),
  ];
}

/// Helper child node descriptor for test lab screen trees.
class TestNodeChild {
  final String label;
  final String path;
  const TestNodeChild(this.label, this.path);
}
