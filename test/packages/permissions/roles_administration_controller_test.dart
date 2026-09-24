import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/authorization/nexabiz_authorization_administration.dart';
import 'package:nexabiz/app/authorization/nexabiz_authorization_invalidation_signal.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_errors.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_models.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_store.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_context.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_id.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_catalog.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_guard.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/roles/nexabiz_role_id.dart';
import 'package:nexabiz/core/session/nexabiz_session.dart';
import 'package:nexabiz/l10n/app_localizations_ar.dart';
import 'package:nexabiz/l10n/app_localizations_en.dart';
import 'package:nexabiz/packages/permissions/presentation/controllers/roles_administration_controller.dart';

// ---------------------------------------------------------------------------
// Controllable Test Double for Authorization Administration Stores
// ---------------------------------------------------------------------------

final class FakePermissionGuard implements NexaBizPermissionGuard {
  const FakePermissionGuard();
  @override
  Future<void> requirePermission({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  }) async {}
}

class FakeAdminStore implements NexaBizAuthorizationAdministrationStore {
  final Map<String, List<NexaBizCompanyRoleSummary>> rolesByCompany = {};
  final Map<String, NexaBizCompanyRoleDetails> roleDetailsByRole = {};
  final Map<String, Set<NexaBizPermissionId>> permissionsByRole = {};
  final Map<String, List<NexaBizMembershipRoleAssignment>> assignmentsByRole =
      {};
  final Map<String, List<NexaBizAssignableMembership>> assignablesByRole = {};
  final List<String> recordedEvents = [];
  Completer<void>? delayCompleter;
  Completer<void>? mutationDelayCompleter;
  final Map<NexaBizPermissionId, Completer<void>> permissionMutationCompleters =
      {};
  final Map<NexaBizMembershipId, Completer<void>> membershipMutationCompleters =
      {};
  final Map<String?, Completer<void>> assignableQueryCompleters = {};
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

  NexaBizAssignableMembership dummyAssignable({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
    required NexaBizUserId userId,
    String name = 'Candidate User',
  }) {
    return NexaBizAssignableMembership(
      companyId: companyId,
      membershipId: membershipId,
      userId: userId,
      userName: name,
      userEmail: '$name@example.com',
      membershipIsActive: true,
      userIsActive: true,
      joinedAt: DateTime.utc(2026, 1, 1),
    );
  }

  NexaBizMembershipRoleAssignment dummyAssignment({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
    required NexaBizUserId userId,
    required NexaBizRoleId roleId,
    String name = 'Assigned User',
  }) {
    return NexaBizMembershipRoleAssignment(
      companyId: companyId,
      membershipId: membershipId,
      userId: userId,
      roleId: roleId,
      userName: name,
      userEmail: '$name@example.com',
      membershipIsActive: true,
      userIsActive: true,
      assignedAt: DateTime.utc(2026, 1, 1),
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

    final existing = roleDetailsByRole[roleId.value];
    if (existing != null) return existing;

    final roleExists = (rolesByCompany[companyId.value] ?? []).any(
      (role) => role.roleId == roleId,
    );
    if (!roleExists) {
      throw NexaBizRoleNotFoundException(companyId: companyId, roleId: roleId);
    }

    return NexaBizCompanyRoleDetails(
      companyId: companyId,
      roleId: roleId,
      metadata: NexaBizRoleMetadata(
        displayName: NexaBizRoleDisplayName('Role ${roleId.value}'),
      ),
      kind: NexaBizCompanyRoleKind.custom,
      membershipAssignmentCount: assignmentsByRole[roleId.value]?.length ?? 0,
      permissionAssignmentCount: permissionsByRole[roleId.value]?.length ?? 0,
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

    final granted = permissionsByRole[roleId.value] ?? {};
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

    final list = assignmentsByRole[roleId.value] ?? [];
    final start = page.cursor == null
        ? 0
        : list.indexWhere(
                (member) => member.membershipId.value == page.cursor,
              ) +
              1;
    final items = list.skip(start).take(page.limit).toList();
    final hasMore = start + page.limit < list.length;
    return NexaBizAuthorizationAdministrationPage(
      items: items,
      nextCursor: hasMore && items.isNotEmpty
          ? items.last.membershipId.value
          : null,
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
    if (assignableQueryCompleters[search] case final completer?) {
      await completer.future;
    }
    if (delayCompleter != null) await delayCompleter!.future;
    if (throwOnQuery != null) throw throwOnQuery!;

    var list = assignablesByRole[roleId.value] ?? [];
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

    final start = page.cursor == null
        ? 0
        : list.indexWhere(
                (member) => member.membershipId.value == page.cursor,
              ) +
              1;
    final items = list.skip(start).take(page.limit).toList();
    final hasMore = start + page.limit < list.length;
    return NexaBizAuthorizationAdministrationPage(
      items: items,
      nextCursor: hasMore && items.isNotEmpty
          ? items.last.membershipId.value
          : null,
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
    if (mutationDelayCompleter != null) await mutationDelayCompleter!.future;
    if (throwOnMutation != null) throw throwOnMutation!;

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

    roleDetailsByRole[roleId.value] = details;
    rolesByCompany
        .putIfAbsent(companyId.value, () => [])
        .add(
          NexaBizCompanyRoleSummary(
            companyId: companyId,
            roleId: roleId,
            metadata: metadata,
            kind: NexaBizCompanyRoleKind.custom,
            membershipAssignmentCount: 0,
          ),
        );
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
    if (mutationDelayCompleter != null) await mutationDelayCompleter!.future;
    if (throwOnMutation != null) throw throwOnMutation!;

    final current = roleDetailsByRole[roleId.value]!;
    final updated = NexaBizCompanyRoleDetails(
      companyId: companyId,
      roleId: roleId,
      metadata: metadata,
      kind: current.kind,
      membershipAssignmentCount: current.membershipAssignmentCount,
      permissionAssignmentCount: current.permissionAssignmentCount,
      createdAt: current.createdAt,
      updatedAt: DateTime.utc(2026, 1, 2),
    );
    roleDetailsByRole[roleId.value] = updated;

    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: current,
      after: updated,
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
    if (mutationDelayCompleter != null) await mutationDelayCompleter!.future;
    if (throwOnMutation != null) throw throwOnMutation!;

    final current = roleDetailsByRole.remove(roleId.value);
    rolesByCompany[companyId.value]?.removeWhere((r) => r.roleId == roleId);

    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: current,
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
    recordedEvents.add('grantPermission:${permissionId.value}');
    if (permissionMutationCompleters[permissionId] case final completer?) {
      await completer.future;
    }
    if (mutationDelayCompleter != null) await mutationDelayCompleter!.future;
    if (throwOnMutation != null) throw throwOnMutation!;

    permissionsByRole.putIfAbsent(roleId.value, () => {}).add(permissionId);

    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: null,
      after: NexaBizRolePermissionAssignment(
        companyId: companyId,
        roleId: roleId,
        permissionId: permissionId,
        assignedAt: DateTime.utc(2026, 1, 1),
      ),
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
    recordedEvents.add('revokePermission:${permissionId.value}');
    if (permissionMutationCompleters[permissionId] case final completer?) {
      await completer.future;
    }
    if (mutationDelayCompleter != null) await mutationDelayCompleter!.future;
    if (throwOnMutation != null) throw throwOnMutation!;

    permissionsByRole[roleId.value]?.remove(permissionId);

    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: NexaBizRolePermissionAssignment(
        companyId: companyId,
        roleId: roleId,
        permissionId: permissionId,
        assignedAt: DateTime.utc(2026, 1, 1),
      ),
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
    recordedEvents.add('assignRoleToMembership:${membershipId.value}');
    if (membershipMutationCompleters[membershipId] case final completer?) {
      await completer.future;
    }
    if (mutationDelayCompleter != null) await mutationDelayCompleter!.future;
    if (throwOnMutation != null) throw throwOnMutation!;

    final assignment = NexaBizMembershipRoleAssignment(
      companyId: companyId,
      membershipId: membershipId,
      userId: NexaBizUserId('usr-1'),
      roleId: roleId,
      membershipIsActive: true,
      userIsActive: true,
      assignedAt: DateTime.utc(2026, 1, 1),
    );

    assignmentsByRole.putIfAbsent(roleId.value, () => []).add(assignment);
    assignablesByRole[roleId.value]?.removeWhere(
      (m) => m.membershipId == membershipId,
    );

    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: null,
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
    recordedEvents.add('unassignRoleFromMembership:${membershipId.value}');
    if (membershipMutationCompleters[membershipId] case final completer?) {
      await completer.future;
    }
    if (mutationDelayCompleter != null) await mutationDelayCompleter!.future;
    if (throwOnMutation != null) throw throwOnMutation!;

    final current = assignmentsByRole[roleId.value]?.firstWhere(
      (m) => m.membershipId == membershipId,
    );
    assignmentsByRole[roleId.value]?.removeWhere(
      (m) => m.membershipId == membershipId,
    );

    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: NexaBizAuthorizationAdministrationMutationOutcome.changed,
      before: current,
      after: null,
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
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  final l10nEn = AppLocalizationsEn();
  final l10nAr = AppLocalizationsAr();

  final companyA = NexaBizCompanyId('company-a');
  final companyB = NexaBizCompanyId('company-b');
  final user1 = NexaBizUserId('user-1');
  final membershipA = NexaBizMembershipId('member-a-1');
  final membershipB = NexaBizMembershipId('member-b-1');

  final contextA = NexaBizCompanyAuthorizationContext(
    userId: user1,
    companyId: companyA,
    membershipId: membershipA,
  );

  final contextB = NexaBizCompanyAuthorizationContext(
    userId: user1,
    companyId: companyB,
    membershipId: membershipB,
  );

  final role1 = NexaBizRoleId('company.accountant');
  final role2 = NexaBizRoleId('company.viewer');
  final permissionView = NexaBizPermissionId('company.profile.view');
  final permissionManage = NexaBizPermissionId('company.profile.manage');

  final canonicalCatalog = NexaBizImmutablePermissionCatalog({
    permissionView,
    permissionManage,
    NexaBizPermissionId('company.membership.view'),
    NexaBizPermissionId('identity.session.view'),
    NexaBizPermissionId('identity.user.manage'),
    NexaBizPermissionId('permissions.catalog.view'),
    NexaBizPermissionId('permissions.policy.review'),
    NexaBizPermissionId('permissions.role.manage'),
    NexaBizPermissionId('permissions.policy.manage'),
    NexaBizPermissionId('permissions.assignment.manage'),
  });

  late FakeAdminStore store;
  late NexaBizAuthorizationAdministration administration;
  late NexaBizAuthorizationInvalidationSignal invalidationSignal;
  late RolesAdministrationController controller;

  setUp(() {
    store = FakeAdminStore();
    invalidationSignal = NexaBizAuthorizationInvalidationSignal();

    administration = NexaBizAuthorizationAdministration.create(
      permissionGuard: const FakePermissionGuard(),
      queryStore: store,
      mutationStore: store,
      invalidationSignal: invalidationSignal,
      permissionCatalog: canonicalCatalog,
    );

    // Seed roles in company A
    store.rolesByCompany[companyA.value] = [
      store.dummySummary(
        companyId: companyA,
        roleId: role1,
        name: 'Accountant',
      ),
      store.dummySummary(companyId: companyA, roleId: role2, name: 'Viewer'),
    ];

    controller = RolesAdministrationController(
      administration: administration,
      initialContext: contextA,
      invalidationSignal: invalidationSignal,
    );
  });

  tearDown(() {
    controller.dispose();
  });

  group('RolesAdministrationController Initial State & Load', () {
    test('initial state before initialize() is safe to render', () {
      final uninitController = RolesAdministrationController(
        administration: administration,
        initialContext: contextA,
      );

      final state = uninitController.state;
      expect(state.isInitialized, isFalse);
      expect(state.roles, isEmpty);
      expect(state.hasSelectedRole, isFalse);
      expect(state.isLoadingRoles, isFalse);
      expect(state.rolesError, isNull);
      expect(state.isCreatingRole, isFalse);
      expect(state.mutationError, isNull);

      uninitController.dispose();
    });

    test(
      'initialize() loads roles and declared catalog with deterministic sort order',
      () async {
        await controller.initialize();

        final state = controller.state;
        expect(state.isInitialized, isTrue);
        expect(state.roles, hasLength(2));
        expect(state.roles.first.roleId, equals(role1));
        expect(state.isCatalogLoaded, isTrue);
        expect(state.declaredCatalog, hasLength(10));

        // Deterministic sort: company group first, then identity, then authorization
        expect(
          state.declaredCatalog.first.permissionId.value,
          equals('company.profile.view'),
        );
      },
    );
  });

  group('Role Selection & Details Lifecycle', () {
    test(
      'selectRole() concurrently loads details, permissions, and assigned members',
      () async {
        store.permissionsByRole[role1.value] = {permissionView};
        store.assignmentsByRole[role1.value] = [
          NexaBizMembershipRoleAssignment(
            companyId: companyA,
            membershipId: membershipA,
            userId: user1,
            roleId: role1,
            membershipIsActive: true,
            userIsActive: true,
            assignedAt: DateTime.utc(2026, 1, 1),
          ),
        ];

        await controller.initialize();
        await controller.selectRole(role1);

        final state = controller.state;
        expect(state.hasSelectedRole, isTrue);
        expect(state.selectedRoleId, equals(role1));
        expect(state.selectedRoleDetails, isNotNull);
        expect(state.selectedRoleDetails!.roleId, equals(role1));
        expect(state.assignedMembers, hasLength(1));

        // Verify permission composition
        final permViewItem = state.selectedRolePermissions.firstWhere(
          (p) => p.permissionId == permissionView,
        );
        expect(permViewItem.isGranted, isTrue);
        expect(permViewItem.isPending, isFalse);

        final permManageItem = state.selectedRolePermissions.firstWhere(
          (p) => p.permissionId == permissionManage,
        );
        expect(permManageItem.isGranted, isFalse);
      },
    );

    test('clearSelectedRole() resets detail state and selection', () async {
      await controller.initialize();
      await controller.selectRole(role1);
      expect(controller.state.hasSelectedRole, isTrue);

      controller.clearSelectedRole();
      expect(controller.state.hasSelectedRole, isFalse);
      expect(controller.state.selectedRoleId, isNull);
      expect(controller.state.selectedRoleDetails, isNull);
      expect(controller.state.selectedRolePermissions, isEmpty);
      expect(controller.state.assignedMembers, isEmpty);
    });
  });

  group('Race Safety: Role Selection, Search & Company Switch', () {
    test(
      'selection race: late response from Role A is dropped when Role B selected',
      () async {
        await controller.initialize();

        // Slow down Role A query
        final roleACompleter = Completer<void>();
        store.delayCompleter = roleACompleter;

        final selectAFuture = controller.selectRole(role1);
        expect(controller.state.selectedRoleId, equals(role1));

        // Quickly select Role B
        store.delayCompleter = null; // Role B completes immediately
        await controller.selectRole(role2);
        expect(controller.state.selectedRoleId, equals(role2));

        // Now complete Role A late
        roleACompleter.complete();
        await selectAFuture;

        // State MUST still show Role B
        expect(controller.state.selectedRoleId, equals(role2));
        expect(controller.state.selectedRoleDetails!.roleId, equals(role2));
      },
    );

    test(
      'search race: late response from earlier search query is discarded',
      () async {
        await controller.initialize();

        final searchACompleter = Completer<void>();
        store.delayCompleter = searchACompleter;

        final searchAFuture = controller.searchRoles('Acc');

        // Search 'View' immediately with no delay
        store.delayCompleter = null;
        await controller.searchRoles('View');
        expect(controller.state.roles, hasLength(1));
        expect(controller.state.roles.first.roleId, equals(role2));

        // Complete slow search
        searchACompleter.complete();
        await searchAFuture;

        // State must retain 'View' results
        expect(controller.state.roles, hasLength(1));
        expect(controller.state.roles.first.roleId, equals(role2));
        expect(controller.state.roleSearchQuery, equals('View'));
      },
    );

    test(
      'company switch race: pending requests from Company A are dropped when switching to B',
      () async {
        store.rolesByCompany[companyB.value] = [
          store.dummySummary(
            companyId: companyB,
            roleId: NexaBizRoleId('company.b_role'),
            name: 'B Role',
          ),
        ];

        final companyACompleter = Completer<void>();
        store.delayCompleter = companyACompleter;

        final initAFuture = controller.initialize();

        // Session/context switches to Company B
        store.delayCompleter = null;
        await controller.updateContext(contextB);
        expect(controller.state.companyId, equals(companyB));
        expect(
          controller.state.roles.map((r) => r.roleId.value),
          contains('company.b_role'),
        );

        // Complete Company A response late
        companyACompleter.complete();
        await initAFuture;

        // Data from Company A must NOT appear
        expect(controller.state.companyId, equals(companyB));
        expect(
          controller.state.roles.map((r) => r.roleId.value),
          isNot(contains('company.accountant')),
        );
      },
    );

    test(
      'session logout: clears sensitive role/member state and discards in-flight responses',
      () async {
        final queryCompleter = Completer<void>();
        store.delayCompleter = queryCompleter;

        final initFuture = controller.initialize();

        // User logs out
        controller.handleLogout();
        expect(controller.currentContext, isNull);
        expect(controller.state.roles, isEmpty);
        expect(controller.state.companyId, isNull);

        // Late response finishes
        queryCompleter.complete();
        await initFuture;

        expect(controller.state.roles, isEmpty);
        expect(controller.state.companyId, isNull);
      },
    );

    test(
      'dispose safety: in-flight completions after dispose trigger no errors or notifications',
      () async {
        final completer = Completer<void>();
        store.delayCompleter = completer;

        final future = controller.initialize();
        controller.dispose();

        completer.complete();
        await future; // Must complete cleanly without throwing FlutterError
      },
    );
  });

  group('Commit-Confirmed Mutations & Double-Submit Protection', () {
    test(
      'createRole prevents double submit and updates committed role list',
      () async {
        await controller.initialize();
        final newRoleId = NexaBizRoleId('company.auditor');
        final newName = NexaBizRoleDisplayName('Auditor');

        var notificationCount = 0;
        controller.addListener(() => notificationCount++);

        final f1 = controller.createRole(
          roleId: newRoleId,
          displayName: newName,
        );
        final f2 = controller.createRole(
          roleId: newRoleId,
          displayName: newName,
        ); // Duplicate call

        final res2 = await f2;
        expect(
          res2,
          isFalse,
          reason: 'Duplicate create submission must be rejected',
        );

        final res1 = await f1;
        expect(res1, isTrue);

        expect(
          controller.state.roles.any((r) => r.roleId == newRoleId),
          isTrue,
        );
        expect(controller.state.isCreatingRole, isFalse);
        expect(notificationCount, greaterThan(0));
      },
    );

    test('company switch drops an in-flight create completion', () async {
      await controller.initialize();
      store.rolesByCompany[companyB.value] = [];
      store.mutationDelayCompleter = Completer<void>();

      final future = controller.createRole(
        roleId: NexaBizRoleId('company.cashier'),
        displayName: NexaBizRoleDisplayName('Cashier'),
      );
      await controller.updateContext(contextB);
      store.mutationDelayCompleter!.complete();

      expect(await future, isFalse);
      expect(controller.state.companyId, companyB);
      expect(
        controller.state.roles.any(
          (role) => role.roleId.value == 'company.cashier',
        ),
        isFalse,
      );
      expect(controller.state.isCreatingRole, isFalse);
    });

    test('company switch drops an in-flight metadata update', () async {
      await controller.initialize();
      await controller.selectRole(role1);
      store.rolesByCompany[companyB.value] = [];
      store.mutationDelayCompleter = Completer<void>();

      final future = controller.updateRoleMetadata(
        roleId: role1,
        displayName: NexaBizRoleDisplayName('Changed in A'),
      );
      await controller.updateContext(contextB);
      store.mutationDelayCompleter!.complete();

      expect(await future, isFalse);
      expect(controller.state.companyId, companyB);
      expect(controller.state.selectedRoleId, isNull);
      expect(controller.state.isUpdatingRole, isFalse);
    });

    test('company switch drops an in-flight delete completion', () async {
      await controller.initialize();
      await controller.selectRole(role1);
      store.rolesByCompany[companyB.value] = [];
      store.mutationDelayCompleter = Completer<void>();

      final future = controller.deleteRole(role1);
      await controller.updateContext(contextB);
      store.mutationDelayCompleter!.complete();

      expect(await future, isFalse);
      expect(controller.state.companyId, companyB);
      expect(controller.state.selectedRoleId, isNull);
      expect(controller.state.isDeletingRole, isFalse);
    });

    test(
      'grantPermission: sequencing guard drops duplicate call; commits grant on success',
      () async {
        await controller.initialize();
        await controller.selectRole(role1);

        final f1 = controller.grantPermission(permissionView);
        final f2 = controller.grantPermission(permissionView);

        expect(await f2, isFalse); // Second is dropped
        expect(await f1, isTrue);

        final perm = controller.state.selectedRolePermissions.firstWhere(
          (p) => p.permissionId == permissionView,
        );
        expect(perm.isGranted, isTrue);
        expect(perm.isPending, isFalse);
      },
    );

    test(
      'grantPermission rollback: retains false grant state and exposes typed error on failure',
      () async {
        await controller.initialize();
        await controller.selectRole(role1);

        store.throwOnMutation = NexaBizBuiltInRoleProtectedException(
          roleId: role1,
          action: NexaBizBuiltInRoleProtectedAction.grantPermission,
        );

        final success = await controller.grantPermission(permissionView);
        expect(success, isFalse);

        final perm = controller.state.selectedRolePermissions.firstWhere(
          (p) => p.permissionId == permissionView,
        );
        expect(perm.isGranted, isFalse); // Rolled back / retained false
        expect(perm.isPending, isFalse);

        expect(controller.state.mutationError, isNotNull);
        expect(
          controller.state.mutationError!.resolveMessage(l10nEn),
          equals(l10nEn.authAdminErrorBuiltInPermissions),
        );
        expect(
          controller.state.mutationError!.resolveMessage(l10nAr),
          equals(l10nAr.authAdminErrorBuiltInPermissions),
        );
        expect(controller.state.mutationError!.permissionId, permissionView);
      },
    );

    test('direct revoke failure retains the granted permission', () async {
      store.permissionsByRole[role1.value] = {permissionView};
      await controller.initialize();
      await controller.selectRole(role1);
      store.throwOnMutation = NexaBizBuiltInRoleProtectedException(
        roleId: role1,
        action: NexaBizBuiltInRoleProtectedAction.revokePermission,
      );

      expect(await controller.revokePermission(permissionView), isFalse);
      expect(controller.state.isPermissionGranted(permissionView), isTrue);
      expect(controller.state.pendingPermissionIds, isEmpty);
      expect(controller.state.mutationError?.permissionId, permissionView);
    });

    test('role switch drops a late permission mutation completion', () async {
      await controller.initialize();
      await controller.selectRole(role1);
      final completer = Completer<void>();
      store.permissionMutationCompleters[permissionView] = completer;

      final future = controller.grantPermission(permissionView);
      expect(controller.state.isPermissionPending(permissionView), isTrue);

      await controller.selectRole(role2);
      expect(controller.state.pendingPermissionIds, isEmpty);
      completer.complete();

      expect(await future, isFalse);
      expect(controller.state.selectedRoleId, role2);
      expect(controller.state.isPermissionGranted(permissionView), isFalse);
    });

    test(
      'company switch drops a late permission mutation completion',
      () async {
        await controller.initialize();
        await controller.selectRole(role1);
        store.rolesByCompany[companyB.value] = [];
        final completer = Completer<void>();
        store.permissionMutationCompleters[permissionView] = completer;

        final future = controller.grantPermission(permissionView);
        await controller.updateContext(contextB);
        completer.complete();

        expect(await future, isFalse);
        expect(controller.state.companyId, companyB);
        expect(controller.state.selectedRoleId, isNull);
        expect(controller.state.pendingPermissionIds, isEmpty);
      },
    );

    test('logout drops a late permission mutation completion', () async {
      await controller.initialize();
      await controller.selectRole(role1);
      final completer = Completer<void>();
      store.permissionMutationCompleters[permissionView] = completer;

      final future = controller.grantPermission(permissionView);
      controller.handleLogout();
      completer.complete();

      expect(await future, isFalse);
      expect(controller.state.companyId, isNull);
      expect(controller.state.selectedRolePermissions, isEmpty);
      expect(controller.state.pendingPermissionIds, isEmpty);
    });

    test(
      'dispose drops a late permission completion without notifying',
      () async {
        await controller.initialize();
        await controller.selectRole(role1);
        final completer = Completer<void>();
        store.permissionMutationCompleters[permissionView] = completer;
        var notificationCount = 0;
        controller.addListener(() => notificationCount++);

        final future = controller.grantPermission(permissionView);
        final countBeforeDispose = notificationCount;
        controller.dispose();
        completer.complete();

        expect(await future, isFalse);
        expect(notificationCount, countBeforeDispose);
      },
    );

    test(
      'different permission mutations complete independently out of order',
      () async {
        await controller.initialize();
        await controller.selectRole(role1);
        final firstCompleter = Completer<void>();
        final secondCompleter = Completer<void>();
        store.permissionMutationCompleters[permissionView] = firstCompleter;
        store.permissionMutationCompleters[permissionManage] = secondCompleter;

        final first = controller.grantPermission(permissionView);
        final second = controller.grantPermission(permissionManage);
        expect(
          controller.state.pendingPermissionIds,
          containsAll([permissionView, permissionManage]),
        );

        secondCompleter.complete();
        expect(await second, isTrue);
        expect(controller.state.isPermissionGranted(permissionManage), isTrue);
        expect(controller.state.isPermissionPending(permissionView), isTrue);

        firstCompleter.complete();
        expect(await first, isTrue);
        expect(controller.state.isPermissionGranted(permissionView), isTrue);
        expect(controller.state.pendingPermissionIds, isEmpty);
      },
    );

    test(
      'external invalidation during permission mutation reaches final canonical state',
      () async {
        await controller.initialize();
        await controller.selectRole(role1);
        final completer = Completer<void>();
        store.permissionMutationCompleters[permissionView] = completer;

        final mutation = controller.grantPermission(permissionView);
        invalidationSignal.notifyAuthorizationChanged();
        await Future<void>.delayed(Duration.zero);
        expect(controller.state.isPermissionPending(permissionView), isTrue);

        completer.complete();
        expect(await mutation, isTrue);
        await Future<void>.delayed(Duration.zero);

        expect(controller.state.isPermissionGranted(permissionView), isTrue);
        expect(controller.state.pendingPermissionIds, isEmpty);
      },
    );

    test(
      'role deletion during permission mutation cannot resurrect details',
      () async {
        await controller.initialize();
        await controller.selectRole(role1);
        final completer = Completer<void>();
        store.permissionMutationCompleters[permissionView] = completer;

        final mutation = controller.grantPermission(permissionView);
        store.rolesByCompany[companyA.value]!.removeWhere(
          (role) => role.roleId == role1,
        );
        invalidationSignal.notifyAuthorizationChanged();
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        completer.complete();
        expect(await mutation, isFalse);
        await Future<void>.delayed(Duration.zero);
        expect(controller.state.selectedRoleId, isNull);
        expect(controller.state.selectedRoleDetails, isNull);
        expect(controller.state.selectedRolePermissions, isEmpty);
      },
    );

    test(
      'unassignMember rollback: Last Owner rejection retains member in assigned list',
      () async {
        final ownerRole = NexaBizRoleId('company.owner');
        store.rolesByCompany[companyA.value]!.add(
          store.dummySummary(
            companyId: companyA,
            roleId: ownerRole,
            name: 'Owner',
            kind: NexaBizCompanyRoleKind.builtIn,
          ),
        );
        final ownerAssignment = NexaBizMembershipRoleAssignment(
          companyId: companyA,
          membershipId: membershipA,
          userId: user1,
          roleId: ownerRole,
          membershipIsActive: true,
          userIsActive: true,
          assignedAt: DateTime.utc(2026, 1, 1),
        );
        store.assignmentsByRole[ownerRole.value] = [ownerAssignment];

        await controller.initialize();
        await controller.selectRole(ownerRole);

        // Simulate last owner error from domain
        store.throwOnMutation = NexaBizLastOwnerProtectedException(companyA);

        final success = await controller.unassignMember(membershipA);
        expect(success, isFalse);

        // Member remains assigned!
        expect(controller.state.assignedMembers, hasLength(1));
        expect(
          controller.state.assignedMembers.first.membershipId,
          equals(membershipA),
        );

        // Actionable error message
        expect(
          controller.state.mutationError!.resolveMessage(l10nEn),
          contains('Assign another active owner first'),
        );
        expect(
          controller.state.mutationError!.resolveMessage(l10nAr),
          contains('يجب تعيين مالك نشط آخر'),
        );
      },
    );

    test('role switch drops a late membership assignment completion', () async {
      final candidateId = NexaBizMembershipId('member-role-switch');
      store.assignablesByRole[role1.value] = [
        store.dummyAssignable(
          companyId: companyA,
          membershipId: candidateId,
          userId: NexaBizUserId('user-role-switch'),
        ),
      ];
      await controller.initialize();
      await controller.selectRole(role1);
      await controller.loadAssignableMembers();
      final completer = Completer<void>();
      store.membershipMutationCompleters[candidateId] = completer;

      final mutation = controller.assignMember(candidateId);
      expect(controller.state.isMembershipPending(candidateId), isTrue);

      await controller.selectRole(role2);
      expect(controller.state.pendingMembershipIds, isEmpty);
      completer.complete();

      expect(await mutation, isFalse);
      expect(controller.state.selectedRoleId, role2);
      expect(
        controller.state.assignedMembers.any(
          (member) => member.membershipId == candidateId,
        ),
        isFalse,
      );
    });

    test(
      'role switch drops a late membership unassignment completion',
      () async {
        store.assignmentsByRole[role1.value] = [
          store.dummyAssignment(
            companyId: companyA,
            membershipId: membershipA,
            userId: user1,
            roleId: role1,
          ),
        ];
        await controller.initialize();
        await controller.selectRole(role1);
        final completer = Completer<void>();
        store.membershipMutationCompleters[membershipA] = completer;

        final mutation = controller.unassignMember(membershipA);
        await controller.selectRole(role2);
        completer.complete();

        expect(await mutation, isFalse);
        expect(controller.state.selectedRoleId, role2);
        expect(controller.state.assignedMembers, isEmpty);
        expect(controller.state.pendingMembershipIds, isEmpty);
      },
    );

    test(
      'starting another member mutation preserves an unrelated error',
      () async {
        final firstId = NexaBizMembershipId('member-error-first');
        final secondId = NexaBizMembershipId('member-error-second');
        store.assignablesByRole[role1.value] = [
          store.dummyAssignable(
            companyId: companyA,
            membershipId: firstId,
            userId: NexaBizUserId('user-error-first'),
          ),
          store.dummyAssignable(
            companyId: companyA,
            membershipId: secondId,
            userId: NexaBizUserId('user-error-second'),
          ),
        ];
        await controller.initialize();
        await controller.selectRole(role1);
        await controller.loadAssignableMembers();
        store.throwOnMutation = NexaBizMembershipIneligibleException(
          membershipId: firstId,
          reason: NexaBizMembershipIneligibilityReason.inactiveMembership,
        );

        expect(await controller.assignMember(firstId), isFalse);
        expect(controller.state.mutationError?.membershipId, firstId);

        store.throwOnMutation = null;
        final completer = Completer<void>();
        store.membershipMutationCompleters[secondId] = completer;
        final secondMutation = controller.assignMember(secondId);

        expect(controller.state.mutationError?.membershipId, firstId);
        completer.complete();
        expect(await secondMutation, isTrue);
      },
    );

    test('company switch drops late assign and unassign completions', () async {
      final candidateId = NexaBizMembershipId('member-company-switch');
      store.assignablesByRole[role1.value] = [
        store.dummyAssignable(
          companyId: companyA,
          membershipId: candidateId,
          userId: NexaBizUserId('user-company-switch'),
        ),
      ];
      store.assignmentsByRole[role1.value] = [
        store.dummyAssignment(
          companyId: companyA,
          membershipId: membershipA,
          userId: user1,
          roleId: role1,
        ),
      ];
      store.rolesByCompany[companyB.value] = [];
      await controller.initialize();
      await controller.selectRole(role1);
      await controller.loadAssignableMembers();
      final assignCompleter = Completer<void>();
      final unassignCompleter = Completer<void>();
      store.membershipMutationCompleters[candidateId] = assignCompleter;
      store.membershipMutationCompleters[membershipA] = unassignCompleter;

      final assign = controller.assignMember(candidateId);
      final unassign = controller.unassignMember(membershipA);
      await controller.updateContext(contextB);
      assignCompleter.complete();
      unassignCompleter.complete();

      expect(await assign, isFalse);
      expect(await unassign, isFalse);
      expect(controller.state.companyId, companyB);
      expect(controller.state.pendingMembershipIds, isEmpty);
      expect(controller.state.assignedMembers, isEmpty);
    });

    test('logout drops a late membership mutation completion', () async {
      final candidateId = NexaBizMembershipId('member-logout');
      store.assignablesByRole[role1.value] = [
        store.dummyAssignable(
          companyId: companyA,
          membershipId: candidateId,
          userId: NexaBizUserId('user-logout'),
        ),
      ];
      await controller.initialize();
      await controller.selectRole(role1);
      await controller.loadAssignableMembers();
      final completer = Completer<void>();
      store.membershipMutationCompleters[candidateId] = completer;

      final mutation = controller.assignMember(candidateId);
      controller.handleLogout();
      completer.complete();

      expect(await mutation, isFalse);
      expect(controller.state.companyId, isNull);
      expect(controller.state.pendingMembershipIds, isEmpty);
      expect(controller.state.assignedMembers, isEmpty);
    });

    test(
      'dispose drops a late membership completion without notifying',
      () async {
        final candidateId = NexaBizMembershipId('member-dispose');
        store.assignablesByRole[role1.value] = [
          store.dummyAssignable(
            companyId: companyA,
            membershipId: candidateId,
            userId: NexaBizUserId('user-dispose'),
          ),
        ];
        await controller.initialize();
        await controller.selectRole(role1);
        await controller.loadAssignableMembers();
        final completer = Completer<void>();
        store.membershipMutationCompleters[candidateId] = completer;
        var notificationCount = 0;
        controller.addListener(() => notificationCount++);

        final mutation = controller.assignMember(candidateId);
        final countBeforeDispose = notificationCount;
        controller.dispose();
        completer.complete();

        expect(await mutation, isFalse);
        expect(notificationCount, countBeforeDispose);
      },
    );

    test(
      'different membership mutations complete independently out of order',
      () async {
        final firstId = NexaBizMembershipId('member-overlap-first');
        final secondId = NexaBizMembershipId('member-overlap-second');
        store.assignablesByRole[role1.value] = [
          store.dummyAssignable(
            companyId: companyA,
            membershipId: firstId,
            userId: NexaBizUserId('user-overlap-first'),
          ),
          store.dummyAssignable(
            companyId: companyA,
            membershipId: secondId,
            userId: NexaBizUserId('user-overlap-second'),
          ),
        ];
        await controller.initialize();
        await controller.selectRole(role1);
        await controller.loadAssignableMembers();
        final firstCompleter = Completer<void>();
        final secondCompleter = Completer<void>();
        store.membershipMutationCompleters[firstId] = firstCompleter;
        store.membershipMutationCompleters[secondId] = secondCompleter;

        final first = controller.assignMember(firstId);
        final second = controller.assignMember(secondId);
        expect(
          controller.state.pendingMembershipIds,
          containsAll([firstId, secondId]),
        );

        secondCompleter.complete();
        expect(await second, isTrue);
        expect(controller.state.isMembershipPending(firstId), isTrue);
        firstCompleter.complete();
        expect(await first, isTrue);
        expect(controller.state.pendingMembershipIds, isEmpty);
        expect(
          controller.state.assignedMembers.map((item) => item.membershipId),
          containsAll([firstId, secondId]),
        );
      },
    );

    test('assign and unassign different memberships may overlap', () async {
      final candidateId = NexaBizMembershipId('member-mixed-assign');
      store.assignablesByRole[role1.value] = [
        store.dummyAssignable(
          companyId: companyA,
          membershipId: candidateId,
          userId: NexaBizUserId('user-mixed-assign'),
        ),
      ];
      store.assignmentsByRole[role1.value] = [
        store.dummyAssignment(
          companyId: companyA,
          membershipId: membershipA,
          userId: user1,
          roleId: role1,
        ),
      ];
      await controller.initialize();
      await controller.selectRole(role1);
      await controller.loadAssignableMembers();
      final assignCompleter = Completer<void>();
      final unassignCompleter = Completer<void>();
      store.membershipMutationCompleters[candidateId] = assignCompleter;
      store.membershipMutationCompleters[membershipA] = unassignCompleter;

      final assign = controller.assignMember(candidateId);
      final unassign = controller.unassignMember(membershipA);
      unassignCompleter.complete();
      expect(await unassign, isTrue);
      assignCompleter.complete();
      expect(await assign, isTrue);

      expect(controller.state.pendingMembershipIds, isEmpty);
      expect(
        controller.state.assignedMembers.map((item) => item.membershipId),
        [candidateId],
      );
      expect(
        controller.state.selectedRoleDetails?.membershipAssignmentCount,
        1,
      );
    });

    test(
      'external invalidation during membership mutation reaches canonical state',
      () async {
        final candidateId = NexaBizMembershipId('member-invalidation');
        store.assignablesByRole[role1.value] = [
          store.dummyAssignable(
            companyId: companyA,
            membershipId: candidateId,
            userId: NexaBizUserId('user-invalidation'),
          ),
        ];
        await controller.initialize();
        await controller.selectRole(role1);
        await controller.loadAssignableMembers();
        final completer = Completer<void>();
        store.membershipMutationCompleters[candidateId] = completer;

        final mutation = controller.assignMember(candidateId);
        invalidationSignal.notifyAuthorizationChanged();
        await Future<void>.delayed(Duration.zero);
        expect(controller.state.isMembershipPending(candidateId), isTrue);

        completer.complete();
        expect(await mutation, isTrue);
        await Future<void>.delayed(Duration.zero);
        expect(controller.state.pendingMembershipIds, isEmpty);
        expect(
          controller.state.assignedMembers.where(
            (item) => item.membershipId == candidateId,
          ),
          hasLength(1),
        );
      },
    );

    test('assignable search race retains the newest query results', () async {
      final firstId = NexaBizMembershipId('member-search-alan');
      final secondId = NexaBizMembershipId('member-search-alice');
      store.assignablesByRole[role1.value] = [
        store.dummyAssignable(
          companyId: companyA,
          membershipId: firstId,
          userId: NexaBizUserId('user-search-alan'),
          name: 'Alan',
        ),
        store.dummyAssignable(
          companyId: companyA,
          membershipId: secondId,
          userId: NexaBizUserId('user-search-alice'),
          name: 'Alice',
        ),
      ];
      await controller.initialize();
      await controller.selectRole(role1);
      final slow = Completer<void>();
      store.assignableQueryCompleters['a'] = slow;

      final oldSearch = controller.loadAssignableMembers(search: 'a');
      await controller.loadAssignableMembers(search: 'Alice');
      slow.complete();
      await oldSearch;

      expect(controller.state.assignableMembers, hasLength(1));
      expect(controller.state.assignableMembers.single.membershipId, secondId);
      expect(controller.state.assignableMembersSearchQuery, 'Alice');
    });

    test('role switch discards an in-flight assignable query', () async {
      final candidateId = NexaBizMembershipId('member-query-role-a');
      store.assignablesByRole[role1.value] = [
        store.dummyAssignable(
          companyId: companyA,
          membershipId: candidateId,
          userId: NexaBizUserId('user-query-role-a'),
          name: 'Slow Candidate',
        ),
      ];
      await controller.initialize();
      await controller.selectRole(role1);
      final slow = Completer<void>();
      store.assignableQueryCompleters['Slow'] = slow;

      final query = controller.loadAssignableMembers(search: 'Slow');
      await controller.selectRole(role2);
      slow.complete();
      await query;

      expect(controller.state.selectedRoleId, role2);
      expect(controller.state.assignableMembers, isEmpty);
      expect(controller.state.assignableMembersSearchQuery, isNull);
    });

    test('assignable pagination appends without duplicates', () async {
      final firstId = NexaBizMembershipId('member-page-1');
      final secondId = NexaBizMembershipId('member-page-2');
      store.assignablesByRole[role1.value] = [
        store.dummyAssignable(
          companyId: companyA,
          membershipId: firstId,
          userId: NexaBizUserId('user-page-1'),
        ),
        store.dummyAssignable(
          companyId: companyA,
          membershipId: secondId,
          userId: NexaBizUserId('user-page-2'),
        ),
      ];
      final pagedController = RolesAdministrationController(
        administration: administration,
        initialContext: contextA,
        pageSize: 1,
      );
      addTearDown(pagedController.dispose);
      await pagedController.initialize();
      await pagedController.selectRole(role1);

      await pagedController.loadAssignableMembers();
      expect(pagedController.state.assignableMembers, hasLength(1));
      expect(pagedController.state.hasMoreAssignableMembers, isTrue);
      await pagedController.loadMoreAssignableMembers();

      expect(
        pagedController.state.assignableMembers.map(
          (item) => item.membershipId,
        ),
        [firstId, secondId],
      );
      expect(pagedController.state.hasMoreAssignableMembers, isFalse);
    });

    test(
      'role deletion during membership mutation cannot resurrect details',
      () async {
        final candidateId = NexaBizMembershipId('member-role-delete');
        store.assignablesByRole[role1.value] = [
          store.dummyAssignable(
            companyId: companyA,
            membershipId: candidateId,
            userId: NexaBizUserId('user-role-delete'),
          ),
        ];
        await controller.initialize();
        await controller.selectRole(role1);
        await controller.loadAssignableMembers();
        final completer = Completer<void>();
        store.membershipMutationCompleters[candidateId] = completer;

        final mutation = controller.assignMember(candidateId);
        store.rolesByCompany[companyA.value]!.removeWhere(
          (role) => role.roleId == role1,
        );
        invalidationSignal.notifyAuthorizationChanged();
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        completer.complete();

        expect(await mutation, isFalse);
        await Future<void>.delayed(Duration.zero);
        expect(controller.state.selectedRoleId, isNull);
        expect(controller.state.selectedRoleDetails, isNull);
        expect(controller.state.assignedMembers, isEmpty);
      },
    );

    test(
      'deleteRole rollback: failure keeps role in list and active selection',
      () async {
        await controller.initialize();
        await controller.selectRole(role1);

        store.throwOnMutation =
            NexaBizAuthorizationAdministrationConflictException(
              type: NexaBizAuthorizationAdministrationConflictType
                  .roleHasMembershipAssignments,
              roleId: role1,
            );

        final success = await controller.deleteRole(role1);
        expect(success, isFalse);

        expect(controller.state.roles.any((r) => r.roleId == role1), isTrue);
        expect(controller.state.selectedRoleId, equals(role1));
        expect(
          controller.state.mutationError!.resolveMessage(l10nEn),
          equals(l10nEn.authAdminErrorRoleHasAssignments),
        );
      },
    );

    test('direct built-in metadata update and delete fail closed', () async {
      final builtInRole = NexaBizRoleId('company.owner');
      store.rolesByCompany[companyA.value]!.add(
        store.dummySummary(
          companyId: companyA,
          roleId: builtInRole,
          name: 'Owner',
          kind: NexaBizCompanyRoleKind.builtIn,
        ),
      );
      await controller.initialize();
      await controller.selectRole(builtInRole);

      store.throwOnMutation = NexaBizBuiltInRoleProtectedException(
        roleId: builtInRole,
        action: NexaBizBuiltInRoleProtectedAction.updateMetadata,
      );
      expect(
        await controller.updateRoleMetadata(
          roleId: builtInRole,
          displayName: NexaBizRoleDisplayName('Changed Owner'),
        ),
        isFalse,
      );
      expect(
        controller.state.mutationError!.resolveMessage(l10nEn),
        l10nEn.authAdminErrorBuiltInUpdate,
      );

      store.throwOnMutation = NexaBizBuiltInRoleProtectedException(
        roleId: builtInRole,
        action: NexaBizBuiltInRoleProtectedAction.delete,
      );
      expect(await controller.deleteRole(builtInRole), isFalse);
      expect(
        controller.state.roles.any((role) => role.roleId == builtInRole),
        isTrue,
      );
      expect(controller.state.selectedRoleId, builtInRole);
      expect(
        controller.state.mutationError!.resolveMessage(l10nEn),
        l10nEn.authAdminErrorBuiltInDelete,
      );
    });
  });

  group('Locale Neutrality & Error Resolution', () {
    test(
      'state is locale-neutral: can resolve error and descriptors in En and Ar without query reloads',
      () async {
        await controller.initialize();
        await controller.selectRole(role1);

        store.throwOnMutation = NexaBizInvalidRoleDisplayNameException(
          NexaBizRoleDisplayNameValidationReason.empty,
        );

        await controller.updateRoleMetadata(
          roleId: role1,
          displayName: NexaBizRoleDisplayName('Valid'),
        );

        final err = controller.state.mutationError;
        expect(err, isNotNull);

        // Zero reload required to read in En or Ar
        expect(
          err!.resolveMessage(l10nEn),
          equals(l10nEn.authAdminErrorRoleNameEmpty),
        );
        expect(
          err.resolveMessage(l10nAr),
          equals(l10nAr.authAdminErrorRoleNameEmpty),
        );

        final permDescriptor = controller.state.selectedRolePermissions.first;
        expect(
          permDescriptor.resolveTitle(l10nEn),
          equals('View company profile'),
        );
        expect(
          permDescriptor.resolveTitle(l10nAr),
          equals('عرض الملف التعريفي للشركة'),
        );
      },
    );
  });

  group('Invalidation Signal Handling & Concurrency Matrix', () {
    test('1. typed membership assign', () async {
      await controller.initialize();
      await controller.selectRole(role1);

      final candidateId = NexaBizMembershipId('member-cand-1');
      store.assignablesByRole[role1.value] = [
        store.dummyAssignable(
          companyId: companyA,
          membershipId: candidateId,
          userId: NexaBizUserId('user-cand-1'),
          name: 'Candidate 1',
        ),
      ];

      await controller.loadAssignableMembers();
      expect(controller.state.assignableMembers, hasLength(1));
      expect(
        controller.state.assignableMembers.first.membershipId,
        equals(candidateId),
      );

      final success = await controller.assignMember(candidateId);
      expect(success, isTrue);
      expect(controller.state.assignableMembers, isEmpty);
      expect(
        controller.state.assignedMembers.any(
          (m) => m.membershipId == candidateId,
        ),
        isTrue,
      );
    });

    test('2. typed membership unassign', () async {
      store.assignmentsByRole[role1.value] = [
        store.dummyAssignment(
          companyId: companyA,
          membershipId: membershipA,
          userId: user1,
          roleId: role1,
        ),
      ];
      await controller.initialize();
      await controller.selectRole(role1);
      expect(controller.state.assignedMembers, hasLength(1));
      final memberToUnassign =
          controller.state.assignedMembers.first.membershipId;

      final success = await controller.unassignMember(memberToUnassign);
      expect(success, isTrue);
      expect(
        controller.state.assignedMembers.any(
          (m) => m.membershipId == memberToUnassign,
        ),
        isFalse,
      );
    });

    test('3. typed pendingMembershipIds', () async {
      store.assignmentsByRole[role1.value] = [
        store.dummyAssignment(
          companyId: companyA,
          membershipId: membershipA,
          userId: user1,
          roleId: role1,
        ),
      ];
      await controller.initialize();
      await controller.selectRole(role1);
      final memberToUnassign = membershipA;
      store.mutationDelayCompleter = Completer<void>();

      final future = controller.unassignMember(memberToUnassign);
      expect(controller.state.pendingMembershipIds, contains(memberToUnassign));
      expect(controller.state.isMembershipPending(memberToUnassign), isTrue);

      store.mutationDelayCompleter!.complete();
      await future;
      expect(controller.state.pendingMembershipIds, isEmpty);
    });

    test(
      '4. overlapping mutation A/B: two different mutations run concurrently',
      () async {
        await controller.initialize();
        await controller.selectRole(role1);
        store.mutationDelayCompleter = Completer<void>();

        final p1 = NexaBizPermissionId('company.profile.manage');
        final p2 = NexaBizPermissionId('identity.user.manage');

        final f1 = controller.grantPermission(p1);
        final f2 = controller.grantPermission(p2);

        expect(controller.state.isPermissionPending(p1), isTrue);
        expect(controller.state.isPermissionPending(p2), isTrue);
        expect(controller.state.pendingPermissionIds, containsAll([p1, p2]));

        store.mutationDelayCompleter!.complete();
        final r1 = await f1;
        final r2 = await f2;

        expect(r1, isTrue);
        expect(r2, isTrue);
        expect(controller.state.isPermissionGranted(p1), isTrue);
        expect(controller.state.isPermissionGranted(p2), isTrue);
        expect(controller.state.pendingPermissionIds, isEmpty);
      },
    );

    test(
      '5. external invalidation during local mutation is never lost',
      () async {
        await controller.initialize();
        store.recordedEvents.clear();
        store.mutationDelayCompleter = Completer<void>();

        // Local mutation starts and hangs on store completion
        final localFuture = controller.createRole(
          roleId: NexaBizRoleId('company.cashier'),
          displayName: NexaBizRoleDisplayName('Cashier'),
        );

        // External actor adds a role in backend
        final externalRole = store.dummySummary(
          companyId: companyA,
          roleId: NexaBizRoleId('company.external'),
          name: 'External Role',
        );
        store.rolesByCompany[companyA.value]!.add(externalRole);

        // External invalidation signal arrives while local mutation is in-flight
        invalidationSignal.notifyAuthorizationChanged();

        // Release local mutation
        store.mutationDelayCompleter!.complete();
        await localFuture;
        await Future<void>.delayed(Duration.zero);

        // Both local cashier AND external role must be present
        expect(
          controller.state.roles.any(
            (r) => r.roleId.value == 'company.external',
          ),
          isTrue,
        );
        expect(
          controller.state.roles.any(
            (r) => r.roleId.value == 'company.cashier',
          ),
          isTrue,
        );
      },
    );

    test('6. rapid multiple invalidations coalesced safely', () async {
      await controller.initialize();
      await controller.selectRole(role1);
      store.recordedEvents.clear();

      store.delayCompleter = Completer<void>();

      // 5 rapid invalidation signals
      invalidationSignal.notifyAuthorizationChanged();
      invalidationSignal.notifyAuthorizationChanged();
      invalidationSignal.notifyAuthorizationChanged();
      invalidationSignal.notifyAuthorizationChanged();
      invalidationSignal.notifyAuthorizationChanged();

      store.delayCompleter!.complete();
      await Future<void>.delayed(Duration.zero);

      // listCompanyRoles must NOT be called 5 times
      final listCalls = store.recordedEvents
          .where((e) => e == 'listCompanyRoles')
          .length;
      expect(listCalls, lessThanOrEqualTo(2));
    });

    test('7. no lost final refresh', () async {
      await controller.initialize();
      store.delayCompleter = Completer<void>();

      // Trigger first refresh
      invalidationSignal.notifyAuthorizationChanged();

      // Add late role to store while first query is awaiting
      final lateRole = store.dummySummary(
        companyId: companyA,
        roleId: NexaBizRoleId('company.auditor'),
        name: 'Auditor',
      );
      store.rolesByCompany[companyA.value]!.add(lateRole);

      // Trigger second signal while first is in-flight
      invalidationSignal.notifyAuthorizationChanged();

      // Complete first query
      store.delayCompleter!.complete();
      await Future<void>.delayed(Duration.zero);

      // The follow-up coalesced refresh must have retrieved the late role
      expect(
        controller.state.roles.any((r) => r.roleId.value == 'company.auditor'),
        isTrue,
      );
    });

    test(
      '8. company switch during refresh: data from Company A never enters Company B',
      () async {
        await controller.initialize();
        store.delayCompleter = Completer<void>();

        invalidationSignal.notifyAuthorizationChanged();

        // Switch to Company B while Company A query is awaiting
        controller.updateContext(contextB);

        store.delayCompleter!.complete();
        await Future<void>.delayed(Duration.zero);

        expect(
          controller.state.roles.any((r) => r.companyId == companyA),
          isFalse,
        );
      },
    );

    test(
      '9. role switch during refresh: Role A details never overwrite Role B',
      () async {
        await controller.initialize();
        store.delayCompleter = Completer<void>();

        // Select Role 1 (delayed)
        final f1 = controller.selectRole(role1);

        // User quickly selects Role 2
        final f2 = controller.selectRole(role2);

        store.delayCompleter!.complete();
        await f1;
        await f2;

        expect(controller.state.selectedRoleId, equals(role2));
        expect(controller.state.selectedRoleDetails?.roleId, equals(role2));
      },
    );

    test('10. dispose during/after invalidation', () async {
      await controller.initialize();
      controller.dispose();

      expect(
        () => invalidationSignal.notifyAuthorizationChanged(),
        returnsNormally,
      );
      await Future<void>.delayed(Duration.zero);
    });

    test(
      '11. same permission double-submit: sequencing guard blocks duplicate',
      () async {
        await controller.initialize();
        await controller.selectRole(role1);
        store.mutationDelayCompleter = Completer<void>();

        final p1 = NexaBizPermissionId('company.profile.manage');
        final f1 = controller.grantPermission(p1);

        // Second call on the same pending permission
        final f2 = controller.grantPermission(p1);
        expect(await f2, isFalse);

        store.mutationDelayCompleter!.complete();
        expect(await f1, isTrue);
      },
    );

    test(
      '12. same membership double-submit: sequencing guard blocks duplicate',
      () async {
        store.assignmentsByRole[role1.value] = [
          store.dummyAssignment(
            companyId: companyA,
            membershipId: membershipA,
            userId: user1,
            roleId: role1,
          ),
        ];
        await controller.initialize();
        await controller.selectRole(role1);
        store.mutationDelayCompleter = Completer<void>();

        final f1 = controller.unassignMember(membershipA);

        // Second call on the same pending membership
        final f2 = controller.unassignMember(membershipA);
        expect(await f2, isFalse);

        store.mutationDelayCompleter!.complete();
        expect(await f1, isTrue);
      },
    );
  });
}
