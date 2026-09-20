import '../../core/capabilities/nexabiz_capability.dart';
import '../../core/session/core_session_controller.dart';
import '../../core/setup/initialize_nexabiz_core.dart';
import '../../core/setup/nexabiz_setup_readiness.dart';
import '../../packages/company/company_capability.dart';
import '../../packages/dashboard/dashboard_capability.dart';
import '../../packages/development/navigation_test_lab/navigation_test_lab_capability.dart';
import '../../packages/gallery/gallery_capability.dart';
import '../../packages/identity/identity_capability.dart';
import '../../packages/permissions/permissions_capability.dart';
import '../../packages/reports/reports_capability.dart';
import '../../packages/services/services_capability.dart';
import '../../packages/settings/settings_capability.dart';
import '../../packages/splash/splash_capability.dart';
import '../../packages/system_setup/system_setup_capability.dart';

/// Central compile-time manifest defining all capabilities registered in NexaBiz ERP.
class NexaBizCapabilityManifest {
  const NexaBizCapabilityManifest._();

  /// Immutable list of all application capabilities.
  static List<NexaBizCapability> get capabilities => capabilitiesFor();

  static List<NexaBizCapability> capabilitiesFor({
    InitializeNexaBizCore? initializer,
    NexaBizSetupReadiness? readiness,
    CoreSessionController? sessionController,
  }) => [
    const SplashCapability(),
    DashboardCapability(),
    CompanyCapability(sessionController: sessionController),
    IdentityCapability(sessionController: sessionController),
    PermissionsCapability(),
    ServicesCapability(),
    ReportsCapability(),
    SettingsCapability(sessionController: sessionController),
    SystemSetupCapability(initializer: initializer, readiness: readiness),
    GalleryCapability(),
    NavigationTestLabCapability(),
  ];
}
