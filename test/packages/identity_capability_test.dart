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
import 'package:nexabiz/packages/identity/identity_capability.dart';
import 'package:nexabiz/packages/identity/presentation/identity_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('manifest registers identity with descriptive permission IDs', () {
    final capability = NexaBizCapabilityManifest.capabilities
        .whereType<IdentityCapability>()
        .single;
    expect(capability.capabilityId, 'identity');
    expect(capability.dependsOn, isEmpty);
    expect(capability, isA<NexaBizCapabilityWithRuntimeContributions>());
    expect(capability.setupContribution, isNull);
    expect(
      capability.permissionContribution.declaredPermissionIds
          .map((id) => id.value)
          .toSet(),
      {'identity.session.view', 'identity.user.manage'},
    );
    expect(capability.permissionContribution.requiredPermissions, isEmpty);
  });

  test('bootstrap registers identity and its canonical route', () async {
    final bootstrap = await bootstrapForTest(initialLocation: '/identity');
    addTearDown(bootstrap.router.dispose);
    expect(bootstrap.capabilityRegistry.containsCapability('identity'), isTrue);
    expect(
      bootstrap.navigationRegistry.getRouteByPath('/identity').routeId,
      const NexaBizRouteId(namespace: 'identity', routeName: 'home'),
    );
  });

  test('identity translation keys exist in both ARB catalogs', () {
    final en =
        jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
            as Map<String, dynamic>;
    final ar =
        jsonDecode(File('lib/l10n/app_ar.arb').readAsStringSync())
            as Map<String, dynamic>;
    expect(en.keys.toSet(), ar.keys.toSet());
    for (final key in [
      'identityTitle',
      'identitySubtitle',
      'identityStatusFoundationOnly',
      'identityResponsibilityLocalSession',
      'identityResponsibilityAdminUser',
      'identityResponsibilityCompanyMembership',
      'identityResponsibilityCompanySwitchEndsSession',
    ]) {
      expect(en[key], isA<String>());
      expect(ar[key], isA<String>());
    }
  });

  test('identity screen uses public nexabiz_ui only', () {
    final source = File(
      'lib/packages/identity/presentation/identity_screen.dart',
    ).readAsStringSync();
    expect(source, contains('package:nexabiz_ui/nexabiz_ui.dart'));
    expect(source, isNot(contains('package:nexabiz_ui/src/')));
    expect(source, isNot(contains('package:shadcn_flutter/')));
  });

  testWidgets('identity route renders in English and Arabic', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocaleController.setLocale(const Locale('en'));
    final bootstrap = await bootstrapForTest(initialLocation: '/identity');
    addTearDown(bootstrap.router.dispose);
    await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
    await tester.pumpAndSettle();
    expect(find.byType(IdentityScreen), findsOneWidget);
    expect(find.text('Identity'), findsOneWidget);
    expect(find.text('Identity responsibilities planned'), findsOneWidget);
    expect(find.text('Local session'), findsOneWidget);

    await AppLocaleController.setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
    expect(find.text('الهوية'), findsOneWidget);
    expect(find.text('مسؤوليات الهوية المخطط لها'), findsOneWidget);
    expect(find.text('الجلسة المحلية'), findsOneWidget);
    expect(
      bootstrap.router.routeInformationProvider.value.uri.path,
      '/identity',
    );
  });
}
