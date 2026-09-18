import '../../core/capabilities/capability_metadata.dart';
import '../../core/capabilities/nexabiz_capability.dart';
import '../../core/navigation/nexabiz_navigation_contribution.dart';
import '../../core/navigation/nexabiz_route_definition.dart';
import '../../app/router/nexabiz_flutter_route_definition.dart';
import '../../core/navigation/nexabiz_route_id.dart';
import 'presentation/demo_page.dart';

class _DemoNavigationContribution implements NexaBizNavigationContribution {
  static const NexaBizRouteId _rootRouteId = NexaBizRouteId(
    namespace: 'demo',
    routeName: 'root',
  );

  @override
  NexaBizRouteId get rootRouteId => _rootRouteId;

  @override
  List<NexaBizRouteDefinition> get routes => [
    NexaBizFlutterRouteDefinition(
      routeId: _rootRouteId,
      path: '/demo',
      pageBuilder: (context) => const DemoPage(),
    ),
  ];
}

/// Minimal demo capability for architecture verification.
class DemoCapability implements NexaBizCapability {
  @override
  String get capabilityId => 'demo';

  @override
  CapabilityMetadata get metadata => const CapabilityMetadata(
    nameKey: 'demo.title',
    iconIdentifier: 'demo',
    sortOrder: 0,
  );

  @override
  List<String> get dependsOn => const [];

  @override
  NexaBizNavigationContribution? get navigationContribution =>
      _DemoNavigationContribution();
}
