import '../authorization/nexabiz_membership_id.dart';
import '../company/nexabiz_company_scope.dart';
import '../identity/authenticate_local_user.dart';

/// Validated, opaque user identity for a local session contract.
final class NexaBizUserId {
  factory NexaBizUserId(String value) {
    if (value.isEmpty || value.trim() != value) {
      throw ArgumentError.value(
        value,
        'value',
        'User ID must be non-empty and unpadded.',
      );
    }
    return NexaBizUserId._(value);
  }

  const NexaBizUserId._(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NexaBizUserId && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'NexaBizUserId(<redacted>)';
}

enum NexaBizSessionState { noSession, activeSession, lockedSession }

/// Immutable local session snapshot; each active or locked session has one company.
/// A later company switch must end this session and create a distinct one.
final class NexaBizSession {
  const NexaBizSession.noSession()
    : state = NexaBizSessionState.noSession,
      userId = null,
      companyId = null,
      membershipId = null,
      userName = null,
      userEmail = null,
      companyName = null,
      companyCode = null,
      role = null,
      availableCompanies = const [],
      sessionId = null;

  const NexaBizSession.active({
    required NexaBizUserId this.userId,
    required this.companyId,
    this.membershipId,
    this.userName,
    this.userEmail,
    this.companyName,
    this.companyCode,
    this.role,
    this.availableCompanies = const [],
    this.sessionId,
  }) : state = NexaBizSessionState.activeSession;

  const NexaBizSession.locked({
    required NexaBizUserId this.userId,
    required this.companyId,
    this.membershipId,
    this.userName,
    this.userEmail,
    this.companyName,
    this.companyCode,
    this.role,
    this.availableCompanies = const [],
    this.sessionId,
  }) : state = NexaBizSessionState.lockedSession;

  final NexaBizSessionState state;
  final NexaBizUserId? userId;
  final NexaBizCompanyId? companyId;
  final NexaBizMembershipId? membershipId;
  final String? userName;
  final String? userEmail;
  final String? companyName;
  final String? companyCode;
  final String? role;
  final List<CoreAuthCompanyRef> availableCompanies;
  final String? sessionId;

  bool get isActive => state == NexaBizSessionState.activeSession;
  bool get hasActiveCompany => companyId != null;
  bool get requiresCompanySelection =>
      isActive && companyId == null && availableCompanies.length > 1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizSession &&
          state == other.state &&
          userId == other.userId &&
          companyId == other.companyId &&
          membershipId == other.membershipId &&
          sessionId == other.sessionId;

  @override
  int get hashCode =>
      Object.hash(state, userId, companyId, membershipId, sessionId);

  @override
  String toString() => 'NexaBizSession($state, identities=<redacted>)';
}
