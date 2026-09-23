import '../../../../core/authorization/administration/nexabiz_authorization_administration_errors.dart';
import '../../../../core/authorization/administration/nexabiz_authorization_administration_models.dart';
import '../../../../core/authorization/administration/nexabiz_authorization_administration_permissions.dart';
import '../../../../core/authorization/administration/nexabiz_authorization_administration_store.dart';
import '../../../../core/authorization/nexabiz_authorization_context.dart';
import '../../../../core/authorization/nexabiz_permission_guard.dart';
import '../../../../core/company/nexabiz_company_scope.dart';
import '../../../../core/roles/nexabiz_role_id.dart';

/// Application UseCase for reading details of a company role.
///
/// Security Enforcement Pipeline:
/// `Caller -> NexaBizCompanyAuthorizationContext -> NexaBizPermissionGuard -> QueryStore`
final class GetCompanyRoleUseCase {
  const GetCompanyRoleUseCase({
    required NexaBizPermissionGuard permissionGuard,
    required NexaBizAuthorizationAdministrationQueryStore queryStore,
  }) : _guard = permissionGuard,
       _store = queryStore;

  final NexaBizPermissionGuard _guard;
  final NexaBizAuthorizationAdministrationQueryStore _store;

  Future<NexaBizCompanyRoleDetails> execute({
    required NexaBizCompanyAuthorizationContext context,
    required NexaBizRoleId roleId,
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
      permissionId: NexaBizAuthorizationAdministrationPermissions.policyReview,
    );

    // 3. Query Store Execution
    return await _store.readCompanyRole(
      companyId: context.companyId,
      roleId: roleId,
    );
  }
}
