import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/authorization/app_permission_scope.dart';
import 'package:nexabiz/app/authorization/nexabiz_authorization_administration.dart';
import 'package:nexabiz/app/authorization/nexabiz_authorization_invalidation_signal.dart';
import 'package:nexabiz/app/localization/app_locale_controller.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_models.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_errors.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_permissions.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_store.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_context.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_id.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_catalog.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_evaluator.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_guard.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_denied_exception.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/roles/nexabiz_role_id.dart';
import 'package:nexabiz/core/roles/nexabiz_role_scope.dart';
import 'package:nexabiz/core/session/core_session_controller.dart';
import 'package:nexabiz/core/session/nexabiz_session.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:nexabiz/l10n/app_localizations.dart';
import 'package:nexabiz/packages/permissions/presentation/controllers/roles_administration_controller.dart';
import 'package:nexabiz/packages/permissions/presentation/metadata/nexabiz_permission_presentation_resolver.dart';
import 'package:nexabiz/packages/permissions/presentation/roles_screen.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Test Doubles
// ---------------------------------------------------------------------------

final class _FakePermissionGuard implements NexaBizPermissionGuard {
  const _FakePermissionGuard();
  @override
  Future<void> requirePermission({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  }) async {}
}

class _FakePermissionEvaluator implements NexaBizPermissionEvaluator {
  bool allowRoleManagement = true;
  bool allowPolicyManagement = true;
  bool allowAssignmentManagement = true;

  @override
  Future<NexaBizPermissionDecision> evaluate({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  }) async {
    if (permissionId.value == 'permissions.role.manage' &&
        !allowRoleManagement) {
      return NexaBizPermissionDecision.deny;
    }
    if (permissionId.value == 'permissions.policy.manage' &&
        !allowPolicyManagement) {
      return NexaBizPermissionDecision.deny;
    }
    if (permissionId.value == 'permissions.assignment.manage' &&
        !allowAssignmentManagement) {
      return NexaBizPermissionDecision.deny;
    }
    return NexaBizPermissionDecision.allow;
  }
}

final class _TestMockIdentityStore implements CoreIdentityQueryStore {
  @override
  Future<CoreAuthUserRef?> findUserByIdentifier(
    String normalizedIdentifier,
  ) async => null;
  @override
  Future<CorePreparedCredential?> readUserCredential(String userId) async =>
      null;
  @override
  Future<CoreAuthIdentitySnapshot?> readAuthenticationSnapshot(
    String userId,
  ) async => null;
  @override
  Future<CoreLoginLockout?> checkLockout(
    String normalizedIdentifier,
    DateTime nowUtc,
  ) async => null;
  @override
  Future<CoreLoginLockout?> recordFailedAttempt(
    String normalizedIdentifier,
    DateTime nowUtc,
  ) async => null;
  @override
  Future<void> clearFailedAttempts(String normalizedIdentifier) async {}
  @override
  Future<bool> isSessionEligible(String userId, String? companyId) async =>
      true;
  @override
  Stream<bool> watchSessionEligibility(String userId, String? companyId) =>
      const Stream.empty();
}

class _FakeAdminStore implements NexaBizAuthorizationAdministrationStore {
  final Map<String, List<NexaBizCompanyRoleSummary>> rolesByCompany = {};
  final Map<String, NexaBizCompanyRoleDetails> roleDetailsByRole = {};
  final Map<String, Set<NexaBizPermissionId>> permissionsByRole = {};
  final Map<String, List<NexaBizMembershipRoleAssignment>> assignmentsByRole =
      {};
  final Map<String, List<NexaBizAssignableMembership>> assignablesByRole = {};
  final List<String> recordedEvents = [];
  Completer<void>? delayCompleter;
  Completer<void>? mutationDelayCompleter;
  Object? throwOnMutation;
  Object? throwOnQuery;

  NexaBizCompanyRoleSummary dummySummary({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    String name = 'Role Name',
    NexaBizCompanyRoleKind kind = NexaBizCompanyRoleKind.custom,
  }) {
    return NexaBizCompanyRoleSummary(
      companyId: companyId,
      roleId: roleId,
      metadata: NexaBizRoleMetadata(displayName: NexaBizRoleDisplayName(name)),
      kind: kind,
      membershipAssignmentCount: 0,
    );
  }

  @override
  Future<NexaBizAuthorizationAdministrationPage<NexaBizCompanyRoleSummary>>
  listCompanyRoles({
    required NexaBizCompanyId companyId,
    required NexaBizAuthorizationAdministrationPageRequest page,
    NexaBizCompanyRoleFilter? filter,
  }) async {
    recordedEvents.add('listCompanyRoles');
    if (delayCompleter != null) await delayCompleter!.future;
    if (throwOnQuery != null) throw throwOnQuery!;

    var list = List<NexaBizCompanyRoleSummary>.from(
      rolesByCompany[companyId.value] ?? [],
    );

    if (filter?.search != null) {
      final q = filter!.search!.toLowerCase();
      list = list
          .where(
            (r) =>
                r.metadata.displayName.value.toLowerCase().contains(q) ||
                r.roleId.value.toLowerCase().contains(q),
          )
          .toList();
    }

    if (filter?.kind != null) {
      list = list.where((r) => r.kind == filter!.kind).toList();
    }

    final start = page.cursor != null
        ? list.indexWhere((r) => r.roleId.value == page.cursor) + 1
        : 0;

    final sub = list.skip(start).take(page.limit).toList();
    final hasMore = start + page.limit < list.length;
    final nextCursor = hasMore && sub.isNotEmpty ? sub.last.roleId.value : null;

    return NexaBizAuthorizationAdministrationPage(
      items: sub,
      nextCursor: nextCursor,
    );
  }

  @override
  Future<NexaBizCompanyRoleDetails> readCompanyRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
  }) async {
    recordedEvents.add('readCompanyRole:${roleId.value}');
    if (delayCompleter != null) await delayCompleter!.future;
    if (throwOnQuery != null) throw throwOnQuery!;

    final existing =
        roleDetailsByRole['${companyId.value}:${roleId.value}'] ??
        roleDetailsByRole[roleId.value];
    if (existing != null) return existing;

    final summary = (rolesByCompany[companyId.value] ?? [])
        .cast<NexaBizCompanyRoleSummary?>()
        .firstWhere((r) => r?.roleId == roleId, orElse: () => null);

    final perms =
        permissionsByRole['${companyId.value}:${roleId.value}'] ??
        permissionsByRole[roleId.value] ??
        {};
    final assigns =
        assignmentsByRole['${companyId.value}:${roleId.value}'] ??
        assignmentsByRole[roleId.value] ??
        [];

    return NexaBizCompanyRoleDetails(
      companyId: companyId,
      roleId: roleId,
      metadata:
          summary?.metadata ??
          NexaBizRoleMetadata(
            displayName: NexaBizRoleDisplayName('Role ${roleId.value}'),
          ),
      kind: summary?.kind ?? NexaBizCompanyRoleKind.custom,
      membershipAssignmentCount: assigns.length,
      permissionAssignmentCount: perms.length,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationPage<NexaBizRolePermissionAssignment>
  >
  listRolePermissions({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizAuthorizationAdministrationPageRequest page,
  }) async {
    recordedEvents.add('listRolePermissions:${roleId.value}');
    if (delayCompleter != null) await delayCompleter!.future;
    if (throwOnQuery != null) throw throwOnQuery!;

    final granted =
        permissionsByRole['${companyId.value}:${roleId.value}'] ??
        permissionsByRole[roleId.value] ??
        {};
    final items = granted
        .map(
          (p) => NexaBizRolePermissionAssignment(
            companyId: companyId,
            roleId: roleId,
            permissionId: p,
            assignedAt: DateTime.utc(2026, 1, 1),
          ),
        )
        .toList();

    return NexaBizAuthorizationAdministrationPage(
      items: items,
      nextCursor: null,
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationPage<NexaBizMembershipRoleAssignment>
  >
  listRoleMemberships({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizAuthorizationAdministrationPageRequest page,
  }) async {
    recordedEvents.add('listRoleMemberships:${roleId.value}');
    if (delayCompleter != null) await delayCompleter!.future;
    if (throwOnQuery != null) throw throwOnQuery!;

    final list =
        assignmentsByRole['${companyId.value}:${roleId.value}'] ??
        assignmentsByRole[roleId.value] ??
        [];
    return NexaBizAuthorizationAdministrationPage(
      items: list,
      nextCursor: null,
    );
  }

  @override
  Future<NexaBizAuthorizationAdministrationPage<NexaBizAssignableMembership>>
  listAssignableMembershipsForRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizAuthorizationAdministrationPageRequest page,
    String? search,
  }) async {
    recordedEvents.add('listAssignableMembershipsForRole:${roleId.value}');
    if (delayCompleter != null) await delayCompleter!.future;
    if (throwOnQuery != null) throw throwOnQuery!;

    var list =
        assignablesByRole['${companyId.value}:${roleId.value}'] ??
        assignablesByRole[roleId.value] ??
        [];
    if (search != null) {
      final q = search.toLowerCase();
      list = list
          .where(
            (m) =>
                (m.userName?.toLowerCase().contains(q) ?? false) ||
                (m.userEmail?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    return NexaBizAuthorizationAdministrationPage(
      items: list,
      nextCursor: null,
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationPage<NexaBizMembershipRoleAssignment>
  >
  listMembershipRoles({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
    required NexaBizAuthorizationAdministrationPageRequest page,
  }) async =>
      NexaBizAuthorizationAdministrationPage(items: [], nextCursor: null);

  @override
  Future<NexaBizMembershipEffectivePermissionInfo>
  inspectMembershipEffectivePermissions({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
  }) async {
    return NexaBizMembershipEffectivePermissionInfo(
      companyId: companyId,
      membershipId: membershipId,
      userId: NexaBizUserId('usr-1'),
      roleIds: const {},
      permissionIds: const {},
      isEligible: true,
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  createCompanyRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizRoleMetadata metadata,
  }) async {
    recordedEvents.add('createCompanyRole:${roleId.value}');
    if (mutationDelayCompleter != null) {
      await mutationDelayCompleter!.future;
    }
    if (throwOnMutation != null) throw throwOnMutation!;
    final roles = rolesByCompany.putIfAbsent(companyId.value, () => []);
    if (roles.any((role) => role.roleId == roleId)) {
      throw NexaBizAuthorizationAdministrationConflictException(
        type: NexaBizAuthorizationAdministrationConflictType.duplicateRoleKey,
        roleId: roleId,
      );
    }
    if (roles.any(
      (role) =>
          role.metadata.displayName.comparisonKey ==
          metadata.displayName.comparisonKey,
    )) {
      throw NexaBizAuthorizationAdministrationConflictException(
        type: NexaBizAuthorizationAdministrationConflictType
            .duplicateRoleDisplayName,
        roleId: roleId,
      );
    }
    final details = NexaBizCompanyRoleDetails(
      companyId: companyId,
      roleId: roleId,
      metadata: metadata,
      kind: NexaBizCompanyRoleKind.custom,
      membershipAssignmentCount: 0,
      permissionAssignmentCount: 0,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    roles.add(
      NexaBizCompanyRoleSummary(
        companyId: companyId,
        roleId: roleId,
        metadata: metadata,
        kind: NexaBizCompanyRoleKind.custom,
        membershipAssignmentCount: 0,
      ),
    );
    roleDetailsByRole['${companyId.value}:${roleId.value}'] = details;
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: null,
      after: details,
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  updateCompanyRoleMetadata({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizRoleMetadata metadata,
  }) async {
    recordedEvents.add('updateCompanyRoleMetadata:${roleId.value}');
    if (mutationDelayCompleter != null) {
      await mutationDelayCompleter!.future;
    }
    if (throwOnMutation != null) throw throwOnMutation!;
    final roles = rolesByCompany[companyId.value] ?? [];
    final index = roles.indexWhere((role) => role.roleId == roleId);
    if (index < 0) {
      throw NexaBizRoleNotFoundException(companyId: companyId, roleId: roleId);
    }
    final beforeSummary = roles[index];
    if (beforeSummary.isBuiltIn) {
      throw NexaBizBuiltInRoleProtectedException(
        roleId: roleId,
        action: NexaBizBuiltInRoleProtectedAction.updateMetadata,
      );
    }
    final before = await readCompanyRole(companyId: companyId, roleId: roleId);
    final after = NexaBizCompanyRoleDetails(
      companyId: companyId,
      roleId: roleId,
      metadata: metadata,
      kind: before.kind,
      membershipAssignmentCount: before.membershipAssignmentCount,
      permissionAssignmentCount: before.permissionAssignmentCount,
      createdAt: before.createdAt,
      updatedAt: DateTime.utc(2026, 1, 2),
    );
    roles[index] = NexaBizCompanyRoleSummary(
      companyId: companyId,
      roleId: roleId,
      metadata: metadata,
      kind: beforeSummary.kind,
      membershipAssignmentCount: beforeSummary.membershipAssignmentCount,
    );
    roleDetailsByRole['${companyId.value}:${roleId.value}'] = after;
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: before,
      after: after,
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  deleteCompanyRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
  }) async {
    recordedEvents.add('deleteCompanyRole:${roleId.value}');
    if (mutationDelayCompleter != null) {
      await mutationDelayCompleter!.future;
    }
    if (throwOnMutation != null) throw throwOnMutation!;
    final roles = rolesByCompany[companyId.value] ?? [];
    final index = roles.indexWhere((role) => role.roleId == roleId);
    if (index < 0) {
      throw NexaBizRoleNotFoundException(companyId: companyId, roleId: roleId);
    }
    final summary = roles[index];
    if (summary.isBuiltIn) {
      throw NexaBizBuiltInRoleProtectedException(
        roleId: roleId,
        action: NexaBizBuiltInRoleProtectedAction.delete,
      );
    }
    if (summary.membershipAssignmentCount > 0) {
      throw NexaBizAuthorizationAdministrationConflictException(
        type: NexaBizAuthorizationAdministrationConflictType
            .roleHasMembershipAssignments,
        roleId: roleId,
      );
    }
    final before = await readCompanyRole(companyId: companyId, roleId: roleId);
    roles.removeAt(index);
    roleDetailsByRole.remove('${companyId.value}:${roleId.value}');
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: before,
      after: null,
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<
      NexaBizRolePermissionAssignment
    >
  >
  grantPermissionToRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizPermissionId permissionId,
  }) async {
    recordedEvents.add(
      'grantPermissionToRole:${roleId.value}:${permissionId.value}',
    );
    if (mutationDelayCompleter != null) {
      await mutationDelayCompleter!.future;
    }
    if (throwOnMutation != null) throw throwOnMutation!;
    final permissions = permissionsByRole.putIfAbsent(
      '${companyId.value}:${roleId.value}',
      () => <NexaBizPermissionId>{},
    );
    final changed = permissions.add(permissionId);
    final assignment = NexaBizRolePermissionAssignment(
      companyId: companyId,
      roleId: roleId,
      permissionId: permissionId,
      assignedAt: DateTime.utc(2026, 1, 1),
    );
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: changed
          ? NexaBizAuthorizationAdministrationMutationOutcome.changed
          : NexaBizAuthorizationAdministrationMutationOutcome.unchanged,
      before: changed ? null : assignment,
      after: assignment,
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<
      NexaBizRolePermissionAssignment
    >
  >
  revokePermissionFromRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizPermissionId permissionId,
  }) async {
    recordedEvents.add(
      'revokePermissionFromRole:${roleId.value}:${permissionId.value}',
    );
    if (mutationDelayCompleter != null) {
      await mutationDelayCompleter!.future;
    }
    if (throwOnMutation != null) throw throwOnMutation!;
    final permissions = permissionsByRole.putIfAbsent(
      '${companyId.value}:${roleId.value}',
      () => <NexaBizPermissionId>{},
    );
    final changed = permissions.remove(permissionId);
    final assignment = NexaBizRolePermissionAssignment(
      companyId: companyId,
      roleId: roleId,
      permissionId: permissionId,
      assignedAt: DateTime.utc(2026, 1, 1),
    );
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: changed
          ? NexaBizAuthorizationAdministrationMutationOutcome.changed
          : NexaBizAuthorizationAdministrationMutationOutcome.unchanged,
      before: changed ? assignment : null,
      after: null,
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<
      NexaBizMembershipRoleAssignment
    >
  >
  assignRoleToMembership({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
    required NexaBizRoleId roleId,
  }) async {
    recordedEvents.add(
      'assignRoleToMembership:${roleId.value}:${membershipId.value}',
    );
    if (mutationDelayCompleter != null) {
      await mutationDelayCompleter!.future;
    }
    if (throwOnMutation != null) throw throwOnMutation!;
    final key = '${companyId.value}:${roleId.value}';
    final candidates = assignablesByRole.putIfAbsent(key, () => []);
    final candidate = candidates.firstWhere(
      (item) => item.membershipId == membershipId,
    );
    final assignments = assignmentsByRole.putIfAbsent(key, () => []);
    final existing = assignments
        .cast<NexaBizMembershipRoleAssignment?>()
        .firstWhere(
          (item) => item?.membershipId == membershipId,
          orElse: () => null,
        );
    final assignment =
        existing ??
        NexaBizMembershipRoleAssignment(
          companyId: companyId,
          membershipId: membershipId,
          userId: candidate.userId,
          roleId: roleId,
          userName: candidate.userName,
          userEmail: candidate.userEmail,
          membershipIsActive: candidate.membershipIsActive,
          userIsActive: candidate.userIsActive,
          assignedAt: DateTime.utc(2026, 1, 1),
        );
    if (existing == null) assignments.add(assignment);
    candidates.removeWhere((item) => item.membershipId == membershipId);
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: existing == null
          ? NexaBizAuthorizationAdministrationMutationOutcome.changed
          : NexaBizAuthorizationAdministrationMutationOutcome.unchanged,
      before: existing,
      after: assignment,
    );
  }

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<
      NexaBizMembershipRoleAssignment
    >
  >
  unassignRoleFromMembership({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
    required NexaBizRoleId roleId,
  }) async {
    recordedEvents.add(
      'unassignRoleFromMembership:${roleId.value}:${membershipId.value}',
    );
    if (mutationDelayCompleter != null) {
      await mutationDelayCompleter!.future;
    }
    if (throwOnMutation != null) throw throwOnMutation!;
    final key = '${companyId.value}:${roleId.value}';
    final assignments = assignmentsByRole.putIfAbsent(key, () => []);
    final existing = assignments
        .cast<NexaBizMembershipRoleAssignment?>()
        .firstWhere(
          (item) => item?.membershipId == membershipId,
          orElse: () => null,
        );
    assignments.removeWhere((item) => item.membershipId == membershipId);
    if (existing != null && existing.isEligible) {
      assignablesByRole
          .putIfAbsent(key, () => [])
          .add(
            NexaBizAssignableMembership(
              companyId: companyId,
              membershipId: membershipId,
              userId: existing.userId,
              userName: existing.userName,
              userEmail: existing.userEmail,
              membershipIsActive: existing.membershipIsActive,
              userIsActive: existing.userIsActive,
            ),
          );
    }
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: existing == null
          ? NexaBizAuthorizationAdministrationMutationOutcome.unchanged
          : NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: existing,
      after: null,
    );
  }
}

// ---------------------------------------------------------------------------
// Test Suite
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAdminStore fakeStore;
  late NexaBizAuthorizationAdministration adminFacade;
  late NexaBizAuthorizationInvalidationSignal invalidationSignal;
  late _FakePermissionEvaluator permissionEvaluator;
  late CoreSessionController sessionController;
  late RolesAdministrationController controller;

  final testCompanyId = NexaBizCompanyId('company_123');
  final roleA = NexaBizRoleId('company.owner');
  final roleB = NexaBizRoleId('company.manager');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLocaleController.initialize();

    fakeStore = _FakeAdminStore();
    invalidationSignal = NexaBizAuthorizationInvalidationSignal();
    permissionEvaluator = _FakePermissionEvaluator();

    adminFacade = NexaBizAuthorizationAdministration.create(
      permissionGuard: const _FakePermissionGuard(),
      queryStore: fakeStore,
      mutationStore: fakeStore,
      invalidationSignal: invalidationSignal,
      permissionCatalog: NexaBizImmutablePermissionCatalog({
        NexaBizPermissionId('company.profile.view'),
        NexaBizPermissionId('identity.user.manage'),
        NexaBizPermissionId('permissions.role.manage'),
        NexaBizPermissionId('billing.invoice.archive'), // synthetic unknown
      }),
    );

    sessionController = CoreSessionController(
      authenticateLocalUser: AuthenticateLocalUser(
        queryStore: _TestMockIdentityStore(),
      ),
      queryStore: _TestMockIdentityStore(),
    );

    sessionController.setSessionForTesting(
      NexaBizSession.active(
        sessionId: 'sess_1',
        userId: NexaBizUserId('usr_1'),
        membershipId: NexaBizMembershipId('mem_1'),
        companyId: testCompanyId,
        companyName: 'Test Corp',
        role: 'owner',
      ),
    );

    // Seed roles
    fakeStore.rolesByCompany[testCompanyId.value] = [
      fakeStore.dummySummary(
        companyId: testCompanyId,
        roleId: roleA,
        name: 'Owner',
        kind: NexaBizCompanyRoleKind.builtIn,
      ),
      fakeStore.dummySummary(
        companyId: testCompanyId,
        roleId: roleB,
        name: 'Manager',
        kind: NexaBizCompanyRoleKind.custom,
      ),
    ];

    fakeStore.permissionsByRole['${testCompanyId.value}:${roleA.value}'] = {
      NexaBizPermissionId('company.profile.view'),
      NexaBizPermissionId('permissions.role.manage'),
    };

    fakeStore.assignmentsByRole['${testCompanyId.value}:${roleA.value}'] = [
      NexaBizMembershipRoleAssignment(
        companyId: testCompanyId,
        membershipId: NexaBizMembershipId('mem_alpha'),
        userId: NexaBizUserId('usr_alpha'),
        roleId: roleA,
        userName: 'Alice Smith',
        userEmail: 'alice@example.com',
        membershipIsActive: true,
        userIsActive: true,
        assignedAt: DateTime.utc(2026, 1, 1),
      ),
      NexaBizMembershipRoleAssignment(
        companyId: testCompanyId,
        membershipId: NexaBizMembershipId('mem_beta'),
        userId: NexaBizUserId('usr_beta'),
        roleId: roleA,
        userName: null, // null name to test email fallback
        userEmail: 'bob@example.com',
        membershipIsActive: false,
        userIsActive: true,
        assignedAt: DateTime.utc(2026, 1, 1),
      ),
    ];

    controller = RolesAdministrationController(
      administration: adminFacade,
      metadataResolver: const NexaBizPermissionPresentationResolver(),
      sessionController: sessionController,
      invalidationSignal: invalidationSignal,
    );
    await controller.initialize();
  });

  tearDown(() {
    controller.dispose();
  });

  Widget buildTestWidget({
    required WidgetTester tester,
    RolesAdministrationController? injectedController,
    Size viewport = const Size(1200, 800),
    Locale locale = const Locale('en'),
    double textScaleFactor = 1.0,
  }) {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    return MediaQuery(
      data: MediaQueryData(
        size: viewport,
        textScaler: TextScaler.linear(textScaleFactor),
      ),
      child: AppPermissionScope(
        permissionEvaluator: permissionEvaluator,
        sessionController: sessionController,
        invalidationSignal: invalidationSignal,
        authorizationAdministration: adminFacade,
        child: NexaBizRootApp(
          locale: locale,
          supportedLocales: AppLocaleController.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            NexaBizShadcnLocalizationsDelegate.delegate,
          ],
          home: RolesScreen(controller: injectedController ?? controller),
        ),
      ),
    );
  }

  group('RolesScreen — Step 06 Role Lifecycle UI', () {
    testWidgets(
      '72. Initial render: lists roles with display name and status',
      (tester) async {
        await controller.refreshRoles();
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();

        expect(find.text('Roles & Access Control'), findsOneWidget);
        expect(find.text('Owner'), findsWidgets);
        expect(find.text('Manager'), findsOneWidget);
        expect(find.text('company.owner'), findsWidgets);
        expect(find.text('company.manager'), findsOneWidget);
        expect(find.text('Built-in'), findsWidgets);
        expect(find.text('Custom'), findsWidgets);
      },
    );

    testWidgets('73. Selection: selecting Role B displays details for B', (
      tester,
    ) async {
      await controller.refreshRoles();
      await tester.pumpWidget(buildTestWidget(tester: tester));
      await tester.pumpAndSettle();

      // Tap on Manager role in the list
      await tester.tap(find.text('Manager'));
      await tester.pumpAndSettle();

      expect(controller.state.selectedRoleId, equals(roleB));
      expect(find.text('company.manager'), findsWidgets);
    });

    testWidgets('74. Rapid selection: late response for A is ignored', (
      tester,
    ) async {
      await controller.refreshRoles();
      await tester.pumpWidget(buildTestWidget(tester: tester));
      await tester.pumpAndSettle();

      // Rapidly select A then B
      controller.selectRole(roleA);
      controller.selectRole(roleB);
      await tester.pumpAndSettle();

      expect(controller.state.selectedRoleId, equals(roleB));
    });

    testWidgets(
      '75. Built-in role: displays help and no edit/delete controls',
      (tester) async {
        await controller.refreshRoles();
        await controller.selectRole(roleA);
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();

        // Built-in help text exists
        expect(
          find.textContaining('Built-in roles are system-defined'),
          findsOneWidget,
        );

        expect(find.text('Create Role'), findsWidgets);
        expect(find.text('Edit Role'), findsNothing);
        expect(find.text('Delete Role'), findsNothing);
        expect(find.text('Assign Member'), findsNothing);
        expect(find.text('Unassign'), findsNothing);
        expect(find.byType(AppSwitch), findsNothing);
      },
    );

    testWidgets(
      '76. Custom role: renders lifecycle actions without permission/member mutations',
      (tester) async {
        await controller.refreshRoles();
        await controller.selectRole(roleB);
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();

        expect(find.text('Custom'), findsWidgets);
        expect(
          find.textContaining('Built-in roles are system-defined'),
          findsNothing,
        );
        expect(find.text('Edit Role'), findsOneWidget);
        expect(find.text('Delete Role'), findsOneWidget);
        expect(find.text('Assign Member'), findsNothing);
        expect(find.byType(AppSwitch), findsNothing);
      },
    );

    testWidgets('77. Permission metadata: renders localized title & ID', (
      tester,
    ) async {
      await controller.refreshRoles();
      await controller.selectRole(roleA);
      await tester.pumpWidget(buildTestWidget(tester: tester));
      await tester.pumpAndSettle();

      // Switch to Permissions tab
      await tester.tap(find.text('Permissions').first);
      await tester.pumpAndSettle();

      expect(find.text('View company profile'), findsOneWidget);
      expect(find.text('company.profile.view'), findsOneWidget);
      expect(find.text('Manage custom roles'), findsOneWidget);
      expect(find.text('permissions.role.manage'), findsOneWidget);
      expect(find.text('Granted'), findsWidgets);
    });

    testWidgets('78. Unknown future permission: renders fallback gracefully', (
      tester,
    ) async {
      fakeStore.permissionsByRole['${testCompanyId.value}:${roleB.value}'] = {
        NexaBizPermissionId('billing.invoice.archive'),
      };

      await controller.refreshRoles();
      await controller.selectRole(roleB);
      await tester.pumpWidget(buildTestWidget(tester: tester));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Permissions').first);
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('billing.invoice.archive')),
        200,
        scrollable: find
            .byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  axisDirectionToAxis(widget.axisDirection) == Axis.vertical,
            )
            .last,
      );
      expect(find.text('billing.invoice.archive'), findsWidgets);
    });

    testWidgets('79. Permission groups: deterministic order rendered', (
      tester,
    ) async {
      await controller.refreshRoles();
      await controller.selectRole(roleA);
      await tester.pumpWidget(buildTestWidget(tester: tester));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Permissions').first);
      await tester.pumpAndSettle();

      expect(find.text('Company Workspace'), findsOneWidget);
      expect(find.text('Access Control & Roles'), findsOneWidget);
    });

    testWidgets(
      'Step 07 grant and revoke are per-row pending and commit-confirmed',
      (tester) async {
        final permissionId = NexaBizPermissionId('company.profile.view');
        await controller.refreshRoles();
        await controller.selectRole(roleB);
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Permissions').first);
        await tester.pumpAndSettle();

        expect(controller.state.isPermissionGranted(permissionId), isFalse);

        fakeStore.mutationDelayCompleter = Completer<void>();
        await tester.tap(find.byKey(ValueKey(permissionId)));
        await tester.pump();

        expect(controller.state.isPermissionPending(permissionId), isTrue);
        expect(controller.state.isPermissionGranted(permissionId), isFalse);
        expect(
          fakeStore.recordedEvents.where(
            (event) =>
                event ==
                'grantPermissionToRole:company.manager:company.profile.view',
          ),
          hasLength(1),
        );

        fakeStore.mutationDelayCompleter!.complete();
        await tester.pumpAndSettle();
        expect(controller.state.isPermissionGranted(permissionId), isTrue);
        expect(
          tester.widget<AppCheckbox>(find.byKey(ValueKey(permissionId))).value,
          isTrue,
        );

        fakeStore.mutationDelayCompleter = Completer<void>();
        await tester.tap(find.byKey(ValueKey(permissionId)));
        await tester.pump();
        expect(controller.state.isPermissionPending(permissionId), isTrue);
        expect(controller.state.isPermissionGranted(permissionId), isTrue);

        fakeStore.mutationDelayCompleter!.complete();
        await tester.pumpAndSettle();
        expect(controller.state.isPermissionGranted(permissionId), isFalse);
      },
    );

    testWidgets(
      'Step 07 typed grant and revoke failures retain committed truth',
      (tester) async {
        final permissionId = NexaBizPermissionId('company.profile.view');
        await controller.refreshRoles();
        await controller.selectRole(roleB);
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Permissions').first);
        await tester.pumpAndSettle();

        fakeStore.throwOnMutation = NexaBizPermissionDeniedException(
          permissionId:
              NexaBizAuthorizationAdministrationPermissions.policyManage,
          contextScope: NexaBizRoleScope.company,
          decision: NexaBizPermissionDecision.deny,
        );
        await tester.tap(find.byKey(ValueKey(permissionId)));
        await tester.pumpAndSettle();
        expect(controller.state.isPermissionGranted(permissionId), isFalse);
        expect(
          find.text(
            'You do not have permission to perform this administration action.',
          ),
          findsOneWidget,
        );

        fakeStore.throwOnMutation = null;
        await controller.grantPermission(permissionId);
        fakeStore.throwOnMutation = NexaBizPermissionDeniedException(
          permissionId:
              NexaBizAuthorizationAdministrationPermissions.policyManage,
          contextScope: NexaBizRoleScope.company,
          decision: NexaBizPermissionDecision.deny,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(ValueKey(permissionId)));
        await tester.pumpAndSettle();
        expect(controller.state.isPermissionGranted(permissionId), isTrue);
      },
    );

    testWidgets(
      'Step 07 review-only and built-in roles remain readable without controls',
      (tester) async {
        await controller.refreshRoles();
        await controller.selectRole(roleB);
        permissionEvaluator.allowPolicyManagement = false;
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Permissions').first);
        await tester.pumpAndSettle();

        expect(find.text('View company profile'), findsOneWidget);
        expect(find.text('Not granted'), findsWidgets);
        expect(find.byType(AppCheckbox), findsNothing);

        permissionEvaluator.allowPolicyManagement = true;
        invalidationSignal.notifyAuthorizationChanged();
        await tester.pumpAndSettle();
        expect(find.byType(AppCheckbox), findsWidgets);

        permissionEvaluator.allowPolicyManagement = false;
        invalidationSignal.notifyAuthorizationChanged();
        await tester.pumpAndSettle();
        expect(find.text('View company profile'), findsOneWidget);
        expect(find.byType(AppCheckbox), findsNothing);

        await controller.selectRole(roleA);
        permissionEvaluator.allowPolicyManagement = true;
        invalidationSignal.notifyAuthorizationChanged();
        await tester.pumpAndSettle();
        expect(find.text('View company profile'), findsOneWidget);
        expect(find.byType(AppCheckbox), findsNothing);
      },
    );

    testWidgets(
      'Step 07 unknown declared permission is manageable and accessible',
      (tester) async {
        final unknownId = NexaBizPermissionId('billing.invoice.archive');
        await controller.refreshRoles();
        await controller.selectRole(roleB);
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Permissions').first);
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('billing.invoice.archive')),
          200,
          scrollable: find
              .byWidgetPredicate(
                (widget) =>
                    widget is Scrollable &&
                    axisDirectionToAxis(widget.axisDirection) == Axis.vertical,
              )
              .last,
        );
        expect(find.text('billing.invoice.archive'), findsWidgets);
        expect(find.byKey(ValueKey(unknownId)), findsWidgets);
        expect(
          find.bySemanticsLabel(RegExp('billing\\.invoice\\.archive')),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'Step 07 compact Arabic at 2x keeps canonical permission IDs LTR',
      (tester) async {
        await controller.refreshRoles();
        await controller.selectRole(roleB);
        await tester.pumpWidget(
          buildTestWidget(
            tester: tester,
            viewport: const Size(400, 800),
            locale: const Locale('ar'),
            textScaleFactor: 2,
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Manager'),
          120,
          scrollable: find
              .byWidgetPredicate(
                (widget) =>
                    widget is Scrollable &&
                    axisDirectionToAxis(widget.axisDirection) == Axis.vertical,
              )
              .last,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Manager'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('الصلاحيات').first,
          100,
          scrollable: find
              .byWidgetPredicate(
                (widget) =>
                    widget is Scrollable &&
                    axisDirectionToAxis(widget.axisDirection) == Axis.vertical,
              )
              .last,
        );
        final horizontalTabs = find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              axisDirectionToAxis(widget.axisDirection) == Axis.horizontal,
        );
        await tester.scrollUntilVisible(
          find.text('الصلاحيات').first,
          100,
          scrollable: horizontalTabs.last,
        );
        await tester.tap(find.text('الصلاحيات').first);
        await tester.pumpAndSettle();

        final technicalId = find.text('company.profile.view');
        expect(technicalId, findsOneWidget);
        expect(
          tester
              .widget<Directionality>(
                find
                    .ancestor(
                      of: technicalId,
                      matching: find.byType(Directionality),
                    )
                    .first,
              )
              .textDirection,
          TextDirection.ltr,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '80. Assigned member: human-readable user identity, no raw UUID primary',
      (tester) async {
        await controller.refreshRoles();
        await controller.selectRole(roleA);
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Assigned Members').first);
        await tester.pumpAndSettle();

        expect(find.text('Alice Smith'), findsOneWidget);
        expect(find.text('alice@example.com'), findsOneWidget);
        expect(find.text('mem_alpha'), findsNothing); // Raw UUID not primary
        expect(find.text('Eligible'), findsOneWidget);
      },
    );

    testWidgets('81. Null name: falls back to user email', (tester) async {
      await controller.refreshRoles();
      await controller.selectRole(roleA);
      await tester.pumpWidget(buildTestWidget(tester: tester));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Assigned Members').first);
      await tester.pumpAndSettle();

      expect(find.text('bob@example.com'), findsOneWidget);
      expect(find.text('Ineligible'), findsOneWidget);
    });

    testWidgets(
      'Step 08 assignment is per-member pending and commit-confirmed',
      (tester) async {
        final candidateId = NexaBizMembershipId('mem_candidate');
        fakeStore.assignablesByRole['${testCompanyId.value}:${roleB.value}'] = [
          NexaBizAssignableMembership(
            companyId: testCompanyId,
            membershipId: candidateId,
            userId: NexaBizUserId('usr_candidate'),
            userName: 'Candidate Person',
            userEmail: 'candidate@example.com',
            membershipIsActive: true,
            userIsActive: true,
          ),
        ];
        await controller.refreshRoles();
        await controller.selectRole(roleB);
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Assigned Members').first);
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('assign-member-action')));
        await tester.pumpAndSettle();
        expect(find.byType(AppDialog<void>), findsOneWidget);
        expect(find.text('Candidate Person'), findsOneWidget);
        expect(find.text('candidate@example.com'), findsOneWidget);

        fakeStore.mutationDelayCompleter = Completer<void>();
        await tester.tap(find.widgetWithText(AppButton, 'Assign').last);
        await tester.pump();

        expect(controller.state.isMembershipPending(candidateId), isTrue);
        expect(find.text('Candidate Person'), findsOneWidget);
        expect(
          controller.state.assignedMembers.any(
            (member) => member.membershipId == candidateId,
          ),
          isFalse,
        );
        expect(
          fakeStore.recordedEvents.where(
            (event) =>
                event == 'assignRoleToMembership:company.manager:mem_candidate',
          ),
          hasLength(1),
        );

        fakeStore.mutationDelayCompleter!.complete();
        await tester.pumpAndSettle();
        expect(controller.state.isMembershipPending(candidateId), isFalse);
        expect(
          controller.state.assignedMembers.where(
            (member) => member.membershipId == candidateId,
          ),
          hasLength(1),
        );
        expect(controller.state.assignableMembers, isEmpty);
      },
    );

    testWidgets(
      'Step 08 unassignment confirms and retains committed truth on failure',
      (tester) async {
        await controller.refreshRoles();
        await controller.selectRole(roleA);
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Assigned Members').first);
        await tester.pumpAndSettle();

        final alice = NexaBizMembershipId('mem_alpha');
        await tester.tap(find.byKey(ValueKey(('unassign', alice))));
        await tester.pumpAndSettle();
        expect(
          find.text('Remove "Alice Smith" from role "Owner"?'),
          findsOneWidget,
        );

        fakeStore.throwOnMutation = NexaBizLastOwnerProtectedException(
          testCompanyId,
        );
        await tester.tap(find.widgetWithText(AppButton, 'Unassign').last);
        await tester.pumpAndSettle();
        expect(
          controller.state.assignedMembers.any(
            (member) => member.membershipId == alice,
          ),
          isTrue,
        );
        expect(
          find.textContaining('Cannot remove the last active company owner'),
          findsWidgets,
        );

        fakeStore.throwOnMutation = null;
        await tester.tap(find.widgetWithText(AppButton, 'Unassign').last);
        await tester.pumpAndSettle();
        expect(
          controller.state.assignedMembers.any(
            (member) => member.membershipId == alice,
          ),
          isFalse,
        );
      },
    );

    testWidgets('Step 08 assignment failure keeps candidate and search input', (
      tester,
    ) async {
      final candidateId = NexaBizMembershipId('mem_failure');
      fakeStore.assignablesByRole['${testCompanyId.value}:${roleB.value}'] = [
        NexaBizAssignableMembership(
          companyId: testCompanyId,
          membershipId: candidateId,
          userId: NexaBizUserId('usr_failure'),
          userName: 'Failure Candidate',
          userEmail: 'failure@example.com',
          membershipIsActive: true,
          userIsActive: true,
        ),
      ];
      await controller.refreshRoles();
      await controller.selectRole(roleB);
      await tester.pumpWidget(buildTestWidget(tester: tester));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Assigned Members').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('assign-member-action')));
      await tester.pumpAndSettle();

      final search = find.byKey(const ValueKey('role-membership-search'));
      await tester.enterText(search, 'Failure');
      await tester.pumpAndSettle();
      fakeStore.throwOnMutation = NexaBizMembershipIneligibleException(
        membershipId: candidateId,
        reason: NexaBizMembershipIneligibilityReason.inactiveMembership,
      );
      await tester.tap(find.widgetWithText(AppButton, 'Assign').last);
      await tester.pumpAndSettle();

      expect(find.text('Failure Candidate'), findsOneWidget);
      expect(
        find.textContaining('member is currently inactive'),
        findsOneWidget,
      );
      expect(tester.widget<AppSearchField>(search).controller!.text, 'Failure');
      expect(controller.state.assignedMembers, isEmpty);
      expect(controller.state.pendingMembershipIds, isEmpty);
    });

    testWidgets('Step 08 missing identity uses localized neutral fallback', (
      tester,
    ) async {
      fakeStore.assignmentsByRole['${testCompanyId.value}:${roleB.value}'] = [
        NexaBizMembershipRoleAssignment(
          companyId: testCompanyId,
          membershipId: NexaBizMembershipId('mem_unnamed'),
          userId: NexaBizUserId('usr_unnamed'),
          roleId: roleB,
          membershipIsActive: true,
          userIsActive: true,
          assignedAt: DateTime.utc(2026, 1, 1),
        ),
      ];
      await controller.refreshRoles();
      await controller.selectRole(roleB);
      await tester.pumpWidget(buildTestWidget(tester: tester));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Assigned Members').first);
      await tester.pumpAndSettle();

      expect(find.text('Unnamed member'), findsOneWidget);
      expect(find.text('usr_unnamed'), findsNothing);
      expect(find.text('mem_unnamed'), findsNothing);
    });

    testWidgets(
      'Step 08 assignment.manage gate is live and owner role remains mutable',
      (tester) async {
        await controller.refreshRoles();
        await controller.selectRole(roleA);
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Assigned Members').first);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('assign-member-action')),
          findsOneWidget,
        );
        expect(find.widgetWithText(AppButton, 'Unassign'), findsWidgets);

        await tester.tap(find.byKey(const ValueKey('assign-member-action')));
        await tester.pumpAndSettle();
        permissionEvaluator.allowAssignmentManagement = false;
        invalidationSignal.notifyAuthorizationChanged();
        await tester.pumpAndSettle();

        expect(find.text('Alice Smith'), findsWidgets);
        final search = tester.widget<AppSearchField>(
          find.byKey(const ValueKey('role-membership-search')),
        );
        expect(search.enabled, isFalse);
        expect(find.widgetWithText(AppButton, 'Assign'), findsNothing);

        await tester.tap(find.widgetWithText(AppButton, 'Close'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('assign-member-action')),
          findsNothing,
        );
        expect(find.widgetWithText(AppButton, 'Unassign'), findsNothing);
        expect(find.text('Alice Smith'), findsOneWidget);
      },
    );

    testWidgets(
      'Step 08 compact Arabic assignment surface supports 2x text scale',
      (tester) async {
        fakeStore.assignablesByRole['${testCompanyId.value}:${roleB.value}'] = [
          NexaBizAssignableMembership(
            companyId: testCompanyId,
            membershipId: NexaBizMembershipId('mem_ar'),
            userId: NexaBizUserId('usr_ar'),
            userName: 'عضو تجريبي',
            userEmail: 'arabic@example.com',
            membershipIsActive: true,
            userIsActive: true,
          ),
        ];
        await controller.refreshRoles();
        await controller.selectRole(roleB);
        await tester.pumpWidget(
          buildTestWidget(
            tester: tester,
            viewport: const Size(400, 800),
            locale: const Locale('ar'),
            textScaleFactor: 2,
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Manager'),
          120,
          scrollable: find
              .byWidgetPredicate(
                (widget) =>
                    widget is Scrollable &&
                    axisDirectionToAxis(widget.axisDirection) == Axis.vertical,
              )
              .last,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Manager'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('الأعضاء المعينون').first,
          100,
          scrollable: find
              .byWidgetPredicate(
                (widget) =>
                    widget is Scrollable &&
                    axisDirectionToAxis(widget.axisDirection) == Axis.vertical,
              )
              .last,
        );
        final horizontalTabs = find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              axisDirectionToAxis(widget.axisDirection) == Axis.horizontal,
        );
        await tester.scrollUntilVisible(
          find.text('الأعضاء المعينون').first,
          100,
          scrollable: horizontalTabs.last,
        );
        await tester.tap(find.text('الأعضاء المعينون').first);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('assign-member-action')));
        await tester.pumpAndSettle();

        expect(find.byType(AppBottomSheet), findsOneWidget);
        expect(find.text('عضو تجريبي'), findsOneWidget);
        expect(find.text('arabic@example.com'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('82. Empty states: no roles, no permissions, no members', (
      tester,
    ) async {
      fakeStore.rolesByCompany[testCompanyId.value] = [];
      await controller.refreshRoles();
      await tester.pumpWidget(buildTestWidget(tester: tester));
      await tester.pumpAndSettle();

      expect(find.text('No roles found.'), findsOneWidget);
      expect(find.text('Select a role to view its details.'), findsOneWidget);
    });

    testWidgets('83. Loading states: skeleton and loading indicators', (
      tester,
    ) async {
      fakeStore.delayCompleter = Completer<void>();
      final freshController = RolesAdministrationController(
        administration: adminFacade,
        metadataResolver: const NexaBizPermissionPresentationResolver(),
        sessionController: sessionController,
        invalidationSignal: invalidationSignal,
      );
      addTearDown(freshController.dispose);
      freshController.refreshRoles();

      await tester.pumpWidget(
        buildTestWidget(tester: tester, injectedController: freshController),
      );
      await tester.pump();

      expect(find.byType(AppLoading), findsWidgets);

      fakeStore.delayCompleter!.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('84. Error states: list error with retry button', (
      tester,
    ) async {
      final errorController = RolesAdministrationController(
        administration: adminFacade,
        metadataResolver: const NexaBizPermissionPresentationResolver(),
        sessionController: sessionController,
        invalidationSignal: invalidationSignal,
      );
      addTearDown(errorController.dispose);

      fakeStore.throwOnQuery = StateError('Store read fault');
      await errorController.refreshRoles();

      await tester.pumpWidget(
        buildTestWidget(tester: tester, injectedController: errorController),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorState), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      fakeStore.throwOnQuery = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Owner'), findsWidgets);
    });

    testWidgets('85. Pagination: load more roles appends items', (
      tester,
    ) async {
      final manyRoles = [
        for (var i = 1; i <= 25; i++)
          fakeStore.dummySummary(
            companyId: testCompanyId,
            roleId: NexaBizRoleId('company.role_$i'),
            name: 'Role $i',
          ),
      ];
      fakeStore.rolesByCompany[testCompanyId.value] = manyRoles;

      final pagedController = RolesAdministrationController(
        administration: adminFacade,
        metadataResolver: const NexaBizPermissionPresentationResolver(),
        sessionController: sessionController,
        invalidationSignal: invalidationSignal,
        pageSize: 5,
      );
      addTearDown(pagedController.dispose);

      await pagedController.refreshRoles();
      await tester.pumpWidget(
        buildTestWidget(
          tester: tester,
          injectedController: pagedController,
          viewport: const Size(1200, 1000),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Load More'), findsOneWidget);

      await tester.tap(find.text('Load More'));
      await tester.pumpAndSettle();

      expect(pagedController.state.roles.length, equals(10));
    });

    testWidgets(
      '86. Live invalidation: silent refresh without spinner flicker',
      (tester) async {
        await controller.refreshRoles();
        await controller.selectRole(roleA);
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();

        // Trigger background invalidation
        invalidationSignal.notifyAuthorizationChanged();
        await tester.pump();

        // Should not flash full loading spinner because silent: true
        expect(controller.state.isLoadingRoleDetails, isFalse);
      },
    );

    testWidgets(
      '92. RTL Arabic: renders in Arabic without overflow or direction errors',
      (tester) async {
        await controller.refreshRoles();
        await controller.selectRole(roleA);
        await tester.pumpWidget(
          buildTestWidget(tester: tester, locale: const Locale('ar')),
        );
        await tester.pumpAndSettle();

        expect(find.text('الأدوار والتحكم في الوصول'), findsOneWidget);
        expect(find.text('نظامي'), findsWidgets);
      },
    );

    testWidgets('93. Text scale: scales up 2.0x without layout overflow', (
      tester,
    ) async {
      await controller.refreshRoles();
      await controller.selectRole(roleA);
      await tester.pumpWidget(
        buildTestWidget(tester: tester, textScaleFactor: 2.0),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Responsive Matrix: Compact (<600) and Medium (800) show list first, back button returns',
      (tester) async {
        await controller.refreshRoles();
        await tester.pumpWidget(
          buildTestWidget(tester: tester, viewport: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Shows list first
        expect(find.text('Owner'), findsOneWidget);

        // Tap role -> shows detail
        await tester.tap(find.text('Owner'));
        await tester.pumpAndSettle();

        // Back button is present in collapsed mode
        expect(find.byType(AppIconButton), findsOneWidget);

        // Tap back -> returns to master list
        await tester.tap(find.byType(AppIconButton));
        await tester.pumpAndSettle();

        expect(find.text('Manager'), findsOneWidget);
      },
    );

    testWidgets('Theme Matrix: functional under dark mode', (tester) async {
      AppThemeController.toggleTheme(true);
      addTearDown(() => AppThemeController.toggleTheme(false));

      await controller.refreshRoles();
      await tester.pumpWidget(buildTestWidget(tester: tester));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Roles & Access Control'), findsOneWidget);
    });

    testWidgets(
      'Create: validates typed values, commits once, closes, and selects the role',
      (tester) async {
        await controller.refreshRoles();
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(AppButton, 'Create Role').first);
        await tester.pumpAndSettle();

        final fields = find.byType(AppTextField);
        expect(fields, findsNWidgets(4));
        await tester.enterText(fields.at(1), 'Auditor');
        await tester.enterText(fields.at(2), 'company.auditor');
        await tester.enterText(fields.at(3), 'Reviews financial activity');

        await tester.tap(find.widgetWithText(AppButton, 'Create Role').last);
        await tester.pumpAndSettle();

        expect(find.text('Reviews financial activity'), findsOneWidget);
        expect(
          controller.state.selectedRoleId,
          NexaBizRoleId('company.auditor'),
        );
        expect(
          fakeStore.recordedEvents.where(
            (event) => event == 'createCompanyRole:company.auditor',
          ),
          hasLength(1),
        );
      },
    );

    testWidgets(
      'Create failures retain input and show localized duplicate/invalid errors',
      (tester) async {
        await controller.refreshRoles();
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(AppButton, 'Create Role').first);
        await tester.pumpAndSettle();
        var fields = find.byType(AppTextField);
        await tester.enterText(fields.at(1), 'Another Manager');
        await tester.enterText(fields.at(2), 'INVALID KEY');
        await tester.tap(find.widgetWithText(AppButton, 'Create Role').last);
        await tester.pump();
        expect(
          find.textContaining('Invalid role identifier format'),
          findsOneWidget,
        );
        expect(find.text('Another Manager'), findsOneWidget);

        fields = find.byType(AppTextField);
        await tester.enterText(fields.at(2), 'company.manager');
        await tester.tap(find.widgetWithText(AppButton, 'Create Role').last);
        await tester.pumpAndSettle();
        expect(
          find.text(
            'A role with this identifier already exists in this company.',
          ),
          findsOneWidget,
        );
        expect(find.text('Another Manager'), findsOneWidget);
        expect(
          controller.state.roles.where((role) => role.roleId == roleB).length,
          1,
        );

        fields = find.byType(AppTextField);
        await tester.enterText(fields.at(1), ' manager ');
        await tester.enterText(fields.at(2), 'company.other_manager');
        await tester.tap(find.widgetWithText(AppButton, 'Create Role').last);
        await tester.pumpAndSettle();
        expect(
          find.text('A role with this name already exists in this company.'),
          findsOneWidget,
        );
        expect(find.text(' manager '), findsOneWidget);
      },
    );

    testWidgets('Edit failure retains committed metadata and editable input', (
      tester,
    ) async {
      await controller.refreshRoles();
      await controller.selectRole(roleB);
      await tester.pumpWidget(buildTestWidget(tester: tester));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AppButton, 'Edit Role'));
      await tester.pumpAndSettle();

      final fields = find.byType(AppTextField);
      await tester.enterText(fields.at(1), 'Conflicting Name');
      fakeStore.throwOnMutation =
          NexaBizAuthorizationAdministrationConflictException(
            type: NexaBizAuthorizationAdministrationConflictType
                .duplicateRoleDisplayName,
            roleId: roleB,
          );
      await tester.tap(find.widgetWithText(AppButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(
        find.text('A role with this name already exists in this company.'),
        findsOneWidget,
      );
      expect(find.text('Conflicting Name'), findsOneWidget);
      expect(
        controller.state.selectedRoleSummary!.metadata.displayName.value,
        'Manager',
      );
      expect(
        controller.state.selectedRoleDetails!.metadata.displayName.value,
        'Manager',
      );
    });

    testWidgets(
      'Edit: role key is immutable and metadata is commit-confirmed',
      (tester) async {
        await controller.refreshRoles();
        await controller.selectRole(roleB);
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(AppButton, 'Edit Role'));
        await tester.pumpAndSettle();
        final fields = find.byType(AppTextField);
        final roleKeyField = tester.widget<AppTextField>(fields.at(2));
        expect(roleKeyField.readOnly, isTrue);
        expect(roleKeyField.enabled, isFalse);
        expect(roleKeyField.controller!.text, 'company.manager');

        await tester.enterText(fields.at(1), 'Operations Manager');
        await tester.enterText(fields.at(3), 'Runs daily operations');
        await tester.tap(find.widgetWithText(AppButton, 'Save Changes'));
        await tester.pumpAndSettle();

        expect(find.text('Operations Manager'), findsWidgets);
        expect(find.text('Runs daily operations'), findsOneWidget);
        expect(controller.state.selectedRoleId, roleB);
      },
    );

    testWidgets(
      'Delete: confirms, commits, and failure retains the selected role',
      (tester) async {
        await controller.refreshRoles();
        await controller.selectRole(roleB);
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();

        fakeStore.throwOnMutation =
            NexaBizAuthorizationAdministrationConflictException(
              type: NexaBizAuthorizationAdministrationConflictType
                  .roleHasMembershipAssignments,
              roleId: roleB,
            );
        await tester.tap(find.widgetWithText(AppButton, 'Delete Role').last);
        await tester.pumpAndSettle();
        expect(
          find.text('Are you sure you want to delete role "Manager"?'),
          findsOneWidget,
        );
        await tester.tap(find.widgetWithText(AppButton, 'Delete Role').last);
        await tester.pumpAndSettle();
        expect(
          find.textContaining('members are currently assigned'),
          findsOneWidget,
        );
        expect(controller.state.selectedRoleId, roleB);
        expect(
          controller.state.roles.any((role) => role.roleId == roleB),
          isTrue,
        );

        fakeStore.throwOnMutation = null;
        await tester.tap(find.widgetWithText(AppButton, 'Delete Role').last);
        await tester.pumpAndSettle();
        expect(
          controller.state.roles.any((role) => role.roleId == roleB),
          isFalse,
        );
        expect(controller.state.selectedRoleId, isNull);
      },
    );

    testWidgets(
      'role.manage gate reacts live while policy-review content remains readable',
      (tester) async {
        await controller.refreshRoles();
        await controller.selectRole(roleB);
        await tester.pumpWidget(buildTestWidget(tester: tester));
        await tester.pumpAndSettle();
        expect(find.widgetWithText(AppButton, 'Create Role'), findsOneWidget);
        expect(find.widgetWithText(AppButton, 'Edit Role'), findsOneWidget);

        await tester.tap(find.widgetWithText(AppButton, 'Create Role'));
        await tester.pumpAndSettle();
        expect(find.text('Role Name'), findsWidgets);

        permissionEvaluator.allowRoleManagement = false;
        invalidationSignal.notifyAuthorizationChanged();
        await tester.pumpAndSettle();

        expect(find.text('Roles & Access Control'), findsOneWidget);
        expect(find.text('Manager'), findsWidgets);
        expect(find.text('Role Name'), findsWidgets);
        expect(find.widgetWithText(AppButton, 'Create Role'), findsNothing);
        expect(find.widgetWithText(AppButton, 'Edit Role'), findsNothing);
        expect(find.widgetWithText(AppButton, 'Delete Role'), findsNothing);
      },
    );

    testWidgets(
      'compact Arabic form uses a sheet, keeps technical key LTR, and scales to 2x',
      (tester) async {
        await controller.refreshRoles();
        await tester.pumpWidget(
          buildTestWidget(
            tester: tester,
            viewport: const Size(400, 800),
            locale: const Locale('ar'),
            textScaleFactor: 2,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(AppButton, 'إنشاء الدور'));
        await tester.pumpAndSettle();
        expect(find.byType(AppBottomSheet), findsOneWidget);
        expect(find.text('اسم الدور'), findsOneWidget);
        final fields = find.byType(AppTextField);
        final keyField = tester.widget<AppTextField>(fields.at(2));
        expect(keyField.textDirection, TextDirection.ltr);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('open mutation surface closes on company switch and logout', (
      tester,
    ) async {
      await controller.refreshRoles();
      await tester.pumpWidget(buildTestWidget(tester: tester));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.widgetWithText(AppButton, 'Create Role').first);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(AppDialog<void>), findsOneWidget);

      await tester.tap(find.widgetWithText(AppButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AppDialog<void>), findsNothing);
      await tester.tap(find.widgetWithText(AppButton, 'Create Role').first);
      await tester.pumpAndSettle();

      final companyB = NexaBizCompanyId('company_456');
      fakeStore.rolesByCompany[companyB.value] = [];
      final companyBSession = NexaBizSession.active(
        sessionId: 'sess_2',
        userId: NexaBizUserId('usr_1'),
        membershipId: NexaBizMembershipId('mem_2'),
        companyId: companyB,
        companyName: 'Company B',
        role: 'reviewer',
      );
      await controller.updateContext(
        NexaBizCompanyAuthorizationContext.fromSession(companyBSession),
      );
      await tester.pump();
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(controller.state.companyId, companyB);
      expect(find.byType(AppDialog<void>), findsNothing);

      sessionController.setSessionForTesting(companyBSession);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AppButton, 'Create Role').first);
      await tester.pumpAndSettle();
      sessionController.logout();
      controller.handleLogout();
      await tester.pump();
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byType(AppDialog<void>), findsNothing);
      expect(controller.state.companyId, isNull);
    });

    testWidgets('rapid create activation reaches the mutation store once', (
      tester,
    ) async {
      await controller.refreshRoles();
      await tester.pumpWidget(buildTestWidget(tester: tester));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AppButton, 'Create Role').first);
      await tester.pumpAndSettle();
      final fields = find.byType(AppTextField);
      await tester.enterText(fields.at(1), 'Cashier');
      await tester.enterText(fields.at(2), 'company.cashier');
      fakeStore.mutationDelayCompleter = Completer<void>();

      final submit = find.widgetWithText(AppButton, 'Create Role').last;
      await tester.tap(submit);
      await tester.tap(submit);
      await tester.pump();
      expect(
        fakeStore.recordedEvents.where(
          (event) => event == 'createCompanyRole:company.cashier',
        ),
        hasLength(1),
      );

      fakeStore.mutationDelayCompleter!.complete();
      await tester.pumpAndSettle();
    });
  });
}
