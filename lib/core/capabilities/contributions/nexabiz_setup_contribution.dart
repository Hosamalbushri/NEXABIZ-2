import '../../setup/nexabiz_setup_requirement_id.dart';

/// Describes setup requirements a capability provides or needs.
/// No setup execution or state mutation is defined here.
abstract interface class NexaBizSetupContribution {
  List<NexaBizSetupRequirementId> get providedRequirements;

  List<NexaBizSetupRequirementId> get requiredRequirements;
}
