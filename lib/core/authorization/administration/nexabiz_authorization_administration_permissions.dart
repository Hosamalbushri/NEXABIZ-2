import '../../permissions/nexabiz_permission_intent.dart';

/// Canonical permission identities used by authorization administration.
///
/// These identities become declared permissions only when contributed by the
/// owning Permissions capability and accepted by the capability registry.
abstract final class NexaBizAuthorizationAdministrationPermissions {
  static final catalogView = NexaBizPermissionId('permissions.catalog.view');
  static final policyReview = NexaBizPermissionId('permissions.policy.review');
  static final roleManage = NexaBizPermissionId('permissions.role.manage');
  static final policyManage = NexaBizPermissionId('permissions.policy.manage');
  static final assignmentManage = NexaBizPermissionId(
    'permissions.assignment.manage',
  );

  static final List<NexaBizPermissionId> declaredPermissionIds =
      List.unmodifiable([
        catalogView,
        policyReview,
        roleManage,
        policyManage,
        assignmentManage,
      ]);
}

/// Planned application operations and their least-privilege requirements.
enum NexaBizAuthorizationAdministrationOperation {
  listPermissionCatalog,
  readRole,
  listRoles,
  listRolePermissions,
  listMembershipRoles,
  listRoleMemberships,
  listAssignableMemberships,
  inspectEffectivePermissions,
  createRole,
  updateRoleMetadata,
  deleteRole,
  grantRolePermission,
  revokeRolePermission,
  assignMembershipRole,
  unassignMembershipRole;

  NexaBizPermissionId get requiredPermission => switch (this) {
    listPermissionCatalog =>
      NexaBizAuthorizationAdministrationPermissions.catalogView,
    readRole ||
    listRoles ||
    listRolePermissions ||
    listMembershipRoles ||
    listRoleMemberships ||
    inspectEffectivePermissions =>
      NexaBizAuthorizationAdministrationPermissions.policyReview,
    listAssignableMemberships ||
    assignMembershipRole ||
    unassignMembershipRole =>
      NexaBizAuthorizationAdministrationPermissions.assignmentManage,
    createRole ||
    updateRoleMetadata ||
    deleteRole => NexaBizAuthorizationAdministrationPermissions.roleManage,
    grantRolePermission || revokeRolePermission =>
      NexaBizAuthorizationAdministrationPermissions.policyManage,
  };

  bool get requiresMutation => switch (this) {
    listPermissionCatalog ||
    readRole ||
    listRoles ||
    listRolePermissions ||
    listMembershipRoles ||
    listRoleMemberships ||
    listAssignableMemberships ||
    inspectEffectivePermissions => false,
    _ => true,
  };
}
