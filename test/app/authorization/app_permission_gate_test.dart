import 'dart:async';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart' show Scaffold;
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/authorization/app_permission_gate.dart';
import 'package:nexabiz/app/authorization/app_permission_scope.dart';
import 'package:nexabiz/app/authorization/nexabiz_authorization_invalidation_signal.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_context.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_id.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_evaluator.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/session/core_session_controller.dart';
import 'package:nexabiz/core/session/nexabiz_session.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

// ---------------------------------------------------------------------------
// Test Doubles
// ---------------------------------------------------------------------------

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

class _TestFakeEvaluator implements NexaBizPermissionEvaluator {
  _TestFakeEvaluator();

  NexaBizPermissionDecision decision = NexaBizPermissionDecision.allow;
  bool shouldThrow = false;
  Duration? delay;
  Completer<NexaBizPermissionDecision>? delayedCompleter;
  int evaluateCallCount = 0;
  NexaBizAuthorizationContext? lastContext;
  NexaBizPermissionId? lastPermissionId;

  @override
  Future<NexaBizPermissionDecision> evaluate({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  }) async {
    evaluateCallCount++;
    lastContext = context;
    lastPermissionId = permissionId;

    if (shouldThrow) {
      throw StateError('Simulated infrastructure failure');
    }

    if (delayedCompleter != null) {
      return delayedCompleter!.future;
    }

    if (delay != null) {
      await Future<void>.delayed(delay!);
    }

    return decision;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _permEdit = NexaBizPermissionId('company.profile.manage');
final _defaultUserId = NexaBizUserId('usr-001');
final _defaultCompanyId = NexaBizCompanyId('cmp-001');
final _defaultMembershipId = NexaBizMembershipId('mem-001');

Widget _wrapTestWidget({
  required Widget child,
  NexaBizPermissionEvaluator? evaluator,
  CoreSessionController? sessionController,
  Listenable? invalidationSignal,
}) {
  Widget current = Directionality(
    textDirection: TextDirection.ltr,
    child: child,
  );

  if (evaluator != null && sessionController != null) {
    current = AppPermissionScope(
      permissionEvaluator: evaluator,
      sessionController: sessionController,
      invalidationSignal: invalidationSignal,
      child: current,
    );
  }

  return current;
}

Widget _wrapInteractiveTestWidget({
  required Widget child,
  NexaBizPermissionEvaluator? evaluator,
  required CoreSessionController sessionController,
  Listenable? invalidationSignal,
}) {
  Widget current = Directionality(
    textDirection: TextDirection.ltr,
    child: child,
  );

  if (evaluator != null) {
    current = AppPermissionScope(
      permissionEvaluator: evaluator,
      sessionController: sessionController,
      invalidationSignal: invalidationSignal,
      child: current,
    );
  }

  return shadcn.ShadcnApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: current)),
  );
}

void main() {
  group('AppPermissionGate Widget & Behavioral Suite (Section 26)', () {
    late CoreSessionController sessionController;
    late _TestFakeEvaluator evaluator;
    late NexaBizAuthorizationInvalidationSignal invalidationSignal;

    setUp(() {
      sessionController = CoreSessionController(
        authenticateLocalUser: AuthenticateLocalUser(
          queryStore: _TestMockIdentityStore(),
        ),
        queryStore: _TestMockIdentityStore(),
      );
      evaluator = _TestFakeEvaluator();
      invalidationSignal = NexaBizAuthorizationInvalidationSignal();
    });

    tearDown(() async {
      await sessionController.dispose();
      invalidationSignal.dispose();
    });

    void setActiveSession({
      String sessionId = 'session-1',
      NexaBizCompanyId? companyId,
      NexaBizMembershipId? membershipId,
      String role = 'member',
    }) {
      sessionController.setSessionForTesting(
        NexaBizSession.active(
          userId: _defaultUserId,
          companyId: companyId ?? _defaultCompanyId,
          membershipId: membershipId ?? _defaultMembershipId,
          role: role,
          sessionId: sessionId,
        ),
      );
    }

    // 1. ALLOW + Hide -> child visible
    testWidgets('1. ALLOW + Hide -> child visible', (tester) async {
      setActiveSession();
      evaluator.decision = NexaBizPermissionDecision.allow;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.hide(
            permissionId: _permEdit,
            child: Text('Edit Profile Action'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile Action'), findsOneWidget);
    });

    // 2. DENY + Hide -> child absent
    testWidgets('2. DENY + Hide -> child absent', (tester) async {
      setActiveSession();
      evaluator.decision = NexaBizPermissionDecision.deny;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.hide(
            permissionId: _permEdit,
            child: Text('Edit Profile Action'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile Action'), findsNothing);
    });

    // 3. UNKNOWN + Hide -> child absent
    testWidgets('3. UNKNOWN + Hide -> child absent', (tester) async {
      setActiveSession();
      evaluator.decision = NexaBizPermissionDecision.unknown;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.hide(
            permissionId: _permEdit,
            child: Text('Edit Profile Action'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile Action'), findsNothing);
    });

    // 4. Missing evaluator + Hide -> child absent
    testWidgets('4. Missing evaluator + Hide -> child absent', (tester) async {
      setActiveSession();

      // No evaluator provided in scope or constructor
      await tester.pumpWidget(
        _wrapTestWidget(
          child: AppPermissionGate.hide(
            permissionId: _permEdit,
            sessionController: sessionController,
            child: const Text('Edit Profile Action'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile Action'), findsNothing);
    });

    // 5. Invalid / no session + Hide -> child absent
    testWidgets('5. Invalid / no session + Hide -> child absent', (
      tester,
    ) async {
      // session is noSession (unauthenticated)
      evaluator.decision = NexaBizPermissionDecision.allow;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.hide(
            permissionId: _permEdit,
            child: Text('Edit Profile Action'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile Action'), findsNothing);
    });

    // 6. Evaluating + Hide -> child absent (Never flash protected action during loading)
    testWidgets('6. Evaluating + Hide -> child absent during evaluation', (
      tester,
    ) async {
      setActiveSession();
      final completer = Completer<NexaBizPermissionDecision>();
      evaluator.delayedCompleter = completer;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.hide(
            permissionId: _permEdit,
            child: Text('Edit Profile Action'),
          ),
        ),
      );

      // Only pump initial frame without resolving async completer
      await tester.pump();
      expect(find.text('Edit Profile Action'), findsNothing);

      // Now complete the future with ALLOW
      completer.complete(NexaBizPermissionDecision.allow);
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile Action'), findsOneWidget);
    });

    // 7. Evaluation exception + Hide -> child absent (Fail-Closed)
    testWidgets('7. Evaluation exception + Hide -> child absent', (
      tester,
    ) async {
      setActiveSession();
      evaluator.shouldThrow = true;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.hide(
            permissionId: _permEdit,
            child: Text('Edit Profile Action'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile Action'), findsNothing);
      expect(
        tester.takeException(),
        isNull,
      ); // Must not throw into unhandled zone
    });

    // 8. ALLOW + Disable -> enabled
    testWidgets('8. ALLOW + Disable -> enabled', (tester) async {
      setActiveSession();
      evaluator.decision = NexaBizPermissionDecision.allow;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.disable(
            permissionId: _permEdit,
            builder: (context, isAllowed) =>
                Text(isAllowed ? 'Action: Enabled' : 'Action: Disabled'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Action: Enabled'), findsOneWidget);
    });

    // 9. DENY + Disable -> disabled
    testWidgets('9. DENY + Disable -> disabled', (tester) async {
      setActiveSession();
      evaluator.decision = NexaBizPermissionDecision.deny;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.disable(
            permissionId: _permEdit,
            builder: (context, isAllowed) =>
                Text(isAllowed ? 'Action: Enabled' : 'Action: Disabled'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Action: Disabled'), findsOneWidget);
    });

    // 10. UNKNOWN + Disable -> disabled
    testWidgets('10. UNKNOWN + Disable -> disabled', (tester) async {
      setActiveSession();
      evaluator.decision = NexaBizPermissionDecision.unknown;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.disable(
            permissionId: _permEdit,
            builder: (context, isAllowed) =>
                Text(isAllowed ? 'Action: Enabled' : 'Action: Disabled'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Action: Disabled'), findsOneWidget);
    });

    // 11. Disabled action cannot invoke callback
    testWidgets('11. Disabled action cannot invoke callback', (tester) async {
      setActiveSession();
      evaluator.decision = NexaBizPermissionDecision.deny;

      var tapped = false;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.disable(
            permissionId: _permEdit,
            builder: (context, isAllowed) => GestureDetector(
              onTap: isAllowed ? () => tapped = true : null,
              child: const Text('Tap Me Target'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tap Me Target'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });

    // 12. Live revoke hides/disables immediately after invalidation
    testWidgets('12. Live revoke hides child immediately after invalidation', (
      tester,
    ) async {
      setActiveSession();
      evaluator.decision = NexaBizPermissionDecision.allow;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          invalidationSignal: invalidationSignal,
          child: AppPermissionGate.hide(
            permissionId: _permEdit,
            child: Text('Live Guarded Button'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Live Guarded Button'), findsOneWidget);

      // Revoke permission live in persistence
      evaluator.decision = NexaBizPermissionDecision.deny;
      invalidationSignal.notifyAuthorizationChanged();

      await tester.pumpAndSettle();
      expect(find.text('Live Guarded Button'), findsNothing);
    });

    // 13. Live grant reveals/enables after invalidation
    testWidgets('13. Live grant reveals child after invalidation', (
      tester,
    ) async {
      setActiveSession();
      evaluator.decision = NexaBizPermissionDecision.deny;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          invalidationSignal: invalidationSignal,
          child: AppPermissionGate.hide(
            permissionId: _permEdit,
            child: Text('Live Guarded Button'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Live Guarded Button'), findsNothing);

      // Grant permission live in persistence
      evaluator.decision = NexaBizPermissionDecision.allow;
      invalidationSignal.notifyAuthorizationChanged();

      await tester.pumpAndSettle();
      expect(find.text('Live Guarded Button'), findsOneWidget);
    });

    // 14. Logout removes/disables child
    testWidgets('14. Logout removes child immediately', (tester) async {
      setActiveSession();
      evaluator.decision = NexaBizPermissionDecision.allow;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.hide(
            permissionId: _permEdit,
            child: Text('Session Bound Action'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Session Bound Action'), findsOneWidget);

      // User logs out
      sessionController.logout();
      await tester.pumpAndSettle();

      expect(find.text('Session Bound Action'), findsNothing);
    });

    // 15. Company switch reevaluates
    testWidgets('15. Company switch reevaluates permission', (tester) async {
      setActiveSession(companyId: NexaBizCompanyId('cmp-A'));
      evaluator.decision = NexaBizPermissionDecision.allow;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.hide(
            permissionId: _permEdit,
            child: Text('Company Scoped Action'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Company Scoped Action'), findsOneWidget);

      // In Company B, user does not have this permission
      evaluator.decision = NexaBizPermissionDecision.deny;
      setActiveSession(companyId: NexaBizCompanyId('cmp-B'));

      await tester.pumpAndSettle();
      expect(find.text('Company Scoped Action'), findsNothing);
    });

    // 16. Membership change reevaluates
    testWidgets('16. Membership change reevaluates permission', (tester) async {
      setActiveSession(membershipId: NexaBizMembershipId('mem-1'));
      evaluator.decision = NexaBizPermissionDecision.allow;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.hide(
            permissionId: _permEdit,
            child: Text('Membership Action'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Membership Action'), findsOneWidget);

      // Membership changed
      evaluator.decision = NexaBizPermissionDecision.deny;
      setActiveSession(membershipId: NexaBizMembershipId('mem-2'));

      await tester.pumpAndSettle();
      expect(find.text('Membership Action'), findsNothing);
    });

    // 17. Stale ALLOW from old session ignored
    testWidgets('17. Stale ALLOW from old session ignored', (tester) async {
      setActiveSession(sessionId: 'session-old');
      final completer = Completer<NexaBizPermissionDecision>();
      evaluator.delayedCompleter = completer;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.hide(
            permissionId: _permEdit,
            child: Text('Protected UI'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Protected UI'), findsNothing);

      // Active session switches to new session where user has no permission
      evaluator.delayedCompleter = null;
      evaluator.decision = NexaBizPermissionDecision.deny;
      setActiveSession(sessionId: 'session-new');

      // Old evaluation finishes with ALLOW for old session
      completer.complete(NexaBizPermissionDecision.allow);
      await tester.pumpAndSettle();

      // Gate must reject the stale result and remain hidden!
      expect(find.text('Protected UI'), findsNothing);
    });

    // 18. Stale DENY from old session cannot override newer ALLOW
    testWidgets('18. Stale DENY from old session cannot override newer ALLOW', (
      tester,
    ) async {
      setActiveSession(sessionId: 'session-A');
      final completerA = Completer<NexaBizPermissionDecision>();
      evaluator.delayedCompleter = completerA;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.hide(
            permissionId: _permEdit,
            child: Text('Protected UI'),
          ),
        ),
      );
      await tester.pump();

      // Switch to session B which completes fast with ALLOW
      evaluator.delayedCompleter = null;
      evaluator.decision = NexaBizPermissionDecision.allow;
      setActiveSession(sessionId: 'session-B');
      await tester.pumpAndSettle();

      expect(find.text('Protected UI'), findsOneWidget);

      // Now session A's slow DENY finishes
      completerA.complete(NexaBizPermissionDecision.deny);
      await tester.pumpAndSettle();

      // Newer session B's ALLOW must NOT be overridden by stale A's DENY!
      expect(find.text('Protected UI'), findsOneWidget);
    });

    // 19. Dispose during evaluation does not throw
    testWidgets('19. Dispose during evaluation does not throw', (tester) async {
      setActiveSession();
      final completer = Completer<NexaBizPermissionDecision>();
      evaluator.delayedCompleter = completer;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.hide(
            permissionId: _permEdit,
            child: Text('Ephemeral Gate'),
          ),
        ),
      );
      await tester.pump();

      // Remove gate from tree (dispose)
      await tester.pumpWidget(_wrapTestWidget(child: const SizedBox.shrink()));

      // Complete in-flight future after dispose
      completer.complete(NexaBizPermissionDecision.allow);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    // 20. Gate never checks role name
    testWidgets(
      '20. Role names (owner/admin) without permission grant remain hidden',
      (tester) async {
        // Role in session is 'owner', but permission evaluation yields DENIED
        setActiveSession(role: 'owner');
        evaluator.decision = NexaBizPermissionDecision.deny;

        await tester.pumpWidget(
          _wrapTestWidget(
            evaluator: evaluator,
            sessionController: sessionController,
            child: AppPermissionGate.hide(
              permissionId: _permEdit,
              child: Text('Super Restricted UI'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Must be hidden despite 'owner' role string
        expect(find.text('Super Restricted UI'), findsNothing);
      },
    );

    // 21. Optional fallback is rendered on denial
    testWidgets('21. Optional fallback is rendered on denial in Hide mode', (
      tester,
    ) async {
      setActiveSession();
      evaluator.decision = NexaBizPermissionDecision.deny;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.hide(
            permissionId: _permEdit,
            fallback: Text('Fallback: No Access'),
            child: Text('Guarded UI'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Guarded UI'), findsNothing);
      expect(find.text('Fallback: No Access'), findsOneWidget);
    });

    testWidgets(
      '22. DENY blocks mouse and touch even when a generic child remains actionable',
      (tester) async {
        setActiveSession();
        evaluator.decision = NexaBizPermissionDecision.deny;
        var activationCount = 0;

        await tester.pumpWidget(
          _wrapInteractiveTestWidget(
            evaluator: evaluator,
            sessionController: sessionController,
            child: AppPermissionGate(
              permissionId: _permEdit,
              mode: AppPermissionGateMode.disable,
              child: shadcn.PrimaryButton(
                key: const ValueKey('denied-pointer-action'),
                onPressed: () => activationCount++,
                child: const Text('Denied pointer action'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final center = tester.getCenter(
          find.byKey(const ValueKey('denied-pointer-action')),
        );
        final mouse = await tester.startGesture(
          center,
          kind: PointerDeviceKind.mouse,
        );
        await mouse.up();
        final touch = await tester.startGesture(
          center,
          kind: PointerDeviceKind.touch,
        );
        await touch.up();
        await tester.pump();

        expect(activationCount, 0);
      },
    );

    testWidgets(
      '23. DENY excludes focus and blocks Enter and Space for a generic child',
      (tester) async {
        setActiveSession();
        evaluator.decision = NexaBizPermissionDecision.deny;
        final focusNode = FocusNode();
        addTearDown(focusNode.dispose);
        var activationCount = 0;

        await tester.pumpWidget(
          _wrapInteractiveTestWidget(
            evaluator: evaluator,
            sessionController: sessionController,
            child: AppPermissionGate(
              permissionId: _permEdit,
              mode: AppPermissionGateMode.disable,
              child: shadcn.PrimaryButton(
                focusNode: focusNode,
                onPressed: () => activationCount++,
                child: const Text('Denied keyboard action'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        focusNode.requestFocus();
        await tester.pump();
        expect(focusNode.hasFocus, isFalse);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();

        expect(focusNode.hasFocus, isFalse);
        expect(activationCount, 0);
      },
    );

    testWidgets(
      '24. DENY remains discoverable as disabled semantics without actions',
      (tester) async {
        final semantics = tester.ensureSemantics();
        setActiveSession();
        evaluator.decision = NexaBizPermissionDecision.deny;

        await tester.pumpWidget(
          _wrapInteractiveTestWidget(
            evaluator: evaluator,
            sessionController: sessionController,
            child: AppPermissionGate(
              permissionId: _permEdit,
              mode: AppPermissionGateMode.disable,
              child: AppButton(
                key: const ValueKey('denied-semantic-action'),
                label: 'Denied semantic action',
                onPressed: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final node = tester.getSemantics(
          find.byKey(const ValueKey('denied-semantic-action')),
        );
        expect(node.label, contains('Denied semantic action'));
        expect(node.flagsCollection.isEnabled.toBoolOrNull(), isFalse);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
        semantics.dispose();
      },
    );

    testWidgets(
      '25. ALLOW restores pointer focus keyboard and actionable semantics',
      (tester) async {
        final semantics = tester.ensureSemantics();
        setActiveSession();
        evaluator.decision = NexaBizPermissionDecision.allow;
        final focusNode = FocusNode();
        addTearDown(focusNode.dispose);
        var activationCount = 0;

        await tester.pumpWidget(
          _wrapInteractiveTestWidget(
            evaluator: evaluator,
            sessionController: sessionController,
            child: AppPermissionGate.disable(
              permissionId: _permEdit,
              builder: (context, isAllowed) => shadcn.PrimaryButton(
                key: const ValueKey('allowed-action'),
                focusNode: focusNode,
                onPressed: isAllowed ? () => activationCount++ : null,
                child: const Text('Allowed action'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final center = tester.getCenter(
          find.byKey(const ValueKey('allowed-action')),
        );
        final mouse = await tester.startGesture(
          center,
          kind: PointerDeviceKind.mouse,
        );
        await mouse.up();
        final touch = await tester.startGesture(
          center,
          kind: PointerDeviceKind.touch,
        );
        await touch.up();

        focusNode.requestFocus();
        await tester.pump();
        expect(focusNode.hasFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();

        expect(activationCount, 4);
        final node = tester.getSemantics(find.text('Allowed action'));
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        expect(
          node.getSemanticsData().hasAction(SemanticsAction.focus),
          isTrue,
        );
        semantics.dispose();
      },
    );

    testWidgets(
      '26. builder receives false from first loading frame and fail-closed states',
      (tester) async {
        setActiveSession();
        final completer = Completer<NexaBizPermissionDecision>();
        evaluator.delayedCompleter = completer;
        bool? builderAllowed;

        Widget gate({NexaBizPermissionEvaluator? explicitEvaluator}) {
          return AppPermissionGate.disable(
            permissionId: _permEdit,
            evaluator: explicitEvaluator,
            sessionController: sessionController,
            builder: (context, isAllowed) {
              builderAllowed = isAllowed;
              return Text(isAllowed ? 'enabled' : 'disabled');
            },
          );
        }

        await tester.pumpWidget(
          _wrapTestWidget(
            evaluator: evaluator,
            sessionController: sessionController,
            child: gate(),
          ),
        );
        await tester.pump();
        expect(builderAllowed, isFalse, reason: 'loading must start disabled');

        completer.complete(NexaBizPermissionDecision.unknown);
        await tester.pumpAndSettle();
        expect(builderAllowed, isFalse, reason: 'UNKNOWN must stay disabled');

        evaluator.delayedCompleter = null;
        evaluator.shouldThrow = true;
        await tester.pumpWidget(
          _wrapTestWidget(
            child: KeyedSubtree(
              key: const ValueKey('failure-gate'),
              child: gate(explicitEvaluator: evaluator),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(builderAllowed, isFalse, reason: 'failure must stay disabled');

        await tester.pumpWidget(
          _wrapTestWidget(child: gate(explicitEvaluator: null)),
        );
        await tester.pumpAndSettle();
        expect(
          builderAllowed,
          isFalse,
          reason: 'missing evaluator must disable',
        );

        evaluator.shouldThrow = false;
        evaluator.decision = NexaBizPermissionDecision.allow;
        sessionController.logout();
        await tester.pumpWidget(
          _wrapTestWidget(
            evaluator: evaluator,
            sessionController: sessionController,
            child: gate(),
          ),
        );
        await tester.pumpAndSettle();
        expect(builderAllowed, isFalse, reason: 'invalid session must disable');
      },
    );

    testWidgets(
      '27. logout and company switch disable an allowed builder action',
      (tester) async {
        setActiveSession(companyId: NexaBizCompanyId('cmp-A'));
        evaluator.decision = NexaBizPermissionDecision.allow;
        bool? builderAllowed;

        await tester.pumpWidget(
          _wrapTestWidget(
            evaluator: evaluator,
            sessionController: sessionController,
            child: AppPermissionGate.disable(
              permissionId: _permEdit,
              builder: (context, isAllowed) {
                builderAllowed = isAllowed;
                return const Text('Session action');
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(builderAllowed, isTrue);

        evaluator.decision = NexaBizPermissionDecision.deny;
        setActiveSession(companyId: NexaBizCompanyId('cmp-B'));
        await tester.pumpAndSettle();
        expect(builderAllowed, isFalse);

        evaluator.decision = NexaBizPermissionDecision.allow;
        setActiveSession(companyId: NexaBizCompanyId('cmp-A'));
        await tester.pumpAndSettle();
        expect(builderAllowed, isTrue);

        sessionController.logout();
        await tester.pumpAndSettle();
        expect(builderAllowed, isFalse);
      },
    );

    testWidgets(
      '28. live revoke unfocuses and fully disables the formerly active action',
      (tester) async {
        final semantics = tester.ensureSemantics();
        setActiveSession();
        evaluator.decision = NexaBizPermissionDecision.allow;
        final focusNode = FocusNode();
        addTearDown(focusNode.dispose);
        var activationCount = 0;

        await tester.pumpWidget(
          _wrapInteractiveTestWidget(
            evaluator: evaluator,
            sessionController: sessionController,
            invalidationSignal: invalidationSignal,
            child: AppPermissionGate.disable(
              permissionId: _permEdit,
              builder: (context, isAllowed) => shadcn.PrimaryButton(
                key: const ValueKey('revoked-action'),
                focusNode: focusNode,
                onPressed: isAllowed ? () => activationCount++ : null,
                child: const Text('Revoked action'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        focusNode.requestFocus();
        await tester.pump();
        expect(focusNode.hasFocus, isTrue);

        final revokeDecision = Completer<NexaBizPermissionDecision>();
        evaluator.delayedCompleter = revokeDecision;
        invalidationSignal.notifyAuthorizationChanged();
        await tester.pump();

        expect(focusNode.hasFocus, isFalse);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.tap(
          find.byKey(const ValueKey('revoked-action')),
          warnIfMissed: false,
        );
        await tester.pump();
        expect(activationCount, 0);

        final node = tester.getSemantics(
          find.byKey(const ValueKey('revoked-action')),
        );
        expect(node.flagsCollection.isEnabled.toBoolOrNull(), isFalse);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);

        revokeDecision.complete(NexaBizPermissionDecision.deny);
        await tester.pumpAndSettle();
        expect(activationCount, 0);
        semantics.dispose();
      },
    );

    testWidgets(
      '29. live grant restores pointer focus keyboard and semantics',
      (tester) async {
        final semantics = tester.ensureSemantics();
        setActiveSession();
        evaluator.decision = NexaBizPermissionDecision.deny;
        final focusNode = FocusNode();
        addTearDown(focusNode.dispose);
        var activationCount = 0;

        await tester.pumpWidget(
          _wrapInteractiveTestWidget(
            evaluator: evaluator,
            sessionController: sessionController,
            invalidationSignal: invalidationSignal,
            child: AppPermissionGate.disable(
              permissionId: _permEdit,
              builder: (context, isAllowed) => shadcn.PrimaryButton(
                key: const ValueKey('granted-action'),
                focusNode: focusNode,
                onPressed: isAllowed ? () => activationCount++ : null,
                child: const Text('Granted action'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(focusNode.hasFocus, isFalse);

        evaluator.decision = NexaBizPermissionDecision.allow;
        invalidationSignal.notifyAuthorizationChanged();
        await tester.pumpAndSettle();

        focusNode.requestFocus();
        await tester.pump();
        expect(focusNode.hasFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.tap(find.byKey(const ValueKey('granted-action')));
        await tester.pump();
        expect(activationCount, 2);

        final node = tester.getSemantics(find.text('Granted action'));
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        expect(
          node.getSemanticsData().hasAction(SemanticsAction.focus),
          isTrue,
        );
        semantics.dispose();
      },
    );

    testWidgets('30. stale ALLOW cannot restore disable-mode interaction', (
      tester,
    ) async {
      setActiveSession(sessionId: 'stale-session');
      final completer = Completer<NexaBizPermissionDecision>();
      evaluator.delayedCompleter = completer;
      bool? builderAllowed;

      await tester.pumpWidget(
        _wrapTestWidget(
          evaluator: evaluator,
          sessionController: sessionController,
          child: AppPermissionGate.disable(
            permissionId: _permEdit,
            builder: (context, isAllowed) {
              builderAllowed = isAllowed;
              return const Text('Stale action');
            },
          ),
        ),
      );
      await tester.pump();
      expect(builderAllowed, isFalse);

      evaluator.delayedCompleter = null;
      evaluator.decision = NexaBizPermissionDecision.deny;
      setActiveSession(sessionId: 'current-session');
      completer.complete(NexaBizPermissionDecision.allow);
      await tester.pumpAndSettle();

      expect(builderAllowed, isFalse);
    });
  });
}
