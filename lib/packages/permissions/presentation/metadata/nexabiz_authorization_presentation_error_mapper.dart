import '../../../../core/authorization/administration/nexabiz_authorization_administration_errors.dart';
import '../../../../core/authorization/administration/nexabiz_authorization_administration_models.dart';
import '../../../../core/authorization/nexabiz_permission_denied_exception.dart';
import '../../../../l10n/app_localizations.dart';

/// Centralized presentation error mapper for Authorization Administration.
///
/// Maps strongly-typed domain, persistence, and authorization application errors
/// to localized, actionable user-facing messages without parsing exception strings.
final class NexaBizAuthorizationPresentationErrorMapper {
  const NexaBizAuthorizationPresentationErrorMapper();

  /// Maps [error] into a localized message using [l10n].
  String mapError({required Object error, required AppLocalizations l10n}) {
    return switch (error) {
      final NexaBizRoleNotFoundException _ => l10n.authAdminErrorRoleNotFound,

      final NexaBizMembershipNotFoundException _ =>
        l10n.authAdminErrorMembershipNotFound,

      final NexaBizAuthorizationCrossCompanyException _ =>
        l10n.authAdminErrorCrossCompany,

      final NexaBizBuiltInRoleProtectedException e => switch (e.action) {
        NexaBizBuiltInRoleProtectedAction.create =>
          l10n.authAdminErrorBuiltInCreate,
        NexaBizBuiltInRoleProtectedAction.updateMetadata =>
          l10n.authAdminErrorBuiltInUpdate,
        NexaBizBuiltInRoleProtectedAction.delete =>
          l10n.authAdminErrorBuiltInDelete,
        NexaBizBuiltInRoleProtectedAction.grantPermission ||
        NexaBizBuiltInRoleProtectedAction.revokePermission =>
          l10n.authAdminErrorBuiltInPermissions,
      },

      final NexaBizLastOwnerProtectedException _ =>
        l10n.authAdminErrorLastOwnerProtected,

      final NexaBizUndeclaredPermissionException _ =>
        l10n.authAdminErrorUndeclaredPermission,

      final NexaBizAuthorizationAdministrationConflictException e =>
        switch (e.type) {
          NexaBizAuthorizationAdministrationConflictType.duplicateRoleKey =>
            l10n.authAdminErrorDuplicateRoleKey,
          NexaBizAuthorizationAdministrationConflictType
              .duplicateRoleDisplayName =>
            l10n.authAdminErrorDuplicateRoleDisplayName,
          NexaBizAuthorizationAdministrationConflictType
              .roleHasMembershipAssignments =>
            l10n.authAdminErrorRoleHasAssignments,
        },

      final NexaBizMembershipIneligibleException e => switch (e.reason) {
        NexaBizMembershipIneligibilityReason.inactiveMembership =>
          l10n.authAdminErrorMembershipInactive,
        NexaBizMembershipIneligibilityReason.inactiveUser =>
          l10n.authAdminErrorUserInactive,
      },

      final NexaBizCompanyIneligibleException _ =>
        l10n.authAdminErrorCompanyInactive,

      final NexaBizInvalidRoleDisplayNameException e => switch (e.reason) {
        NexaBizRoleDisplayNameValidationReason.empty =>
          l10n.authAdminErrorRoleNameEmpty,
        NexaBizRoleDisplayNameValidationReason.tooLong =>
          l10n.authAdminErrorRoleNameTooLong(NexaBizRoleDisplayName.maxLength),
      },

      final NexaBizPermissionDeniedException _ =>
        l10n.authAdminErrorPermissionDenied,

      final ArgumentError e when e.name == 'value' || e.name == 'roleId' =>
        l10n.authAdminErrorRoleKeyInvalid,

      _ => l10n.authAdminErrorGeneric,
    };
  }
}
