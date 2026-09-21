import '../company/nexabiz_company_scope.dart';
import '../permissions/nexabiz_permission_intent.dart';
import '../roles/nexabiz_role_id.dart';
import '../session/nexabiz_session.dart';
import 'nexabiz_membership_id.dart';

/// Immutable, atomic authorization snapshot of a specific company membership.
///
/// Contains the technical security facts (membership, company, user, roles, permissions)
/// loaded in a single consistent database read.
final class NexaBizMembershipAuthorizationSnapshot {
  const NexaBizMembershipAuthorizationSnapshot({
    required this.membershipId,
    required this.companyId,
    required this.userId,
    required this.membershipStatus,
    required this.companyStatus,
    required this.userStatus,
    required this.roleIds,
    required this.permissionIds,
  });

  final NexaBizMembershipId membershipId;
  final NexaBizCompanyId companyId;
  final NexaBizUserId userId;
  final String membershipStatus;
  final String companyStatus;
  final String userStatus;

  /// Canonical role identities assigned to this membership.
  final Set<NexaBizRoleId> roleIds;

  /// Deduplicated union of all permissions granted across assigned roles.
  final Set<NexaBizPermissionId> permissionIds;

  bool get isActive =>
      membershipStatus == 'active' &&
      companyStatus == 'active' &&
      userStatus == 'active';

  /// Whether the membership context is active and eligible for authorization.
  bool get isEligibleForAuthorization => isActive;

  /// Effective roles if eligible for authorization; otherwise empty set (fail-closed).
  Set<NexaBizRoleId> get effectiveRoles =>
      isEligibleForAuthorization ? roleIds : const <NexaBizRoleId>{};

  /// Effective permissions if eligible for authorization; otherwise empty set (fail-closed).
  Set<NexaBizPermissionId> get effectivePermissions =>
      isEligibleForAuthorization ? permissionIds : const <NexaBizPermissionId>{};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexaBizMembershipAuthorizationSnapshot &&
          membershipId == other.membershipId &&
          companyId == other.companyId &&
          userId == other.userId &&
          membershipStatus == other.membershipStatus &&
          companyStatus == other.companyStatus &&
          userStatus == other.userStatus &&
          _setEquals(roleIds, other.roleIds) &&
          _setEquals(permissionIds, other.permissionIds);

  @override
  int get hashCode => Object.hash(
        membershipId,
        companyId,
        userId,
        membershipStatus,
        companyStatus,
        userStatus,
        Object.hashAll(roleIds),
        Object.hashAll(permissionIds),
      );

  @override
  String toString() =>
      'NexaBizMembershipAuthorizationSnapshot(membershipId: $membershipId, companyId: $companyId, userId: $userId, roles: ${roleIds.length}, permissions: ${permissionIds.length})';

  static bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}
