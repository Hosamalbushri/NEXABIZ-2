// ignore_for_file: prefer_initializing_formals

import '../../../../core/authorization/administration/nexabiz_authorization_administration_errors.dart';
import '../../../../core/authorization/administration/nexabiz_authorization_administration_models.dart';
import '../../../../core/authorization/administration/nexabiz_authorization_administration_permissions.dart';
import '../../../../core/authorization/administration/nexabiz_authorization_administration_store.dart';
import '../../../../core/authorization/nexabiz_authorization_context.dart';
import '../../../../core/authorization/nexabiz_permission_guard.dart';
import '../../../../core/company/nexabiz_company_scope.dart';
import '../../../../core/roles/nexabiz_role_id.dart';
import '../../../../core/roles/nexabiz_role_scope.dart';
import '../nexabiz_authorization_invalidation_signal.dart';

/// Application UseCase for creating a custom company-scoped role.
///
/// Security Enforcement Pipeline:
/// `Caller -> NexaBizCompanyAuthorizationContext -> NexaBizPermissionGuard -> Store -> Commit -> InvalidationSignal`
final class CreateCompanyRoleUseCase {
  const CreateCompanyRoleUseCase({
    required NexaBizPermissionGuard permissionGuard,
    required NexaBizAuthorizationAdministrationMutationStore mutationStore,
    required NexaBizAuthorizationInvalidationSignal invalidationSignal,
  }) : _guard = permissionGuard,
       _store = mutationStore,
       _invalidationSignal = invalidationSignal;

  final NexaBizPermissionGuard _guard;
  final NexaBizAuthorizationAdministrationMutationStore _store;
  final NexaBizAuthorizationInvalidationSignal _invalidationSignal;

  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  execute({
    required NexaBizCompanyAuthorizationContext context,
    required NexaBizRoleId roleId,
    required NexaBizRoleMetadata metadata,
    NexaBizCompanyId? targetCompanyId,
  }) async {
    // 1. Tenant binding verification before any authorization or storage call
    if (targetCompanyId != null && targetCompanyId != context.companyId) {
      throw NexaBizAuthorizationCrossCompanyException(
        expectedCompanyId: context.companyId,
        actualCompanyId: targetCompanyId,
      );
    }

    if (roleId.scope != NexaBizRoleScope.company) {
      throw ArgumentError.value(
        roleId,
        'roleId',
        'Custom roles must be company-scoped.',
      );
    }

    // 2. Authoritative Permission Guard: Fail-Closed before any side effect
    await _guard.requirePermission(
      context: context,
      permissionId: NexaBizAuthorizationAdministrationPermissions.roleManage,
    );

    // 3. Transactional Store Mutation
    final result = await _store.createCompanyRole(
      companyId: context.companyId,
      roleId: roleId,
      metadata: metadata,
    );

    // 4. Post-Commit Invalidation: notify only if state genuinely changed
    if (result.changed) {
      _invalidationSignal.notifyAuthorizationChanged();
    }

    return result;
  }
}
