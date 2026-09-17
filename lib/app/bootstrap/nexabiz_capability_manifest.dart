import '../../core/capabilities/nexabiz_capability.dart';
import '../../packages/dashboard/dashboard_capability.dart';
import '../../packages/reports/reports_capability.dart';
import '../../packages/services/services_capability.dart';
import '../../packages/settings/settings_capability.dart';

import '../../packages/gallery/gallery_capability.dart';

/// Central compile-time manifest defining all capabilities registered in NexaBiz ERP.
class NexaBizCapabilityManifest {
  const NexaBizCapabilityManifest._();

  /// Immutable list of all application capabilities.
  static List<NexaBizCapability> get capabilities => [
        DashboardCapability(),
        ServicesCapability(),
        ReportsCapability(),
        SettingsCapability(),
        GalleryCapability(),
      ];
}
