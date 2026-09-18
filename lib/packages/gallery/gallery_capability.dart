import 'package:nexabiz_ui/nexabiz_ui.dart';
import '../../core/capabilities/capability_metadata.dart';
import '../../core/capabilities/nexabiz_capability.dart';
import '../../core/navigation/nexabiz_navigation_contribution.dart';
import '../../core/navigation/nexabiz_route_definition.dart';
import '../../app/router/nexabiz_flutter_route_definition.dart';
import '../../core/navigation/nexabiz_route_id.dart';

class _GalleryNavigationContribution implements NexaBizNavigationContribution {
  static const NexaBizRouteId _rootRouteId = NexaBizRouteId(
    namespace: 'gallery',
    routeName: 'root',
  );

  @override
  NexaBizRouteId get rootRouteId => _rootRouteId;

  @override
  List<NexaBizRouteDefinition> get routes => [
    NexaBizFlutterRouteDefinition(
      routeId: _rootRouteId,
      path: '/gallery',
      pageBuilder: (context) => const ComponentGalleryPage(),
    ),
  ];
}

/// Capability registering the Shadcn Flutter Component Gallery & Playground.
class GalleryCapability implements NexaBizCapability {
  @override
  String get capabilityId => 'gallery';

  @override
  CapabilityMetadata get metadata => const CapabilityMetadata(
    nameKey: 'gallery.title',
    iconIdentifier: 'grid',
    sortOrder: 99,
  );

  @override
  List<String> get dependsOn => const [];

  @override
  NexaBizNavigationContribution? get navigationContribution =>
      _GalleryNavigationContribution();
}
