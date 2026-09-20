import '../../permissions/nexabiz_permission_intent.dart';

/// Declares permission identities and dependencies without evaluating them.
abstract interface class NexaBizPermissionContribution {
  List<NexaBizPermissionId> get declaredPermissionIds;

  List<NexaBizPermissionRequirement> get requiredPermissions;
}
