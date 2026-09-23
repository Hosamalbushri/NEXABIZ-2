import '../../../../core/authorization/administration/nexabiz_authorization_administration_permissions.dart';
import '../../../../core/authorization/nexabiz_authorization_context.dart';
import '../../../../core/authorization/nexabiz_permission_catalog.dart';
import '../../../../core/authorization/nexabiz_permission_guard.dart';
import '../../../../core/permissions/nexabiz_permission_intent.dart';

/// Application UseCase for listing the authoritative declared capability permissions.
///
/// Security Enforcement Pipeline:
/// `Caller -> NexaBizCompanyAuthorizationContext -> NexaBizPermissionGuard -> PermissionCatalog`
final class ListDeclaredPermissionCatalogUseCase {
  const ListDeclaredPermissionCatalogUseCase({
    required NexaBizPermissionGuard permissionGuard,
    required NexaBizPermissionCatalog permissionCatalog,
  }) : _guard = permissionGuard,
       _catalog = permissionCatalog;

  final NexaBizPermissionGuard _guard;
  final NexaBizPermissionCatalog _catalog;

  Future<List<NexaBizPermissionId>> execute({
    required NexaBizCompanyAuthorizationContext context,
  }) async {
    // 1. Authoritative Permission Guard: Fail-Closed
    await _guard.requirePermission(
      context: context,
      permissionId: NexaBizAuthorizationAdministrationPermissions.catalogView,
    );

    // 2. Return sorted immutable list of declared capability permissions
    final permissions = _catalog.declaredPermissions.toList(growable: false)
      ..sort((a, b) => a.value.compareTo(b.value));
    return List.unmodifiable(permissions);
  }
}
