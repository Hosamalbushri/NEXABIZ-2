import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/session/core_session_controller.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:nexabiz/l10n/app_localizations.dart';
import 'package:nexabiz/packages/identity/presentation/login_screen.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

class _FakeIdentityQueryStore implements CoreIdentityQueryStore {
  CoreAuthUserRef? userToReturn;
  CorePreparedCredential? credentialToReturn;
  List<CoreAuthCompanyRef> companiesToReturn = [];
  CoreLoginLockout? lockoutToReturn;
  bool shouldThrowStorageFailure = false;
  int recordedAttempts = 0;

  @override
  Future<CoreAuthUserRef?> findUserByIdentifier(
    String normalizedIdentifier,
  ) async {
    if (shouldThrowStorageFailure) {
      throw Exception('Simulated database storage disk error');
    }
    return userToReturn;
  }

  @override
  Future<CorePreparedCredential?> readUserCredential(String userId) async {
    if (shouldThrowStorageFailure) {
      throw Exception('Simulated database storage disk error');
    }
    return credentialToReturn;
  }

  @override
  Future<CoreAuthIdentitySnapshot?> readAuthenticationSnapshot(
    String userId,
  ) async {
    if (shouldThrowStorageFailure) {
      throw Exception('Simulated database storage disk error');
    }
    if (userToReturn == null) return null;
    return CoreAuthIdentitySnapshot(
      user: userToReturn!,
      companies: companiesToReturn,
    );
  }

  @override
  Future<CoreLoginLockout?> checkLockout(
    String normalizedIdentifier,
    DateTime nowUtc,
  ) async {
    if (shouldThrowStorageFailure) {
      throw Exception('Simulated database storage disk error');
    }
    return lockoutToReturn;
  }

  @override
  Future<CoreLoginLockout?> recordFailedAttempt(
    String normalizedIdentifier,
    DateTime nowUtc,
  ) async {
    if (shouldThrowStorageFailure) {
      throw Exception('Simulated database storage disk error');
    }
    recordedAttempts++;
    return lockoutToReturn;
  }

  @override
  Future<void> clearFailedAttempts(String normalizedIdentifier) async {
    if (shouldThrowStorageFailure) {
      throw Exception('Simulated database storage disk error');
    }
    recordedAttempts = 0;
  }

  @override
  Future<bool> isSessionEligible(String userId, String? companyId) async =>
      true;

  @override
  Stream<bool> watchSessionEligibility(String userId, String? companyId) =>
      const Stream.empty();
}

Widget _buildTestApp({
  required CoreSessionController sessionController,
  Locale locale = const Locale('en'),
}) {
  return NexaBizRootApp(
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('ar')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      NexaBizShadcnLocalizationsDelegate.delegate,
    ],
    home: LoginScreen(sessionController: sessionController),
  );
}

void main() {
  group('LoginScreen Authentication Failure States', () {
    testWidgets(
      'lockedOut with duration -> localized lockout message in minutes',
      (tester) async {
        final fakeStore = _FakeIdentityQueryStore();
        final nowUtc = DateTime.now().toUtc();
        fakeStore.lockoutToReturn = CoreLoginLockout(
          attemptCount: 5,
          lockedUntil: nowUtc.add(const Duration(minutes: 5)),
        );

        final controller = CoreSessionController(
          authenticateLocalUser: AuthenticateLocalUser(queryStore: fakeStore),
          queryStore: fakeStore,
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _buildTestApp(
            sessionController: controller,
            locale: const Locale('en'),
          ),
        );
        await tester.pumpAndSettle();

        final l10n = AppLocalizations.of(
          tester.element(find.byType(LoginScreen)),
        );

        // Enter credentials
        await tester.enterText(
          find.widgetWithText(AppTextField, l10n.loginIdentifier),
          'admin@nexabiz.test',
        );
        await tester.enterText(
          find.widgetWithText(AppTextField, l10n.loginPassword),
          'WrongPassword123!',
        );

        await tester.tap(find.widgetWithText(AppButton, l10n.loginSubmit));
        await tester.pumpAndSettle();

        // Lockout with minutes duration is visible
        expect(find.text(l10n.loginLockedOutMinutes(5)), findsOneWidget);
        expect(find.text(l10n.loginRetry), findsOneWidget);
      },
    );

    testWidgets(
      'lockedOut with duration -> localized lockout message in Arabic (seconds)',
      (tester) async {
        final nowUtc = DateTime.now().toUtc();
        final arStore = _FakeIdentityQueryStore();
        arStore.lockoutToReturn = CoreLoginLockout(
          attemptCount: 5,
          lockedUntil: nowUtc.add(const Duration(seconds: 45)),
        );
        final arController = CoreSessionController(
          authenticateLocalUser: AuthenticateLocalUser(queryStore: arStore),
          queryStore: arStore,
        );
        addTearDown(arController.dispose);

        await tester.pumpWidget(
          _buildTestApp(
            sessionController: arController,
            locale: const Locale('ar'),
          ),
        );
        await tester.pumpAndSettle();

        final arL10n = AppLocalizations.of(
          tester.element(find.byType(LoginScreen)),
        );

        await tester.enterText(
          find.widgetWithText(AppTextField, arL10n.loginIdentifier),
          'admin@nexabiz.test',
        );
        await tester.enterText(
          find.widgetWithText(AppTextField, arL10n.loginPassword),
          'WrongPassword123!',
        );

        await tester.tap(find.widgetWithText(AppButton, arL10n.loginSubmit));
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                widget.data != null &&
                widget.data!.contains('ثانية') &&
                widget.data!.contains('تم قفل الحساب مؤقتًا'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'lockedOut without future duration -> generic localized lockout message',
      (tester) async {
        final fakeStore = _FakeIdentityQueryStore();
        final nowUtc = DateTime.now().toUtc();
        fakeStore.lockoutToReturn = CoreLoginLockout(
          attemptCount: 5,
          lockedUntil: nowUtc.add(const Duration(milliseconds: 1)),
        );

        // Or test controller returning lockedOut with null lockoutExpiresAt
        final controller = CoreSessionController(
          authenticateLocalUser: AuthenticateLocalUser(
            queryStore: fakeStore,
            nowProvider: () => DateTime.now().toUtc(),
          ),
          queryStore: fakeStore,
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _buildTestApp(
            sessionController: controller,
            locale: const Locale('en'),
          ),
        );
        await tester.pumpAndSettle();

        final l10n = AppLocalizations.of(
          tester.element(find.byType(LoginScreen)),
        );

        await tester.enterText(
          find.widgetWithText(AppTextField, l10n.loginIdentifier),
          'admin@nexabiz.test',
        );
        await tester.enterText(
          find.widgetWithText(AppTextField, l10n.loginPassword),
          'WrongPassword123!',
        );

        await tester.tap(find.widgetWithText(AppButton, l10n.loginSubmit));
        await tester.pumpAndSettle();

        expect(find.text(l10n.loginLockedOut), findsOneWidget);
      },
    );

    testWidgets(
      'storageFailure -> safe localized error visible without leaks',
      (tester) async {
        final fakeStore = _FakeIdentityQueryStore();
        fakeStore.shouldThrowStorageFailure = true;

        final controller = CoreSessionController(
          authenticateLocalUser: AuthenticateLocalUser(queryStore: fakeStore),
          queryStore: fakeStore,
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _buildTestApp(
            sessionController: controller,
            locale: const Locale('en'),
          ),
        );
        await tester.pumpAndSettle();

        final l10n = AppLocalizations.of(
          tester.element(find.byType(LoginScreen)),
        );

        await tester.enterText(
          find.widgetWithText(AppTextField, l10n.loginIdentifier),
          'admin@nexabiz.test',
        );
        await tester.enterText(
          find.widgetWithText(AppTextField, l10n.loginPassword),
          'Password123!',
        );

        await tester.tap(find.widgetWithText(AppButton, l10n.loginSubmit));
        await tester.pumpAndSettle();

        // Safe localized message is visible
        expect(find.text(l10n.loginStorageFailure), findsOneWidget);

        // Verify that no internal technical details leak to the UI
        expect(find.textContaining('Simulated database'), findsNothing);
        expect(find.textContaining('Exception'), findsNothing);
        expect(find.textContaining('disk error'), findsNothing);
        expect(find.textContaining('stack trace'), findsNothing);
      },
    );

    testWidgets(
      'invalidCredentials -> does not reveal whether account exists',
      (tester) async {
        final fakeStore = _FakeIdentityQueryStore();
        // 1. Non-existent account
        fakeStore.userToReturn = null;

        final controller = CoreSessionController(
          authenticateLocalUser: AuthenticateLocalUser(queryStore: fakeStore),
          queryStore: fakeStore,
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _buildTestApp(
            sessionController: controller,
            locale: const Locale('en'),
          ),
        );
        await tester.pumpAndSettle();

        final l10n = AppLocalizations.of(
          tester.element(find.byType(LoginScreen)),
        );

        // Attempt login for non-existent account
        await tester.enterText(
          find.widgetWithText(AppTextField, l10n.loginIdentifier),
          'nonexistent@nexabiz.test',
        );
        await tester.enterText(
          find.widgetWithText(AppTextField, l10n.loginPassword),
          'WrongPassword123!',
        );
        await tester.tap(find.widgetWithText(AppButton, l10n.loginSubmit));
        await tester.pump();
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
        });
        await tester.pumpAndSettle();

        expect(find.text(l10n.loginInvalidCredentials), findsOneWidget);

        // Tap retry to reset error
        await tester.tap(find.text(l10n.loginRetry));
        await tester.pumpAndSettle();

        // 2. Existing account with wrong credentials
        fakeStore.userToReturn = const CoreAuthUserRef(
          id: 'user-001',
          name: 'Existing User',
          email: 'existing@nexabiz.test',
          status: 'active',
        );
        // Credential is empty or invalid
        fakeStore.credentialToReturn = null;

        await tester.enterText(
          find.widgetWithText(AppTextField, l10n.loginIdentifier),
          'existing@nexabiz.test',
        );
        await tester.enterText(
          find.widgetWithText(AppTextField, l10n.loginPassword),
          'WrongPassword123!',
        );
        await tester.tap(find.widgetWithText(AppButton, l10n.loginSubmit));
        await tester.pump();
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
        });
        await tester.pumpAndSettle();

        // The exact same error message is shown, giving zero enumeration hints
        expect(find.text(l10n.loginInvalidCredentials), findsOneWidget);
        expect(find.textContaining('Existing User'), findsNothing);
        expect(find.textContaining('user-001'), findsNothing);
      },
    );
  });
}
