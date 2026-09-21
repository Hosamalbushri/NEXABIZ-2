import '../permissions/nexabiz_permission_intent.dart';
import 'nexabiz_authorization_context.dart';
import 'nexabiz_permission_denied_exception.dart';
import 'nexabiz_permission_evaluator.dart';

/// Pure domain guard for enforcing permissions in UseCases and domain services.
///
/// Throws [NexaBizPermissionDeniedException] when evaluation fails.
abstract interface class NexaBizPermissionGuard {
  Future<void> requirePermission({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  });
}

/// Canonical Fail-Closed implementation of [NexaBizPermissionGuard].
final class NexaBizDefaultPermissionGuard implements NexaBizPermissionGuard {
  const NexaBizDefaultPermissionGuard(this._evaluator);

  final NexaBizPermissionEvaluator _evaluator;

  @override
  Future<void> requirePermission({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  }) async {
    final decision = await _evaluator.evaluate(
      context: context,
      permissionId: permissionId,
    );
    if (!decision.isAllowed) {
      throw NexaBizPermissionDeniedException(
        permissionId: permissionId,
        contextScope: context.scope,
        decision: decision,
      );
    }
  }
}

