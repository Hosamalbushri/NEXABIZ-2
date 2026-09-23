import '../company/nexabiz_company_scope.dart';
import '../session/nexabiz_session.dart';
import 'nexabiz_membership_id.dart';

/// Pure Dart abstraction providing trusted verification of the active session context.
///
/// Ensures an authorization evaluator can verify that a given [NexaBizAuthorizationContext]
/// is bound to a currently active, non-stale authenticated session without tight coupling
/// to the full stateful session controller.
abstract interface class NexaBizAuthorizationSessionSource {
  /// Checks whether an active session currently matches the given parameters.
  ///
  /// Returns `true` if and only if:
  /// - An active session exists,
  /// - The session state is active (not locked, expired, or ended),
  /// - [sessionId] matches the current active session ID,
  /// - [userId] matches the current active session user ID,
  /// - and if provided, [companyId] matches the current active session company ID,
  /// - and if provided, [membershipId] matches the current active session membership ID.
  bool matchesActiveSession({
    required String sessionId,
    required NexaBizUserId userId,
    NexaBizCompanyId? companyId,
    NexaBizMembershipId? membershipId,
  });
}
