import '../../core/authorization/administration/nexabiz_authorization_administration_store.dart';
import '../../core/authorization/nexabiz_permission_catalog.dart';
import '../../core/authorization/nexabiz_permission_guard.dart';
import 'nexabiz_authorization_invalidation_signal.dart';
import 'use_cases/assign_role_to_membership_use_case.dart';
import 'use_cases/create_company_role_use_case.dart';
import 'use_cases/delete_company_role_use_case.dart';
import 'use_cases/get_company_role_use_case.dart';
import 'use_cases/grant_permission_to_role_use_case.dart';
import 'use_cases/inspect_membership_effective_permissions_use_case.dart';
import 'use_cases/list_assignable_memberships_for_role_use_case.dart';
import 'use_cases/list_company_roles_use_case.dart';
import 'use_cases/list_declared_permission_catalog_use_case.dart';
import 'use_cases/list_membership_roles_use_case.dart';
import 'use_cases/list_memberships_assigned_to_role_use_case.dart';
import 'use_cases/list_role_permissions_use_case.dart';
import 'use_cases/revoke_permission_from_role_use_case.dart';
import 'use_cases/unassign_role_from_membership_use_case.dart';
import 'use_cases/update_company_role_metadata_use_case.dart';

/// Immutable Application facade grouping all authorization administration UseCases.
///
/// This serves as the single application-layer boundary for future presentation
/// features without exposing the underlying Drift persistence stores directly.
final class NexaBizAuthorizationAdministration {
  const NexaBizAuthorizationAdministration({
    required this.createCompanyRole,
    required this.updateCompanyRoleMetadata,
    required this.deleteCompanyRole,
    required this.assignRoleToMembership,
    required this.unassignRoleFromMembership,
    required this.grantPermissionToRole,
    required this.revokePermissionFromRole,
    required this.getCompanyRole,
    required this.listCompanyRoles,
    required this.listRolePermissions,
    required this.listMembershipRoles,
    required this.listMembershipsAssignedToRole,
    required this.listAssignableMembershipsForRole,
    required this.inspectMembershipEffectivePermissions,
    required this.listDeclaredPermissionCatalog,
  });

  /// Factory constructing all UseCases with the canonical security pipeline.
  factory NexaBizAuthorizationAdministration.create({
    required NexaBizPermissionGuard permissionGuard,
    required NexaBizAuthorizationAdministrationQueryStore queryStore,
    required NexaBizAuthorizationAdministrationMutationStore mutationStore,
    required NexaBizAuthorizationInvalidationSignal invalidationSignal,
    required NexaBizPermissionCatalog permissionCatalog,
  }) {
    return NexaBizAuthorizationAdministration(
      createCompanyRole: CreateCompanyRoleUseCase(
        permissionGuard: permissionGuard,
        mutationStore: mutationStore,
        invalidationSignal: invalidationSignal,
      ),
      updateCompanyRoleMetadata: UpdateCompanyRoleMetadataUseCase(
        permissionGuard: permissionGuard,
        mutationStore: mutationStore,
        invalidationSignal: invalidationSignal,
      ),
      deleteCompanyRole: DeleteCompanyRoleUseCase(
        permissionGuard: permissionGuard,
        mutationStore: mutationStore,
        invalidationSignal: invalidationSignal,
      ),
      assignRoleToMembership: AssignRoleToMembershipUseCase(
        permissionGuard: permissionGuard,
        mutationStore: mutationStore,
        invalidationSignal: invalidationSignal,
      ),
      unassignRoleFromMembership: UnassignRoleFromMembershipUseCase(
        permissionGuard: permissionGuard,
        mutationStore: mutationStore,
        invalidationSignal: invalidationSignal,
      ),
      grantPermissionToRole: GrantPermissionToRoleUseCase(
        permissionGuard: permissionGuard,
        mutationStore: mutationStore,
        invalidationSignal: invalidationSignal,
      ),
      revokePermissionFromRole: RevokePermissionFromRoleUseCase(
        permissionGuard: permissionGuard,
        mutationStore: mutationStore,
        invalidationSignal: invalidationSignal,
      ),
      getCompanyRole: GetCompanyRoleUseCase(
        permissionGuard: permissionGuard,
        queryStore: queryStore,
      ),
      listCompanyRoles: ListCompanyRolesUseCase(
        permissionGuard: permissionGuard,
        queryStore: queryStore,
      ),
      listRolePermissions: ListRolePermissionsUseCase(
        permissionGuard: permissionGuard,
        queryStore: queryStore,
      ),
      listMembershipRoles: ListMembershipRolesUseCase(
        permissionGuard: permissionGuard,
        queryStore: queryStore,
      ),
      listMembershipsAssignedToRole: ListMembershipsAssignedToRoleUseCase(
        permissionGuard: permissionGuard,
        queryStore: queryStore,
      ),
      listAssignableMembershipsForRole: ListAssignableMembershipsForRoleUseCase(
        permissionGuard: permissionGuard,
        queryStore: queryStore,
      ),
      inspectMembershipEffectivePermissions:
          InspectMembershipEffectivePermissionsUseCase(
            permissionGuard: permissionGuard,
            queryStore: queryStore,
          ),
      listDeclaredPermissionCatalog: ListDeclaredPermissionCatalogUseCase(
        permissionGuard: permissionGuard,
        permissionCatalog: permissionCatalog,
      ),
    );
  }

  // Mutation UseCases
  final CreateCompanyRoleUseCase createCompanyRole;
  final UpdateCompanyRoleMetadataUseCase updateCompanyRoleMetadata;
  final DeleteCompanyRoleUseCase deleteCompanyRole;
  final AssignRoleToMembershipUseCase assignRoleToMembership;
  final UnassignRoleFromMembershipUseCase unassignRoleFromMembership;
  final GrantPermissionToRoleUseCase grantPermissionToRole;
  final RevokePermissionFromRoleUseCase revokePermissionFromRole;

  // Query UseCases
  final GetCompanyRoleUseCase getCompanyRole;
  final ListCompanyRolesUseCase listCompanyRoles;
  final ListRolePermissionsUseCase listRolePermissions;
  final ListMembershipRolesUseCase listMembershipRoles;
  final ListMembershipsAssignedToRoleUseCase listMembershipsAssignedToRole;
  final ListAssignableMembershipsForRoleUseCase
  listAssignableMembershipsForRole;
  final InspectMembershipEffectivePermissionsUseCase
  inspectMembershipEffectivePermissions;
  final ListDeclaredPermissionCatalogUseCase listDeclaredPermissionCatalog;
}
