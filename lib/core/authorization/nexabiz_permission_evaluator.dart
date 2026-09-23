import '../permissions/nexabiz_permission_intent.dart';
import 'nexabiz_authorization_context.dart';

/// Pure domain interface for evaluating whether a permission is allowed.
///
/// Implementations MUST adhere to the Fail-Closed principle:
/// - If a permission is not explicitly granted, return [NexaBizPermissionDecision.deny]
///   or [NexaBizPermissionDecision.unknown].
/// - An unknown or absent decision is never allowed (`isAllowed == false`).
/// - No role name or identity (e.g. "owner", "admin") provides an implicit bypass.
/// - This interface is pure Dart and must not depend on Flutter, UI, or Riverpod.
abstract interface class NexaBizPermissionEvaluator {
  Future<NexaBizPermissionDecision> evaluate({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  });
}
