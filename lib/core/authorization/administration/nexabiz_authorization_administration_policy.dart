import '../../company/nexabiz_company_scope.dart';
import '../../permissions/nexabiz_permission_intent.dart';
import '../../roles/nexabiz_role_id.dart';
import '../nexabiz_membership_id.dart';
import '../nexabiz_permission_catalog.dart';
import 'nexabiz_authorization_administration_errors.dart';
import 'nexabiz_authorization_administration_models.dart';

/// Single domain authority for known built-in company role identities.
abstract final class NexaBizBuiltInCompanyRoles {
  static final companyOwner = NexaBizRoleId('company.owner');

  static final Set<NexaBizRoleId> values = Set.unmodifiable({companyOwner});

  static bool contains(NexaBizRoleId roleId) => values.contains(roleId);
}

/// Pure policy for company-role safety invariants.
final class NexaBizCompanyRoleAdministrationPolicy {
  const NexaBizCompanyRoleAdministrationPolicy();

  NexaBizCompanyRoleKind classifyRole({
    required NexaBizRoleId roleId,
    required bool persistedIsBuiltIn,
  }) {
    ensureCompanyRoleId(roleId);
    return persistedIsBuiltIn || NexaBizBuiltInCompanyRoles.contains(roleId)
        ? NexaBizCompanyRoleKind.builtIn
        : NexaBizCompanyRoleKind.custom;
  }

  void ensureCompanyRoleId(NexaBizRoleId roleId) {
    if (!roleId.scope.isCompany) {
      throw ArgumentError.value(
        roleId,
        'roleId',
        'Authorization administration supports company roles only.',
      );
    }
  }

  void ensureCreatableCustomRole(NexaBizRoleId roleId) {
    ensureCompanyRoleId(roleId);
    if (NexaBizBuiltInCompanyRoles.contains(roleId)) {
      throw NexaBizBuiltInRoleProtectedException(
        roleId: roleId,
        action: NexaBizBuiltInRoleProtectedAction.create,
      );
    }
  }

  void ensureMetadataMutable({
    required NexaBizRoleId roleId,
    required bool persistedIsBuiltIn,
  }) {
    if (classifyRole(roleId: roleId, persistedIsBuiltIn: persistedIsBuiltIn) ==
        NexaBizCompanyRoleKind.builtIn) {
      throw NexaBizBuiltInRoleProtectedException(
        roleId: roleId,
        action: NexaBizBuiltInRoleProtectedAction.updateMetadata,
      );
    }
  }

  void ensureDeletable({
    required NexaBizRoleId roleId,
    required bool persistedIsBuiltIn,
    required int membershipAssignmentCount,
  }) {
    if (classifyRole(roleId: roleId, persistedIsBuiltIn: persistedIsBuiltIn) ==
        NexaBizCompanyRoleKind.builtIn) {
      throw NexaBizBuiltInRoleProtectedException(
        roleId: roleId,
        action: NexaBizBuiltInRoleProtectedAction.delete,
      );
    }
    if (membershipAssignmentCount > 0) {
      throw NexaBizAuthorizationAdministrationConflictException(
        type: NexaBizAuthorizationAdministrationConflictType
            .roleHasMembershipAssignments,
        roleId: roleId,
      );
    }
  }

  void ensurePermissionRevocable({
    required NexaBizRoleId roleId,
    required bool persistedIsBuiltIn,
  }) {
    if (classifyRole(roleId: roleId, persistedIsBuiltIn: persistedIsBuiltIn) ==
        NexaBizCompanyRoleKind.builtIn) {
      throw NexaBizBuiltInRoleProtectedException(
        roleId: roleId,
        action: NexaBizBuiltInRoleProtectedAction.revokePermission,
      );
    }
  }

  void ensurePermissionGrantable({
    required NexaBizRoleId roleId,
    required bool persistedIsBuiltIn,
  }) {
    if (classifyRole(roleId: roleId, persistedIsBuiltIn: persistedIsBuiltIn) ==
        NexaBizCompanyRoleKind.builtIn) {
      throw NexaBizBuiltInRoleProtectedException(
        roleId: roleId,
        action: NexaBizBuiltInRoleProtectedAction.grantPermission,
      );
    }
  }

  void ensureOwnerUnassignmentLeavesActiveOwner({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required int activeOwnerCountAfter,
  }) {
    ensureCompanyRoleId(roleId);
    if (roleId == NexaBizBuiltInCompanyRoles.companyOwner &&
        activeOwnerCountAfter < 1) {
      throw NexaBizLastOwnerProtectedException(companyId);
    }
  }

  void ensureSameCompany({
    required NexaBizCompanyId expectedCompanyId,
    required NexaBizCompanyId actualCompanyId,
  }) {
    if (expectedCompanyId != actualCompanyId) {
      throw NexaBizAuthorizationCrossCompanyException(
        expectedCompanyId: expectedCompanyId,
        actualCompanyId: actualCompanyId,
      );
    }
  }

  void ensureAssignmentEligibility({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
    required bool companyIsActive,
    required bool membershipIsActive,
    required bool userIsActive,
  }) {
    if (!companyIsActive) {
      throw NexaBizCompanyIneligibleException(companyId);
    }
    if (!membershipIsActive) {
      throw NexaBizMembershipIneligibleException(
        membershipId: membershipId,
        reason: NexaBizMembershipIneligibilityReason.inactiveMembership,
      );
    }
    if (!userIsActive) {
      throw NexaBizMembershipIneligibleException(
        membershipId: membershipId,
        reason: NexaBizMembershipIneligibilityReason.inactiveUser,
      );
    }
  }
}

/// Validates grant targets against the locked capability permission catalog.
final class NexaBizAuthorizationAdministrationPermissionPolicy {
  const NexaBizAuthorizationAdministrationPermissionPolicy(this._catalog);

  final NexaBizPermissionCatalog _catalog;

  void ensureDeclared(NexaBizPermissionId permissionId) {
    if (!_catalog.isDeclared(permissionId)) {
      throw NexaBizUndeclaredPermissionException(permissionId);
    }
  }
}
