import '../../../../core/authorization/administration/nexabiz_authorization_administration_errors.dart';
import '../../../../core/authorization/administration/nexabiz_authorization_administration_models.dart';
import '../../../../core/authorization/administration/nexabiz_authorization_administration_permissions.dart';
import '../../../../core/authorization/administration/nexabiz_authorization_administration_store.dart';
import '../../../../core/authorization/nexabiz_authorization_context.dart';
import '../../../../core/authorization/nexabiz_permission_guard.dart';
import '../../../../core/company/nexabiz_company_scope.dart';
import '../../../../core/roles/nexabiz_role_id.dart';

/// Application UseCase for listing assignable memberships for a role.
///
/// Security Enforcement Pipeline:
/// `Caller -> NexaBizCompanyAuthorizationContext -> NexaBizPermissionGuard -> QueryStore`
final class ListAssignableMembershipsForRoleUseCase {
  const ListAssignableMembershipsForRoleUseCase({
    required NexaBizPermissionGuard permissionGuard,
    required NexaBizAuthorizationAdministrationQueryStore queryStore,
  }) : _guard = permissionGuard,
       _store = queryStore;

  final NexaBizPermissionGuard _guard;
  final NexaBizAuthorizationAdministrationQueryStore _store;

  Future<NexaBizAuthorizationAdministrationPage<NexaBizAssignableMembership>>
  execute({
    required NexaBizCompanyAuthorizationContext context,
    required NexaBizRoleId roleId,
    required NexaBizAuthorizationAdministrationPageRequest page,
    String? search,
    NexaBizCompanyId? targetCompanyId,
  }) async {
    // 1. Tenant binding verification before any query
    if (targetCompanyId != null && targetCompanyId != context.companyId) {
      throw NexaBizAuthorizationCrossCompanyException(
        expectedCompanyId: context.companyId,
        actualCompanyId: targetCompanyId,
      );
    }

    // 2. Authoritative Permission Guard: Fail-Closed
    await _guard.requirePermission(
      context: context,
      permissionId:
          NexaBizAuthorizationAdministrationPermissions.assignmentManage,
    );

    // 3. Query Store Execution
    return await _store.listAssignableMembershipsForRole(
      companyId: context.companyId,
      roleId: roleId,
      page: page,
      search: search,
    );
  }
}
