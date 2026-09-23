import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/authorization/nexabiz_authorization_administration.dart';
import 'package:nexabiz/app/authorization/nexabiz_authorization_invalidation_signal.dart';
import 'package:nexabiz/app/authorization/use_cases/assign_role_to_membership_use_case.dart';
import 'package:nexabiz/app/authorization/use_cases/create_company_role_use_case.dart';
import 'package:nexabiz/app/authorization/use_cases/delete_company_role_use_case.dart';
import 'package:nexabiz/app/authorization/use_cases/get_company_role_use_case.dart';
import 'package:nexabiz/app/authorization/use_cases/grant_permission_to_role_use_case.dart';
import 'package:nexabiz/app/authorization/use_cases/inspect_membership_effective_permissions_use_case.dart';
import 'package:nexabiz/app/authorization/use_cases/list_assignable_memberships_for_role_use_case.dart';
import 'package:nexabiz/app/authorization/use_cases/list_company_roles_use_case.dart';
import 'package:nexabiz/app/authorization/use_cases/list_declared_permission_catalog_use_case.dart';
import 'package:nexabiz/app/authorization/use_cases/list_membership_roles_use_case.dart';
import 'package:nexabiz/app/authorization/use_cases/list_memberships_assigned_to_role_use_case.dart';
import 'package:nexabiz/app/authorization/use_cases/list_role_permissions_use_case.dart';
import 'package:nexabiz/app/authorization/use_cases/revoke_permission_from_role_use_case.dart';
import 'package:nexabiz/app/authorization/use_cases/unassign_role_from_membership_use_case.dart';
import 'package:nexabiz/app/authorization/use_cases/update_company_role_metadata_use_case.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_errors.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_models.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_permissions.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_store.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_context.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_id.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_catalog.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_denied_exception.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_guard.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/roles/nexabiz_role_id.dart';
import 'package:nexabiz/core/session/nexabiz_session.dart';

// Test Doubles

final class FakePermissionGuard implements NexaBizPermissionGuard {
  NexaBizPermissionDecision decision = NexaBizPermissionDecision.allow;
  final List<String> recordedEvents;
  final List<NexaBizPermissionId> evaluatedPermissions = [];

  FakePermissionGuard([List<String>? events])
    : recordedEvents = events ?? <String>[];

  @override
  Future<void> requirePermission({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  }) async {
    recordedEvents.add('guard.requirePermission:${permissionId.value}');
    evaluatedPermissions.add(permissionId);
    if (!decision.isAllowed) {
      throw NexaBizPermissionDeniedException(
        permissionId: permissionId,
        contextScope: context.scope,
        decision: decision,
      );
    }
  }
}

final class FakeAdministrationStore
    implements NexaBizAuthorizationAdministrationStore {
  final List<String> recordedEvents;
  int callCount = 0;
  bool returnChanged = true;
  Exception? throwError;

  FakeAdministrationStore([List<String>? events])
    : recordedEvents = events ?? <String>[];

  NexaBizCompanyRoleDetails _dummyRole(
    NexaBizCompanyId companyId,
    NexaBizRoleId roleId,
  ) => NexaBizCompanyRoleDetails(
    companyId: companyId,
    roleId: roleId,
    metadata: NexaBizRoleMetadata(
      displayName: NexaBizRoleDisplayName('Custom Role'),
    ),
    kind: NexaBizCompanyRoleKind.custom,
    membershipAssignmentCount: 0,
    permissionAssignmentCount: 0,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );

  NexaBizMembershipRoleAssignment _dummyAssignment(
    NexaBizCompanyId companyId,
    NexaBizMembershipId membershipId,
    NexaBizRoleId roleId,
  ) => NexaBizMembershipRoleAssignment(
    companyId: companyId,
    membershipId: membershipId,
    userId: NexaBizUserId('usr-1'),
    roleId: roleId,
    membershipIsActive: true,
    userIsActive: true,
    assignedAt: DateTime.utc(2026, 1, 1),
  );

  NexaBizRolePermissionAssignment _dummyPermission(
    NexaBizCompanyId companyId,
    NexaBizRoleId roleId,
    NexaBizPermissionId permissionId,
  ) => NexaBizRolePermissionAssignment(
    companyId: companyId,
    roleId: roleId,
    permissionId: permissionId,
    assignedAt: DateTime.utc(2026, 1, 1),
  );

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  createCompanyRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizRoleMetadata metadata,
  }) async {
    recordedEvents.add('store.createCompanyRole');
    callCount++;
    if (throwError != null) throw throwError!;
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: returnChanged
          ? NexaBizAuthorizationAdministrationMutationOutcome.changed
          : NexaBizAuthorizationAdministrationMutationOutcome.unchanged,
      before: null,
      after: _dummyRole(companyId, roleId),
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
    recordedEvents.add('store.updateCompanyRoleMetadata');
    callCount++;
    if (throwError != null) throw throwError!;
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: returnChanged
          ? NexaBizAuthorizationAdministrationMutationOutcome.changed
          : NexaBizAuthorizationAdministrationMutationOutcome.unchanged,
      before: _dummyRole(companyId, roleId),
      after: _dummyRole(companyId, roleId),
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
    recordedEvents.add('store.deleteCompanyRole');
    callCount++;
    if (throwError != null) throw throwError!;
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: returnChanged
          ? NexaBizAuthorizationAdministrationMutationOutcome.changed
          : NexaBizAuthorizationAdministrationMutationOutcome.unchanged,
      before: _dummyRole(companyId, roleId),
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
    recordedEvents.add('store.assignRoleToMembership');
    callCount++;
    if (throwError != null) throw throwError!;
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: returnChanged
          ? NexaBizAuthorizationAdministrationMutationOutcome.changed
          : NexaBizAuthorizationAdministrationMutationOutcome.unchanged,
      before: null,
      after: _dummyAssignment(companyId, membershipId, roleId),
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
    recordedEvents.add('store.unassignRoleFromMembership');
    callCount++;
    if (throwError != null) throw throwError!;
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: returnChanged
          ? NexaBizAuthorizationAdministrationMutationOutcome.changed
          : NexaBizAuthorizationAdministrationMutationOutcome.unchanged,
      before: _dummyAssignment(companyId, membershipId, roleId),
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
    recordedEvents.add('store.grantPermissionToRole');
    callCount++;
    if (throwError != null) throw throwError!;
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: returnChanged
          ? NexaBizAuthorizationAdministrationMutationOutcome.changed
          : NexaBizAuthorizationAdministrationMutationOutcome.unchanged,
      before: null,
      after: _dummyPermission(companyId, roleId, permissionId),
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
    recordedEvents.add('store.revokePermissionFromRole');
    callCount++;
    if (throwError != null) throw throwError!;
    return NexaBizAuthorizationAdministrationMutationResult(
      outcome: returnChanged
          ? NexaBizAuthorizationAdministrationMutationOutcome.changed
          : NexaBizAuthorizationAdministrationMutationOutcome.unchanged,
      before: _dummyPermission(companyId, roleId, permissionId),
      after: null,
    );
  }

  @override
  Future<NexaBizCompanyRoleDetails> readCompanyRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
  }) async {
    recordedEvents.add('store.readCompanyRole');
    callCount++;
    if (throwError != null) throw throwError!;
    return _dummyRole(companyId, roleId);
  }

  @override
  Future<NexaBizAuthorizationAdministrationPage<NexaBizCompanyRoleSummary>>
  listCompanyRoles({
    required NexaBizCompanyId companyId,
    required NexaBizAuthorizationAdministrationPageRequest page,
    NexaBizCompanyRoleFilter? filter,
  }) async {
    recordedEvents.add('store.listCompanyRoles');
    callCount++;
    if (throwError != null) throw throwError!;
    return NexaBizAuthorizationAdministrationPage(
      items: [
        NexaBizCompanyRoleSummary(
          companyId: companyId,
          roleId: NexaBizRoleId('company.admin'),
          metadata: NexaBizRoleMetadata(
            displayName: NexaBizRoleDisplayName('Admin'),
          ),
          kind: NexaBizCompanyRoleKind.custom,
          membershipAssignmentCount: 1,
        ),
      ],
      nextCursor: null,
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
    recordedEvents.add('store.listRolePermissions');
    callCount++;
    if (throwError != null) throw throwError!;
    return NexaBizAuthorizationAdministrationPage(
      items: [
        _dummyPermission(
          companyId,
          roleId,
          NexaBizPermissionId('permissions.role.manage'),
        ),
      ],
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
  }) async {
    recordedEvents.add('store.listMembershipRoles');
    callCount++;
    if (throwError != null) throw throwError!;
    return NexaBizAuthorizationAdministrationPage(
      items: [
        _dummyAssignment(
          companyId,
          membershipId,
          NexaBizRoleId('company.admin'),
        ),
      ],
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
    recordedEvents.add('store.listRoleMemberships');
    callCount++;
    if (throwError != null) throw throwError!;
    return NexaBizAuthorizationAdministrationPage(
      items: [
        _dummyAssignment(companyId, NexaBizMembershipId('mem-1'), roleId),
      ],
      nextCursor: null,
    );
  }

  @override
  Future<NexaBizMembershipEffectivePermissionInfo>
  inspectMembershipEffectivePermissions({
    required NexaBizCompanyId companyId,
    required NexaBizMembershipId membershipId,
  }) async {
    recordedEvents.add('store.inspectMembershipEffectivePermissions');
    callCount++;
    if (throwError != null) throw throwError!;
    return NexaBizMembershipEffectivePermissionInfo(
      companyId: companyId,
      membershipId: membershipId,
      userId: NexaBizUserId('usr-1'),
      roleIds: {},
      permissionIds: {},
      isEligible: true,
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
    recordedEvents.add('store.listAssignableMembershipsForRole');
    callCount++;
    if (throwError != null) throw throwError!;
    return NexaBizAuthorizationAdministrationPage(
      items: [
        NexaBizAssignableMembership(
          companyId: companyId,
          membershipId: NexaBizMembershipId('mem-assignable-1'),
          userId: NexaBizUserId('usr-assignable-1'),
          userName: 'Assignable User',
          userEmail: 'assignable@nexabiz.local',
          membershipIsActive: true,
          userIsActive: true,
        ),
      ],
      nextCursor: null,
    );
  }
}

void main() {
  final companyA = NexaBizCompanyId('company-a');
  final companyB = NexaBizCompanyId('company-b');
  final membershipId = NexaBizMembershipId('mem-1');
  final userId = NexaBizUserId('usr-1');
  final roleId = NexaBizRoleId('company.custom_role');
  final metadata = NexaBizRoleMetadata(
    displayName: NexaBizRoleDisplayName('Accountant'),
    description: 'Finance management',
  );
  final permissionId = NexaBizPermissionId('permissions.role.manage');
  final pageRequest = NexaBizAuthorizationAdministrationPageRequest(limit: 20);

  final contextA = NexaBizCompanyAuthorizationContext(
    userId: userId,
    companyId: companyA,
    membershipId: membershipId,
  );

  late FakePermissionGuard guard;
  late FakeAdministrationStore store;
  late NexaBizAuthorizationInvalidationSignal signal;
  late int invalidationCount;
  late NexaBizImmutablePermissionCatalog catalog;
  late List<String> eventTrace;

  setUp(() {
    eventTrace = <String>[];
    guard = FakePermissionGuard(eventTrace);
    store = FakeAdministrationStore(eventTrace);
    signal = NexaBizAuthorizationInvalidationSignal();
    invalidationCount = 0;
    signal.addListener(() {
      eventTrace.add('signal.notifyAuthorizationChanged');
      invalidationCount++;
    });
    catalog = NexaBizImmutablePermissionCatalog({
      NexaBizAuthorizationAdministrationPermissions.catalogView,
      NexaBizAuthorizationAdministrationPermissions.policyReview,
      NexaBizAuthorizationAdministrationPermissions.roleManage,
      NexaBizAuthorizationAdministrationPermissions.policyManage,
      NexaBizAuthorizationAdministrationPermissions.assignmentManage,
    });
  });

  group('Authorization Administration UseCases Unit & Pipeline Tests', () {
    test(
      'Security Execution Order: Guard -> Store -> Invalidation (Post-Commit)',
      () async {
        final useCase = CreateCompanyRoleUseCase(
          permissionGuard: guard,
          mutationStore: store,
          invalidationSignal: signal,
        );

        final result = await useCase.execute(
          context: contextA,
          roleId: roleId,
          metadata: metadata,
        );

        expect(result.changed, isTrue);
        expect(eventTrace, [
          'guard.requirePermission:permissions.role.manage',
          'store.createCompanyRole',
          'signal.notifyAuthorizationChanged',
        ]);
        expect(invalidationCount, 1);
      },
    );

    test('Zero Side Effects on DENY: 0 store calls, 0 invalidations', () async {
      guard.decision = NexaBizPermissionDecision.deny;

      final useCase = CreateCompanyRoleUseCase(
        permissionGuard: guard,
        mutationStore: store,
        invalidationSignal: signal,
      );

      await expectLater(
        useCase.execute(context: contextA, roleId: roleId, metadata: metadata),
        throwsA(isA<NexaBizPermissionDeniedException>()),
      );

      expect(store.callCount, 0);
      expect(invalidationCount, 0);
      expect(eventTrace, ['guard.requirePermission:permissions.role.manage']);
    });

    test(
      'Zero Side Effects on UNKNOWN: 0 store calls, 0 invalidations',
      () async {
        guard.decision = NexaBizPermissionDecision.unknown;

        final useCase = AssignRoleToMembershipUseCase(
          permissionGuard: guard,
          mutationStore: store,
          invalidationSignal: signal,
        );

        await expectLater(
          useCase.execute(
            context: contextA,
            membershipId: membershipId,
            roleId: roleId,
          ),
          throwsA(isA<NexaBizPermissionDeniedException>()),
        );

        expect(store.callCount, 0);
        expect(invalidationCount, 0);
      },
    );

    test('Mismatched target company rejected BEFORE guard and store', () async {
      final useCase = CreateCompanyRoleUseCase(
        permissionGuard: guard,
        mutationStore: store,
        invalidationSignal: signal,
      );

      await expectLater(
        useCase.execute(
          context: contextA,
          roleId: roleId,
          metadata: metadata,
          targetCompanyId: companyB,
        ),
        throwsA(isA<NexaBizAuthorizationCrossCompanyException>()),
      );

      expect(guard.evaluatedPermissions, isEmpty);
      expect(store.callCount, 0);
      expect(invalidationCount, 0);
    });

    test(
      'Idempotent outcome (changed: false) emits ZERO invalidations',
      () async {
        store.returnChanged = false;

        final useCase = AssignRoleToMembershipUseCase(
          permissionGuard: guard,
          mutationStore: store,
          invalidationSignal: signal,
        );

        final result = await useCase.execute(
          context: contextA,
          membershipId: membershipId,
          roleId: roleId,
        );

        expect(result.changed, isFalse);
        expect(store.callCount, 1);
        expect(invalidationCount, 0);
        expect(eventTrace, [
          'guard.requirePermission:permissions.assignment.manage',
          'store.assignRoleToMembership',
        ]);
      },
    );

    test('Store failure propagates and emits ZERO invalidations', () async {
      store.throwError = NexaBizRoleNotFoundException(
        companyId: companyA,
        roleId: roleId,
      );

      final useCase = DeleteCompanyRoleUseCase(
        permissionGuard: guard,
        mutationStore: store,
        invalidationSignal: signal,
      );

      await expectLater(
        useCase.execute(context: contextA, roleId: roleId),
        throwsA(isA<NexaBizRoleNotFoundException>()),
      );

      expect(store.callCount, 1);
      expect(invalidationCount, 0);
    });

    test('All 7 Mutation UseCases map to canonical permissions', () async {
      final create = CreateCompanyRoleUseCase(
        permissionGuard: guard,
        mutationStore: store,
        invalidationSignal: signal,
      );
      final update = UpdateCompanyRoleMetadataUseCase(
        permissionGuard: guard,
        mutationStore: store,
        invalidationSignal: signal,
      );
      final delete = DeleteCompanyRoleUseCase(
        permissionGuard: guard,
        mutationStore: store,
        invalidationSignal: signal,
      );
      final assign = AssignRoleToMembershipUseCase(
        permissionGuard: guard,
        mutationStore: store,
        invalidationSignal: signal,
      );
      final unassign = UnassignRoleFromMembershipUseCase(
        permissionGuard: guard,
        mutationStore: store,
        invalidationSignal: signal,
      );
      final grant = GrantPermissionToRoleUseCase(
        permissionGuard: guard,
        mutationStore: store,
        invalidationSignal: signal,
      );
      final revoke = RevokePermissionFromRoleUseCase(
        permissionGuard: guard,
        mutationStore: store,
        invalidationSignal: signal,
      );

      await create.execute(
        context: contextA,
        roleId: roleId,
        metadata: metadata,
      );
      await update.execute(
        context: contextA,
        roleId: roleId,
        metadata: metadata,
      );
      await delete.execute(context: contextA, roleId: roleId);
      await assign.execute(
        context: contextA,
        membershipId: membershipId,
        roleId: roleId,
      );
      await unassign.execute(
        context: contextA,
        membershipId: membershipId,
        roleId: roleId,
      );
      await grant.execute(
        context: contextA,
        roleId: roleId,
        permissionId: permissionId,
      );
      await revoke.execute(
        context: contextA,
        roleId: roleId,
        permissionId: permissionId,
      );

      expect(guard.evaluatedPermissions, [
        NexaBizAuthorizationAdministrationPermissions.roleManage,
        NexaBizAuthorizationAdministrationPermissions.roleManage,
        NexaBizAuthorizationAdministrationPermissions.roleManage,
        NexaBizAuthorizationAdministrationPermissions.assignmentManage,
        NexaBizAuthorizationAdministrationPermissions.assignmentManage,
        NexaBizAuthorizationAdministrationPermissions.policyManage,
        NexaBizAuthorizationAdministrationPermissions.policyManage,
      ]);
      expect(invalidationCount, 7);
    });

    test(
      'All 8 Query UseCases enforce permissions and emit zero invalidations',
      () async {
        final getRole = GetCompanyRoleUseCase(
          permissionGuard: guard,
          queryStore: store,
        );
        final listRoles = ListCompanyRolesUseCase(
          permissionGuard: guard,
          queryStore: store,
        );
        final listRolePerms = ListRolePermissionsUseCase(
          permissionGuard: guard,
          queryStore: store,
        );
        final listMemRoles = ListMembershipRolesUseCase(
          permissionGuard: guard,
          queryStore: store,
        );
        final listRoleMems = ListMembershipsAssignedToRoleUseCase(
          permissionGuard: guard,
          queryStore: store,
        );
        final listAssignableMems = ListAssignableMembershipsForRoleUseCase(
          permissionGuard: guard,
          queryStore: store,
        );
        final inspectPerms = InspectMembershipEffectivePermissionsUseCase(
          permissionGuard: guard,
          queryStore: store,
        );
        final listCatalog = ListDeclaredPermissionCatalogUseCase(
          permissionGuard: guard,
          permissionCatalog: catalog,
        );

        final roleRes = await getRole.execute(
          context: contextA,
          roleId: roleId,
        );
        final rolesRes = await listRoles.execute(
          context: contextA,
          page: pageRequest,
        );
        final permsRes = await listRolePerms.execute(
          context: contextA,
          roleId: roleId,
          page: pageRequest,
        );
        final memRolesRes = await listMemRoles.execute(
          context: contextA,
          membershipId: membershipId,
          page: pageRequest,
        );
        final roleMemsRes = await listRoleMems.execute(
          context: contextA,
          roleId: roleId,
          page: pageRequest,
        );
        final assignableMemsRes = await listAssignableMems.execute(
          context: contextA,
          roleId: roleId,
          page: pageRequest,
        );
        final inspectRes = await inspectPerms.execute(
          context: contextA,
          membershipId: membershipId,
        );
        final catalogRes = await listCatalog.execute(context: contextA);

        expect(roleRes.roleId, roleId);
        expect(rolesRes.items, isNotEmpty);
        expect(permsRes.items, isNotEmpty);
        expect(memRolesRes.items, isNotEmpty);
        expect(roleMemsRes.items, isNotEmpty);
        expect(assignableMemsRes.items, isNotEmpty);
        expect(inspectRes.membershipId, membershipId);
        expect(catalogRes.length, 5);

        expect(invalidationCount, 0);
        expect(guard.evaluatedPermissions, [
          NexaBizAuthorizationAdministrationPermissions.policyReview,
          NexaBizAuthorizationAdministrationPermissions.policyReview,
          NexaBizAuthorizationAdministrationPermissions.policyReview,
          NexaBizAuthorizationAdministrationPermissions.policyReview,
          NexaBizAuthorizationAdministrationPermissions.policyReview,
          NexaBizAuthorizationAdministrationPermissions.assignmentManage,
          NexaBizAuthorizationAdministrationPermissions.policyReview,
          NexaBizAuthorizationAdministrationPermissions.catalogView,
        ]);
      },
    );

    test(
      'ListAssignableMembershipsForRoleUseCase enforces tenant and permission checks',
      () async {
        final useCase = ListAssignableMembershipsForRoleUseCase(
          permissionGuard: guard,
          queryStore: store,
        );

        // Cross-company rejection
        await expectLater(
          useCase.execute(
            context: contextA,
            roleId: roleId,
            page: pageRequest,
            targetCompanyId: companyB,
          ),
          throwsA(isA<NexaBizAuthorizationCrossCompanyException>()),
        );
        expect(store.callCount, 0);

        // Deny check
        guard.decision = NexaBizPermissionDecision.deny;
        await expectLater(
          useCase.execute(context: contextA, roleId: roleId, page: pageRequest),
          throwsA(isA<NexaBizPermissionDeniedException>()),
        );
        expect(store.callCount, 0);
      },
    );

    test(
      'Query UseCase on DENY throws typed exception (does not return empty list)',
      () async {
        guard.decision = NexaBizPermissionDecision.deny;

        final listRoles = ListCompanyRolesUseCase(
          permissionGuard: guard,
          queryStore: store,
        );

        await expectLater(
          listRoles.execute(context: contextA, page: pageRequest),
          throwsA(isA<NexaBizPermissionDeniedException>()),
        );
        expect(store.callCount, 0);
      },
    );

    test('Application Facade creates all 15 UseCases correctly', () {
      final facade = NexaBizAuthorizationAdministration.create(
        permissionGuard: guard,
        queryStore: store,
        mutationStore: store,
        invalidationSignal: signal,
        permissionCatalog: catalog,
      );

      expect(facade.createCompanyRole, isNotNull);
      expect(facade.updateCompanyRoleMetadata, isNotNull);
      expect(facade.deleteCompanyRole, isNotNull);
      expect(facade.assignRoleToMembership, isNotNull);
      expect(facade.unassignRoleFromMembership, isNotNull);
      expect(facade.grantPermissionToRole, isNotNull);
      expect(facade.revokePermissionFromRole, isNotNull);
      expect(facade.getCompanyRole, isNotNull);
      expect(facade.listCompanyRoles, isNotNull);
      expect(facade.listRolePermissions, isNotNull);
      expect(facade.listMembershipRoles, isNotNull);
      expect(facade.listMembershipsAssignedToRole, isNotNull);
      expect(facade.listAssignableMembershipsForRole, isNotNull);
      expect(facade.inspectMembershipEffectivePermissions, isNotNull);
      expect(facade.listDeclaredPermissionCatalog, isNotNull);
    });
  });
}
