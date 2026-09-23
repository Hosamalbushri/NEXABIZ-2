import '../permissions/nexabiz_permission_intent.dart';
import '../roles/nexabiz_role_scope.dart';

/// Exception thrown when an action or usecase requires a permission that is not granted.
///
/// Contains safe technical metadata without exposing sensitive credentials, PII,
/// or system secrets.
final class NexaBizPermissionDeniedException implements Exception {
  const NexaBizPermissionDeniedException({
    required this.permissionId,
    required this.contextScope,
    required this.decision,
    this.message,
  });

  final NexaBizPermissionId permissionId;
  final NexaBizRoleScope contextScope;
  final NexaBizPermissionDecision decision;
  final String? message;

  @override
  String toString() {
    final suffix = message != null ? ': $message' : '';
    return 'NexaBizPermissionDeniedException(permissionId: $permissionId, scope: ${contextScope.name}, decision: ${decision.name}$suffix)';
  }
}
