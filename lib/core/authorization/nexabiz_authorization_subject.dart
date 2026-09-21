import '../company/nexabiz_company_scope.dart';
import '../session/nexabiz_session.dart';
import 'nexabiz_membership_id.dart';

/// Technical subject for authorization evaluation.
///
/// Contains only identifiers required to locate security assignments and memberships.
/// MUST NOT hold passwords, credentials, email addresses, or personal data.
final class NexaBizAuthorizationSubject {
  const NexaBizAuthorizationSubject({
    required this.userId,
    this.companyId,
    this.membershipId,
    this.sessionId,
  });

  final NexaBizUserId userId;
  final NexaBizCompanyId? companyId;
  final NexaBizMembershipId? membershipId;
  final String? sessionId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizAuthorizationSubject &&
          userId == other.userId &&
          companyId == other.companyId &&
          membershipId == other.membershipId &&
          sessionId == other.sessionId;

  @override
  int get hashCode => Object.hash(userId, companyId, membershipId, sessionId);

  @override
  String toString() =>
      'NexaBizAuthorizationSubject(userId: $userId, companyId: $companyId, membershipId: $membershipId, sessionId: <redacted>)';
}

