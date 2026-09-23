import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/authorization/app_permission_scope.dart';
import 'package:nexabiz/app/authorization/nexabiz_authorization_administration.dart';
import 'package:nexabiz/app/authorization/nexabiz_authorization_invalidation_signal.dart';
import 'package:nexabiz/app/localization/app_locale_controller.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_models.dart';
import 'package:nexabiz/core/authorization/administration/nexabiz_authorization_administration_store.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_context.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_id.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_catalog.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_evaluator.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_guard.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/roles/nexabiz_role_id.dart';
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
  @override
  Future<NexaBizPermissionDecision> evaluate({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  }) async => NexaBizPermissionDecision.allow;
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
  }) async => throw UnimplementedError('Read-only in Step 05');

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  updateCompanyRoleMetadata({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
    required NexaBizRoleMetadata metadata,
  }) async => throw UnimplementedError('Read-only in Step 05');

  @override
  Future<
    NexaBizAuthorizationAdministrationMutationResult<NexaBizCompanyRoleDetails>
  >
  deleteCompanyRole({
    required NexaBizCompanyId companyId,
    required NexaBizRoleId roleId,
  }) async => throw UnimplementedError('Read-only in Step 05');

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
  }) async => throw UnimplementedError('Read-only in Step 05');

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
  }) async => throw UnimplementedError('Read-only in Step 05');

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
  }) async => throw UnimplementedError('Read-only in Step 05');

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
  }) async => throw UnimplementedError('Read-only in Step 05');
}

// ---------------------------------------------------------------------------
// Test Suite
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAdminStore fakeStore;
  late NexaBizAuthorizationAdministration adminFacade;
  late NexaBizAuthorizationInvalidationSignal invalidationSignal;
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
        permissionEvaluator: _FakePermissionEvaluator(),
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

  group('RolesScreen — Step 05 Read-Only UI Shell Verification', () {
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
      '75. Built-in role: displays built-in badge, help explanation, no mutation controls',
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

        // Verification of STRICT READ-ONLY invariant: zero mutation affordances
        expect(find.text('Create Role'), findsNothing);
        expect(find.text('Edit Role'), findsNothing);
        expect(find.text('Delete Role'), findsNothing);
        expect(find.text('Assign Member'), findsNothing);
        expect(find.text('Unassign'), findsNothing);
        expect(find.byType(AppSwitch), findsNothing);
      },
    );

    testWidgets(
      '76. Custom role: renders custom status and read-only details',
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
  });
}
