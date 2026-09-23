import '../../company/nexabiz_company_scope.dart';
import '../../permissions/nexabiz_permission_intent.dart';
import '../../roles/nexabiz_role_id.dart';
import '../nexabiz_membership_id.dart';
import 'nexabiz_authorization_administration_models.dart';

/// Domain-facing reads for company-scoped authorization administration.
///
/// Every query is tenant-explicit and returns domain projections rather than
/// persistence rows. Implementations must reject cross-company targets.
abstract interface class NexaBizAuthorizationAdministrationQueryStore {
  Future<NexaBizCompanyRoleDetails> readCompanyRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
  });

  Future<NexaBizAuthorizationAdministrationPage<NexaBizCompanyRoleSummary>>
  listCompanyRoles({
    required NexaBizCompanyId companyId,
    required NexaBizAuthorizationAdministrationPageRequest page,
    NexaBizCompanyRoleFilter? filter,
  });

  Future<
    NexaBizAuthorizationAdministrationPage<NexaBizRolePermissionAssignment>
  >
  listRolePermissions({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizAuthorizationAdministrationPageRequest page,
  });

  Future<
    NexaBizAuthorizationAdministrationPage<NexaBizMembershipRoleAssignment>
  >
  listMembershipRoles({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
    required NexaBizAuthorizationAdministrationPageRequest page,
  });

  Future<
    NexaBizAuthorizationAdministrationPage<NexaBizMembershipRoleAssignment>
  >
  listRoleMemberships({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizAuthorizationAdministrationPageRequest page,
  });

  Future<NexaBizMembershipEffectivePermissionInfo>
  inspectMembershipEffectivePermissions({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
  });

  /// Lists active company memberships eligible for assignment to [roleId],
  /// excluding members already assigned to the role.
  Future<NexaBizAuthorizationAdministrationPage<NexaBizAssignableMembership>>
  listAssignableMembershipsForRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizAuthorizationAdministrationPageRequest page,
    String? search,
  });
}

/// Atomic company-scoped mutations for authorization administration.
///
/// Each method must begin and finish its validation and write in one database
/// transaction. A successful return means the transaction committed. The
/// application UseCase may notify authorization invalidation only afterwards.
abstract interface class NexaBizAuthorizationAdministrationMutationStore {
  /// Creates a custom role. Duplicate keys or case-insensitive display names
  /// are typed conflicts rather than storage exceptions.
  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  createCompanyRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizRoleMetadata metadata,
  });

  /// Updates metadata only. Role identity, key, scope, and built-in status are
  /// immutable and therefore absent from this API.
  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  updateCompanyRoleMetadata({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizRoleMetadata metadata,
  });

  /// Deletes only a custom role with no membership assignments. Permission
  /// assignments are removed explicitly in the same transaction.
  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  deleteCompanyRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
  });

  /// Idempotent: an existing grant returns an unchanged commit result.
  /// Application administration cannot change built-in role grants.
  Future<
    NexaBizAuthorizationAdministrationMutationResult<
      NexaBizRolePermissionAssignment
    >
  >
  grantPermissionToRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizPermissionId permissionId,
  });

  /// Idempotent: a missing grant returns an unchanged commit result. Revoking
  /// from a protected built-in role is rejected before any mutation.
  Future<
    NexaBizAuthorizationAdministrationMutationResult<
      NexaBizRolePermissionAssignment
    >
  >
  revokePermissionFromRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizPermissionId permissionId,
  });

  /// Idempotent: an existing assignment returns an unchanged commit result.
  /// New assignments require an active company, membership, and user.
  Future<
    NexaBizAuthorizationAdministrationMutationResult<
      NexaBizMembershipRoleAssignment
    >
  >
  assignRoleToMembership({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
    required NexaBizRoleId roleId,
  });

  /// Idempotent for a missing assignment. Last-active-owner validation and the
  /// deletion must execute atomically to prevent concurrent owner removal.
  Future<
    NexaBizAuthorizationAdministrationMutationResult<
      NexaBizMembershipRoleAssignment
    >
  >
  unassignRoleFromMembership({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
    required NexaBizRoleId roleId,
  });
}

abstract interface class NexaBizAuthorizationAdministrationStore
    implements
        NexaBizAuthorizationAdministrationQueryStore,
        NexaBizAuthorizationAdministrationMutationStore {}
