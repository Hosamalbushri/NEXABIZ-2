import '../../company/nexabiz_company_scope.dart';
import '../../permissions/nexabiz_permission_intent.dart';
import '../../roles/nexabiz_role_id.dart';
import '../nexabiz_membership_id.dart';

/// Stable error codes exposed by company authorization administration contracts.
enum NexaBizAuthorizationAdministrationErrorCode {
  roleNotFound,
  membershipNotFound,
  crossCompanyMismatch,
  builtInRoleProtected,
  lastOwnerProtected,
  undeclaredPermission,
  conflict,
  membershipIneligible,
  companyIneligible,
  invalidRoleDisplayName,
}

/// Base type for expected authorization-administration domain failures.
sealed class NexaBizAuthorizationAdministrationException implements Exception {
  const NexaBizAuthorizationAdministrationException();

  NexaBizAuthorizationAdministrationErrorCode get code;
}

final class NexaBizRoleNotFoundException
    extends NexaBizAuthorizationAdministrationException {
  const NexaBizRoleNotFoundException({
    required this.companyId,
    required this.roleId,
  });

  final NexaBizCompanyId companyId;
  final NexaBizRoleId roleId;

  @override
  NexaBizAuthorizationAdministrationErrorCode get code =>
      NexaBizAuthorizationAdministrationErrorCode.roleNotFound;
}

final class NexaBizMembershipNotFoundException
    extends NexaBizAuthorizationAdministrationException {
  const NexaBizMembershipNotFoundException({
    required this.companyId,
    required this.membershipId,
  });

  final NexaBizCompanyId companyId;
  final NexaBizMembershipId membershipId;

  @override
  NexaBizAuthorizationAdministrationErrorCode get code =>
      NexaBizAuthorizationAdministrationErrorCode.membershipNotFound;
}

final class NexaBizAuthorizationCrossCompanyException
    extends NexaBizAuthorizationAdministrationException {
  const NexaBizAuthorizationCrossCompanyException({
    required this.expectedCompanyId,
    required this.actualCompanyId,
  });

  final NexaBizCompanyId expectedCompanyId;
  final NexaBizCompanyId actualCompanyId;

  @override
  NexaBizAuthorizationAdministrationErrorCode get code =>
      NexaBizAuthorizationAdministrationErrorCode.crossCompanyMismatch;
}

enum NexaBizBuiltInRoleProtectedAction {
  create,
  updateMetadata,
  delete,
  grantPermission,
  revokePermission,
}

final class NexaBizBuiltInRoleProtectedException
    extends NexaBizAuthorizationAdministrationException {
  const NexaBizBuiltInRoleProtectedException({
    required this.roleId,
    required this.action,
  });

  final NexaBizRoleId roleId;
  final NexaBizBuiltInRoleProtectedAction action;

  @override
  NexaBizAuthorizationAdministrationErrorCode get code =>
      NexaBizAuthorizationAdministrationErrorCode.builtInRoleProtected;
}

final class NexaBizLastOwnerProtectedException
    extends NexaBizAuthorizationAdministrationException {
  const NexaBizLastOwnerProtectedException(this.companyId);

  final NexaBizCompanyId companyId;

  @override
  NexaBizAuthorizationAdministrationErrorCode get code =>
      NexaBizAuthorizationAdministrationErrorCode.lastOwnerProtected;
}

final class NexaBizUndeclaredPermissionException
    extends NexaBizAuthorizationAdministrationException {
  const NexaBizUndeclaredPermissionException(this.permissionId);

  final NexaBizPermissionId permissionId;

  @override
  NexaBizAuthorizationAdministrationErrorCode get code =>
      NexaBizAuthorizationAdministrationErrorCode.undeclaredPermission;
}

enum NexaBizAuthorizationAdministrationConflictType {
  duplicateRoleKey,
  duplicateRoleDisplayName,
  roleHasMembershipAssignments,
}

final class NexaBizAuthorizationAdministrationConflictException
    extends NexaBizAuthorizationAdministrationException {
  const NexaBizAuthorizationAdministrationConflictException({
    required this.type,
    this.roleId,
  });

  final NexaBizAuthorizationAdministrationConflictType type;
  final NexaBizRoleId? roleId;

  @override
  NexaBizAuthorizationAdministrationErrorCode get code =>
      NexaBizAuthorizationAdministrationErrorCode.conflict;
}

enum NexaBizMembershipIneligibilityReason { inactiveMembership, inactiveUser }

final class NexaBizMembershipIneligibleException
    extends NexaBizAuthorizationAdministrationException {
  const NexaBizMembershipIneligibleException({
    required this.membershipId,
    required this.reason,
  });

  final NexaBizMembershipId membershipId;
  final NexaBizMembershipIneligibilityReason reason;

  @override
  NexaBizAuthorizationAdministrationErrorCode get code =>
      NexaBizAuthorizationAdministrationErrorCode.membershipIneligible;
}

final class NexaBizCompanyIneligibleException
    extends NexaBizAuthorizationAdministrationException {
  const NexaBizCompanyIneligibleException(this.companyId);

  final NexaBizCompanyId companyId;

  @override
  NexaBizAuthorizationAdministrationErrorCode get code =>
      NexaBizAuthorizationAdministrationErrorCode.companyIneligible;
}

enum NexaBizRoleDisplayNameValidationReason { empty, tooLong }

final class NexaBizInvalidRoleDisplayNameException
    extends NexaBizAuthorizationAdministrationException {
  const NexaBizInvalidRoleDisplayNameException(this.reason);

  final NexaBizRoleDisplayNameValidationReason reason;

  @override
  NexaBizAuthorizationAdministrationErrorCode get code =>
      NexaBizAuthorizationAdministrationErrorCode.invalidRoleDisplayName;
}
