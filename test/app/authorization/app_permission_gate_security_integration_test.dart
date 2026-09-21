import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/authorization/app_permission_gate.dart';
import 'package:nexabiz/app/authorization/app_permission_scope.dart';
import 'package:nexabiz/core/authorization/nexabiz_authorization_context.dart';
import 'package:nexabiz/core/authorization/nexabiz_membership_id.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_denied_exception.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_evaluator.dart';
import 'package:nexabiz/core/authorization/nexabiz_permission_guard.dart';
import 'package:nexabiz/core/company/nexabiz_company_scope.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/permissions/nexabiz_permission_intent.dart';
import 'package:nexabiz/core/session/core_session_controller.dart';
import 'package:nexabiz/core/session/nexabiz_session.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';

// ---------------------------------------------------------------------------
// Business Domain Fixture for Security Integration Test
// ---------------------------------------------------------------------------

final _permUpdateProfile = NexaBizPermissionId('company.profile.manage');
final _testUserId = NexaBizUserId('usr-sec-01');
final _testCompanyId = NexaBizCompanyId('cmp-sec-01');
final _testMembershipId = NexaBizMembershipId('mem-sec-01');

class _SecurityTestIdentityStore implements CoreIdentityQueryStore {
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

class _SecurityIntegrationEvaluator implements NexaBizPermissionEvaluator {
  NexaBizPermissionDecision decision = NexaBizPermissionDecision.deny;

  @override
  Future<NexaBizPermissionDecision> evaluate({
    required NexaBizAuthorizationContext context,
    required NexaBizPermissionId permissionId,
  }) async {
    return decision;
  }
}

/// Simulated Business UseCase enforcing canonical UseCase PermissionGuard
class UpdateCompanyProfileUseCase {
  final NexaBizDefaultPermissionGuard _permissionGuard;
  int mutationExecutionCount = 0;

  UpdateCompanyProfileUseCase(this._permissionGuard);

  Future<void> execute({
    required NexaBizAuthorizationContext context,
    required String newProfileName,
  }) async {
    // 1. Authoritative security enforcement
    await _permissionGuard.requirePermission(
      context: context,
      permissionId: _permUpdateProfile,
    );

    // 2. Business mutation strictly after authorization
    mutationExecutionCount++;
  }
}

void main() {
  group(
    'Security Integration: AppPermissionGate (UX) vs PermissionGuard (Authoritative)',
    () {
      late CoreSessionController sessionController;
      late _SecurityIntegrationEvaluator evaluator;
      late NexaBizDefaultPermissionGuard permissionGuard;
      late UpdateCompanyProfileUseCase useCase;

      setUp(() {
        sessionController = CoreSessionController(
          authenticateLocalUser: AuthenticateLocalUser(
            queryStore: _SecurityTestIdentityStore(),
          ),
          queryStore: _SecurityTestIdentityStore(),
        );
        evaluator = _SecurityIntegrationEvaluator();
        permissionGuard = NexaBizDefaultPermissionGuard(evaluator);
        useCase = UpdateCompanyProfileUseCase(permissionGuard);

        sessionController.setSessionForTesting(
          NexaBizSession.active(
            userId: _testUserId,
            companyId: _testCompanyId,
            membershipId: _testMembershipId,
            role: 'member',
            sessionId: 'sec-sess-1',
          ),
        );
      });

      tearDown(() async {
        await sessionController.dispose();
      });

      testWidgets(
        '1. Bypassing or forcing UI button to render does NOT allow UseCase mutation when DENIED',
        (tester) async {
          // Evaluator returns DENY
          evaluator.decision = NexaBizPermissionDecision.deny;

          var caughtException = false;

          // Render a forced UI button that invokes the UseCase regardless of gate
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: AppPermissionScope(
                permissionEvaluator: evaluator,
                sessionController: sessionController,
                child: GestureDetector(
                  key: const ValueKey('forced_button'),
                  onTap: () async {
                    final authContext = NexaBizAuthorizationContext.fromSession(
                      sessionController.currentSession,
                    );
                    try {
                      await useCase.execute(
                        context: authContext,
                        newProfileName: 'Hacked Profile Name',
                      );
                    } on NexaBizPermissionDeniedException {
                      caughtException = true;
                    }
                  },
                  child: const Text('Forced Action Button'),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Tap forced button
          await tester.tap(find.byKey(const ValueKey('forced_button')));
          await tester.pumpAndSettle();

          // Verify that UseCase PermissionGuard blocked the mutation with zero side effects
          expect(
            caughtException,
            isTrue,
            reason:
                'UseCase PermissionGuard MUST reject unauthorized execution.',
          );
          expect(
            useCase.mutationExecutionCount,
            0,
            reason:
                'Business mutation MUST NOT execute when permission is denied.',
          );
        },
      );

      testWidgets(
        '2. Direct caller invocation of UseCase throws NexaBizPermissionDeniedException on DENY',
        (tester) async {
          evaluator.decision = NexaBizPermissionDecision.deny;

          final authContext = NexaBizAuthorizationContext.fromSession(
            sessionController.currentSession,
          );

          expect(
            () => useCase.execute(
              context: authContext,
              newProfileName: 'Direct Call Attempt',
            ),
            throwsA(isA<NexaBizPermissionDeniedException>()),
          );
          expect(useCase.mutationExecutionCount, 0);
        },
      );

      testWidgets(
        '3. When ALLOWED, AppPermissionGate reveals action and UseCase executes successfully',
        (tester) async {
          evaluator.decision = NexaBizPermissionDecision.allow;

          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: AppPermissionScope(
                permissionEvaluator: evaluator,
                sessionController: sessionController,
                child: AppPermissionGate.hide(
                  permissionId: _permUpdateProfile,
                  child: GestureDetector(
                    key: const ValueKey('legit_button'),
                    onTap: () async {
                      final authContext =
                          NexaBizAuthorizationContext.fromSession(
                            sessionController.currentSession,
                          );
                      await useCase.execute(
                        context: authContext,
                        newProfileName: 'Authorized Update',
                      );
                    },
                    child: const Text('Legitimate Update Action'),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Button is visible because it is ALLOWED
          expect(find.byKey(const ValueKey('legit_button')), findsOneWidget);

          await tester.tap(find.byKey(const ValueKey('legit_button')));
          await tester.pumpAndSettle();

          expect(useCase.mutationExecutionCount, 1);
        },
      );
    },
  );
}
