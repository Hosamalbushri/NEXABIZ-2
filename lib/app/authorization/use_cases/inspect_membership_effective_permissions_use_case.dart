import '../../../../core/authorization/administration/nexabiz_authorization_administration_errors.dart';
import '../../../../core/authorization/administration/nexabiz_authorization_administration_models.dart';
import '../../../../core/authorization/administration/nexabiz_authorization_administration_permissions.dart';
import '../../../../core/authorization/administration/nexabiz_authorization_administration_store.dart';
import '../../../../core/authorization/nexabiz_authorization_context.dart';
import '../../../../core/authorization/nexabiz_membership_id.dart';
import '../../../../core/authorization/nexabiz_permission_guard.dart';
import '../../../../core/company/nexabiz_company_scope.dart';

/// Application UseCase for inspecting effective permissions of a membership.
///
/// Security Enforcement Pipeline:
/// `Caller -> NexaBizCompanyAuthorizationContext -> NexaBizPermissionGuard -> QueryStore`
final class InspectMembershipEffectivePermissionsUseCase {
  const InspectMembershipEffectivePermissionsUseCase({
    required NexaBizPermissionGuard permissionGuard,
    required NexaBizAuthorizationAdministrationQueryStore queryStore,
  }) : _guard = permissionGuard,
       _store = queryStore;

  final NexaBizPermissionGuard _guard;
  final NexaBizAuthorizationAdministrationQueryStore _store;

  Future<NexaBizMembershipEffectivePermissionInfo> execute({
    required NexaBizCompanyAuthorizationContext context,
    required NexaBizMembershipId membershipId,
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
    return await _store.inspectMembershipEffectivePermissions(
      companyId: context.companyId,
      membershipId: membershipId,
    );
  }
}
