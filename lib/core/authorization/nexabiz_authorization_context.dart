import '../company/nexabiz_company_scope.dart';
import '../roles/nexabiz_role_scope.dart';
import '../session/nexabiz_session.dart';
import 'nexabiz_authorization_subject.dart';
import 'nexabiz_membership_id.dart';

/// Context within which an authorization decision is evaluated.
///
/// Sealed hierarchy enforcing compile-time type safety:
/// - [NexaBizSystemAuthorizationContext]: strictly system scope, no company or membership.
/// - [NexaBizCompanyAuthorizationContext]: strictly company scope, guarantees non-null company and membership identities.
sealed class NexaBizAuthorizationContext {
  const NexaBizAuthorizationContext();

  NexaBizAuthorizationSubject get subject;
  NexaBizRoleScope get scope;
  NexaBizUserId get userId => subject.userId;
  String? get sessionId => subject.sessionId;

  bool get isSystem => scope.isSystem;
  bool get isCompany => scope.isCompany;

  /// Creates an authoritative [NexaBizAuthorizationContext] from an active [session].
  ///
  /// Resolves to [NexaBizCompanyAuthorizationContext] when the session contains
  /// an active company and membership binding; otherwise [NexaBizSystemAuthorizationContext].
  ///
  /// Throws [StateError] if the session is not active or missing required identities.
  factory NexaBizAuthorizationContext.fromSession(NexaBizSession session) {
    if (!session.isActive) {
      throw StateError(
        'Cannot create authorization context from inactive session.',
      );
    }
    if (session.companyId != null && session.membershipId != null) {
      return NexaBizCompanyAuthorizationContext.fromSession(session);
    }
    return NexaBizSystemAuthorizationContext.fromSession(session);
  }
}

/// Authorization context for system-level operations.
///
/// Explicitly contains no company or membership identity.
final class NexaBizSystemAuthorizationContext
    extends NexaBizAuthorizationContext {
  NexaBizSystemAuthorizationContext({
    required NexaBizUserId userId,
    String? sessionId,
  }) : subject = NexaBizAuthorizationSubject(
         userId: userId,
         sessionId: sessionId,
       );

  NexaBizSystemAuthorizationContext.fromSubject(this.subject) {
    if (subject.companyId != null || subject.membershipId != null) {
      throw ArgumentError(
        'System authorization context cannot have company or membership ID.',
      );
    }
  }

  /// Creates a [NexaBizSystemAuthorizationContext] from an active [session].
  ///
  /// Throws [StateError] if the session is inactive or missing userId or sessionId.
  factory NexaBizSystemAuthorizationContext.fromSession(
    NexaBizSession session,
  ) {
    if (!session.isActive) {
      throw StateError(
        'Cannot create authorization context from inactive session.',
      );
    }
    final userId = session.userId;
    final sessionId = session.sessionId;
    if (userId == null || sessionId == null) {
      throw StateError('Active session is missing userId or sessionId.');
    }
    return NexaBizSystemAuthorizationContext(
      userId: userId,
      sessionId: sessionId,
    );
  }

  @override
  final NexaBizAuthorizationSubject subject;

  @override
  NexaBizRoleScope get scope => NexaBizRoleScope.system;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizSystemAuthorizationContext && subject == other.subject;

  @override
  int get hashCode => Object.hash(NexaBizSystemAuthorizationContext, subject);

  @override
  String toString() => 'NexaBizSystemAuthorizationContext(subject: $subject)';
}

/// Authorization context for company-tenant-level operations.
///
/// Guaranteed to contain non-null [companyId] and [membershipId].
final class NexaBizCompanyAuthorizationContext
    extends NexaBizAuthorizationContext {
  NexaBizCompanyAuthorizationContext({
    required NexaBizUserId userId,
    required this.companyId,
    required this.membershipId,
    String? sessionId,
  }) : subject = NexaBizAuthorizationSubject(
         userId: userId,
         companyId: companyId,
         membershipId: membershipId,
         sessionId: sessionId,
       );

  factory NexaBizCompanyAuthorizationContext.fromSubject(
    NexaBizAuthorizationSubject subject,
  ) {
    final companyId = subject.companyId;
    if (companyId == null) {
      throw ArgumentError(
        'Company authorization context requires subject.companyId.',
      );
    }
    final membershipId = subject.membershipId;
    if (membershipId == null) {
      throw ArgumentError(
        'Company authorization context requires subject.membershipId.',
      );
    }
    return NexaBizCompanyAuthorizationContext(
      userId: subject.userId,
      companyId: companyId,
      membershipId: membershipId,
      sessionId: subject.sessionId,
    );
  }

  /// Creates a [NexaBizCompanyAuthorizationContext] from an active company [session].
  ///
  /// Guarantees that [userId], [companyId], [membershipId], and [sessionId] are
  /// all present and sourced directly from the active session.
  ///
  /// Throws [StateError] if the session is inactive or missing any required identity binding.
  factory NexaBizCompanyAuthorizationContext.fromSession(
    NexaBizSession session,
  ) {
    if (!session.isActive) {
      throw StateError(
        'Cannot create authorization context from inactive session.',
      );
    }
    final userId = session.userId;
    final companyId = session.companyId;
    final membershipId = session.membershipId;
    final sessionId = session.sessionId;

    if (userId == null ||
        companyId == null ||
        membershipId == null ||
        sessionId == null) {
      throw StateError(
        'Active company session is missing userId, companyId, membershipId, or sessionId.',
      );
    }

    return NexaBizCompanyAuthorizationContext(
      userId: userId,
      companyId: companyId,
      membershipId: membershipId,
      sessionId: sessionId,
    );
  }

  @override
  final NexaBizAuthorizationSubject subject;

  final NexaBizCompanyId companyId;
  final NexaBizMembershipId membershipId;

  @override
  NexaBizRoleScope get scope => NexaBizRoleScope.company;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizCompanyAuthorizationContext &&
          subject == other.subject &&
          companyId == other.companyId &&
          membershipId == other.membershipId;

  @override
  int get hashCode => Object.hash(
    NexaBizCompanyAuthorizationContext,
    subject,
    companyId,
    membershipId,
  );

  @override
  String toString() =>
      'NexaBizCompanyAuthorizationContext(subject: $subject, companyId: $companyId, membershipId: $membershipId)';
}
