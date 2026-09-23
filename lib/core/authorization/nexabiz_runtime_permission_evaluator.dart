import '../permissions/nexabiz_permission_intent.dart';
import 'core_authorization_query_store.dart';
import 'nexabiz_authorization_context.dart';
import 'nexabiz_authorization_session_source.dart';
import 'nexabiz_permission_catalog.dart';
import 'nexabiz_permission_evaluator.dart';

/// Canonical runtime permission evaluator enforcing the NexaBiz RBAC security contracts.
///
/// Follows strict Fail-Closed semantics:
/// 1. Verifies that the requested [NexaBizPermissionId] is declared in [permissionCatalog].
///    If undeclared -> returns [NexaBizPermissionDecision.unknown].
/// 2. Verifies that the context is bound to a valid active session via [sessionSource].
///    If invalid, missing, or mismatched -> returns [NexaBizPermissionDecision.deny].
/// 3. For company-scoped authorization ([NexaBizCompanyAuthorizationContext]):
///    - Loads a fresh atomic snapshot via [queryStore.readMembershipAuthorizationSnapshot].
///    - Validates that the snapshot matches the context's membership, company, and user identities.
///    - Validates that the membership, company, and user are all active ([NexaBizMembershipAuthorizationSnapshot.isEligibleForAuthorization]).
///    - Checks if the permission exists in [NexaBizMembershipAuthorizationSnapshot.effectivePermissions].
///    - Returns [NexaBizPermissionDecision.allow] iff explicitly granted; otherwise [NexaBizPermissionDecision.deny].
/// 4. For system-scoped authorization ([NexaBizSystemAuthorizationContext]):
///    - Returns [NexaBizPermissionDecision.deny] (system assignment persistence is not yet supported).
/// 5. Infrastructure / storage errors fail closed safely without leaking internal details.
final class NexaBizRuntimePermissionEvaluator
    implements NexaBizPermissionEvaluator {
  const NexaBizRuntimePermissionEvaluator({
    required this.permissionCatalog,
    required this.queryStore,
    required this.sessionSource,
  });

  final NexaBizPermissionCatalog permissionCatalog;
  final CoreAuthorizationQueryStore queryStore;
  final NexaBizAuthorizationSessionSource sessionSource;

  @override
  Future<NexaBizPermissionDecision> evaluate({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  }) async {
    // 1. Permission Catalog Validation
    // Undeclared permissions cannot be evaluated or granted, regardless of database contents.
    if (!permissionCatalog.isDeclared(permissionId)) {
      return NexaBizPermissionDecision.unknown;
    }

    // 2. Session Binding Validation
    // Context must have an active session ID matching trusted session state.
    final sessionId = context.sessionId;
    if (sessionId == null || sessionId.trim().isEmpty) {
      return NexaBizPermissionDecision.deny;
    }

    try {
      final isSessionValid = switch (context) {
        NexaBizCompanyAuthorizationContext companyCtx =>
          sessionSource.matchesActiveSession(
            sessionId: sessionId,
            userId: companyCtx.userId,
            companyId: companyCtx.companyId,
            membershipId: companyCtx.membershipId,
          ),
        NexaBizSystemAuthorizationContext systemCtx =>
          sessionSource.matchesActiveSession(
            sessionId: sessionId,
            userId: systemCtx.userId,
          ),
      };

      if (!isSessionValid) {
        return NexaBizPermissionDecision.deny;
      }
    } catch (e) {
      if (e is ArgumentError ||
          e is StateError ||
          e is TypeError ||
          e is AssertionError) {
        rethrow;
      }
      return NexaBizPermissionDecision.deny;
    }

    // 3. Context Scope Evaluation
    switch (context) {
      case NexaBizCompanyAuthorizationContext companyCtx:
        try {
          // Fresh atomic snapshot per evaluation: No caching in Phase 04.4.
          final snapshot = await queryStore.readMembershipAuthorizationSnapshot(
            companyCtx.membershipId.value,
          );

          if (snapshot == null) {
            return NexaBizPermissionDecision.deny;
          }

          // Anti-tampering / Cross-tenant consistency check:
          // Snapshot technical facts must strictly match authorization context.
          if (snapshot.membershipId != companyCtx.membershipId ||
              snapshot.companyId != companyCtx.companyId ||
              snapshot.userId != companyCtx.userId) {
            return NexaBizPermissionDecision.deny;
          }

          // Inactive user, company, or membership fails closed.
          if (!snapshot.isEligibleForAuthorization) {
            return NexaBizPermissionDecision.deny;
          }

          // Check effective permissions union (deduplicated across all assigned roles)
          if (snapshot.effectivePermissions.contains(permissionId)) {
            return NexaBizPermissionDecision.allow;
          }

          return NexaBizPermissionDecision.deny;
        } catch (e) {
          if (e is ArgumentError ||
              e is StateError ||
              e is TypeError ||
              e is AssertionError) {
            rethrow;
          }
          return NexaBizPermissionDecision.deny;
        }

      case NexaBizSystemAuthorizationContext _:
        // System roles and permissions persistence is deferred.
        // Fail-Closed: Never grant implicit access to system scope.
        return NexaBizPermissionDecision.deny;
    }
  }
}
