import '../nexabiz_capability.dart';
import 'nexabiz_permission_contribution.dart';
import 'nexabiz_setup_contribution.dart';

/// Optional capability extension for descriptive runtime contributions.
/// Existing capabilities remain valid without implementing this interface.
abstract interface class NexaBizCapabilityWithRuntimeContributions
    implements NexaBizCapability {
  NexaBizSetupContribution? get setupContribution;

  NexaBizPermissionContribution? get permissionContribution;
}
