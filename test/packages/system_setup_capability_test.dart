import '../support/bootstrap_test_helper.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/app.dart';
import 'package:nexabiz/app/bootstrap/nexabiz_capability_manifest.dart';
import 'package:nexabiz/app/localization/app_locale_controller.dart';
import 'package:nexabiz/core/capabilities/contributions/nexabiz_capability_runtime_contributions.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_id.dart';
import 'package:nexabiz/packages/system_setup/system_setup_capability.dart';
import 'package:nexabiz/packages/system_setup/presentation/system_setup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:nexabiz/app/persistence/drift_core_installation_store.dart';

void main() {
  test('manifest registers system_setup with descriptive requirements', () {
    final capability = NexaBizCapabilityManifest.capabilities
        .whereType<SystemSetupCapability>()
        .single;
    expect(capability.capabilityId, 'system_setup');
    expect(capability.dependsOn, isEmpty);
    expect(capability, isA<NexaBizCapabilityWithRuntimeContributions>());
    expect(capability.permissionContribution, isNull);
    expect(
      capability.setupContribution.providedRequirements
          .map((requirement) => requirement.value)
          .toSet(),
      {'system_setup.company', 'system_setup.admin_user'},
    );
    expect(capability.setupContribution.requiredRequirements, isEmpty);
  });

  test(
    'bootstrap locks registries and registers canonical system setup route',
    () async {
      final bootstrap = await bootstrapForTest(
        initialLocation: '/system-setup',
      );
      addTearDown(bootstrap.router.dispose);
      expect(
        bootstrap.capabilityRegistry.containsCapability('system_setup'),
        isTrue,
      );
      expect(
        bootstrap.navigationRegistry.getRouteByPath('/system-setup').routeId,
        const NexaBizRouteId(namespace: 'system_setup', routeName: 'home'),
      );
    },
  );

  test('system setup translation keys exist in both ARB catalogs', () {
    final en =
        jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
            as Map<String, dynamic>;
    final ar =
        jsonDecode(File('lib/l10n/app_ar.arb').readAsStringSync())
            as Map<String, dynamic>;
    expect(en.keys.toSet(), ar.keys.toSet());
    for (final key in [
      'systemSetupTitle',
      'systemSetupSubtitle',
      'systemSetupStatusFoundationOnly',
      'systemSetupRequirementCompany',
      'systemSetupRequirementAdminUser',
    ]) {
      expect(en[key], isA<String>());
      expect(ar[key], isA<String>());
    }
  });

  test('system setup presentation imports only the public UI package', () {
    final source = File(
      'lib/packages/system_setup/presentation/system_setup_screen.dart',
    ).readAsStringSync();
    expect(source, contains('package:nexabiz_ui/nexabiz_ui.dart'));
    expect(source, isNot(contains('package:nexabiz_ui/src/')));
    expect(source, isNot(contains('package:shadcn_flutter/')));
  });

  testWidgets('route renders the Core setup form in English and Arabic', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocaleController.setLocale(const Locale('en'));
    final bootstrap = await bootstrapForTest(initialLocation: '/system-setup');
    addTearDown(bootstrap.router.dispose);
    await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
    await tester.pumpAndSettle();
    expect(find.byType(SystemSetupScreen), findsOneWidget);
    expect(find.text('System Setup'), findsOneWidget);
    expect(find.text('Company code'), findsOneWidget);
    expect(find.text('Company name'), findsOneWidget);
    expect(find.text('Administrator email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Functional currency'), findsNothing);
    expect(find.text('Default accounts'), findsNothing);

    await AppLocaleController.setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
    expect(find.text('إعداد النظام'), findsOneWidget);
    expect(find.text('رمز الشركة'), findsOneWidget);
    expect(find.text('اسم الشركة'), findsOneWidget);
    expect(find.text('البريد الإلكتروني للمسؤول'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsOneWidget);
    expect(find.text('العملة الوظيفية'), findsNothing);
    expect(find.text('الحسابات الافتراضية'), findsNothing);
    expect(
      bootstrap.router.routeInformationProvider.value.uri.path,
      '/system-setup',
    );
  });

  testWidgets('invalid confirmation stays on setup and shows localized error', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocaleController.setLocale(const Locale('en'));
    final bootstrap = await bootstrapForTest(initialLocation: '/system-setup');
    addTearDown(bootstrap.router.dispose);
    await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
    await tester.pumpAndSettle();
    final fields = tester
        .widgetList<AppTextField>(find.byType(AppTextField))
        .toList();
    fields[4].controller!.text = 'correct horse battery staple';
    fields[5].controller!.text = 'different password';
    await tester.ensureVisible(find.text('Create company and administrator'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create company and administrator'));
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(
      bootstrap.router.routeInformationProvider.value.uri.path,
      '/system-setup',
    );
    expect(
      (await bootstrap.coreInstallationStore.readReadiness()).isReady,
      isFalse,
    );
  });

  testWidgets(
    'successful submit creates Core once and enters dashboard without a session',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await AppLocaleController.setLocale(const Locale('en'));
      final bootstrap = await bootstrapForTest(
        initialLocation: '/system-setup',
      );
      addTearDown(bootstrap.router.dispose);
      await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(AppTextField).at(0), 'ACME');
      await tester.enterText(find.byType(AppTextField).at(1), 'Acme Company');
      await tester.enterText(find.byType(AppTextField).at(2), 'Owner');
      await tester.enterText(find.byType(AppTextField).at(3), 'owner@example.com');
      await tester.enterText(find.byType(AppTextField).at(4), 'correct horse battery staple');
      await tester.enterText(find.byType(AppTextField).at(5), 'correct horse battery staple');
      await tester.ensureVisible(find.text('Create company and administrator'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.text('Create company and administrator'));
        await tester.pump();
        for (var i = 0; i < 100; i++) {
          if ((await bootstrap.coreInstallationStore.readReadiness()).isReady) {
            break;
          }
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      });
      await tester.pumpAndSettle();
      expect((await bootstrap.coreInstallationStore.readReadiness()).isReady, isTrue);
      expect(find.text('Could not save setup. Try again.'), findsNothing);
      expect(find.text('Enter a company code, company name, administrator name, valid email, and a password of at least 12 characters.'), findsNothing);
      expect(
        bootstrap.router.routeInformationProvider.value.uri.path,
        '/dashboard',
      );
      expect(
        (await bootstrap.coreInstallationStore.readReadiness()).isReady,
        isTrue,
      );
      final db = (bootstrap.coreInstallationStore as DriftCoreInstallationStore)
          .database;
      expect(await db.select(db.coreCompanies).get(), hasLength(1));
      expect(await db.select(db.coreUsers).get(), hasLength(1));
    },
  );
}
