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
import 'package:nexabiz/packages/company/company_capability.dart';
import 'package:nexabiz/packages/company/presentation/company_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('manifest contains company only, with descriptive permissions', () {
    final capabilities = NexaBizCapabilityManifest.capabilities;
    final company = capabilities.whereType<CompanyCapability>().single;
    expect(
      capabilities.where((capability) => capability.capabilityId == 'tenancy'),
      isEmpty,
    );
    expect(company.capabilityId, 'company');
    expect(company.dependsOn, isEmpty);
    expect(company, isA<NexaBizCapabilityWithRuntimeContributions>());
    expect(company.setupContribution, isNull);
    expect(
      company.permissionContribution.declaredPermissionIds
          .map((id) => id.value)
          .toSet(),
      {
        'company.profile.view',
        'company.profile.manage',
        'company.membership.view',
      },
    );
    expect(company.permissionContribution.requiredPermissions, isEmpty);
  });

  test('bootstrap registers company and its canonical route', () async {
    final bootstrap = await bootstrapForTest(initialLocation: '/company');
    addTearDown(bootstrap.router.dispose);
    expect(bootstrap.capabilityRegistry.containsCapability('company'), isTrue);
    expect(
      bootstrap.navigationRegistry.getRouteByPath('/company').routeId,
      const NexaBizRouteId(namespace: 'company', routeName: 'home'),
    );
  });

  test('company translation keys exist in both ARB catalogs', () {
    final en =
        jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
            as Map<String, dynamic>;
    final ar =
        jsonDecode(File('lib/l10n/app_ar.arb').readAsStringSync())
            as Map<String, dynamic>;
    expect(en.keys.toSet(), ar.keys.toSet());
    for (final key in [
      'companyTitle',
      'companySubtitle',
      'companyStatusFoundationOnly',
      'companyResponsibilityActiveCompany',
      'companyResponsibilityMembership',
      'companyResponsibilityTenantScope',
      'companyResponsibilitySwitchEndsSession',
    ]) {
      expect(en[key], isA<String>());
      expect(ar[key], isA<String>());
    }
  });

  test('company screen uses public nexabiz_ui only', () {
    final source = File(
      'lib/packages/company/presentation/company_screen.dart',
    ).readAsStringSync();
    expect(source, contains('package:nexabiz_ui/nexabiz_ui.dart'));
    expect(source, isNot(contains('package:nexabiz_ui/src/')));
    expect(source, isNot(contains('package:shadcn_flutter/')));
  });

  testWidgets('company route renders in English and Arabic', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocaleController.setLocale(const Locale('en'));
    final bootstrap = await bootstrapForTest(initialLocation: '/company');
    addTearDown(bootstrap.router.dispose);
    await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
    await tester.pumpAndSettle();
    expect(find.byType(CompanyScreen), findsOneWidget);
    expect(find.text('Company'), findsOneWidget);
    expect(find.text('Company responsibilities planned'), findsOneWidget);
    expect(
      find.text('A future company switch must end the current session'),
      findsOneWidget,
    );

    await AppLocaleController.setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
    expect(find.text('الشركة'), findsOneWidget);
    expect(find.text('مسؤوليات الشركة المخطط لها'), findsOneWidget);
    expect(
      find.text('يجب أن ينهي تبديل الشركة مستقبلًا الجلسة الحالية'),
      findsOneWidget,
    );
    expect(
      bootstrap.router.routeInformationProvider.value.uri.path,
      '/company',
    );
  });
}
