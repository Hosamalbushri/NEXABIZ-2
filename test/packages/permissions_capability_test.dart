import '../support/bootstrap_test_helper.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/app.dart';
import 'package:nexabiz/app/bootstrap/nexabiz_capability_manifest.dart';
import 'package:nexabiz/app/localization/app_locale_controller.dart';
import 'package:nexabiz/core/capabilities/contributions/nexabiz_capability_runtime_contributions.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_access_requirement.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_id.dart';
import 'package:nexabiz/packages/permissions/permissions_capability.dart';
import 'package:nexabiz/packages/permissions/presentation/permissions_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('manifest registers permissions with canonical catalog IDs', () {
    final capability = NexaBizCapabilityManifest.capabilities
        .whereType<PermissionsCapability>()
        .single;
    expect(capability.capabilityId, 'permissions');
    expect(capability.dependsOn, isEmpty);
    expect(capability, isA<NexaBizCapabilityWithRuntimeContributions>());
    expect(capability.setupContribution, isNull);
    expect(
      capability.permissionContribution.declaredPermissionIds
          .map((id) => id.value)
          .toSet(),
      {
        'permissions.catalog.view',
        'permissions.policy.review',
        'permissions.role.manage',
        'permissions.policy.manage',
        'permissions.assignment.manage',
      },
    );
    expect(capability.permissionContribution.requiredPermissions, isEmpty);
  });

  test('bootstrap registers permissions and its canonical route', () async {
    final bootstrap = await bootstrapForTest(initialLocation: '/permissions');
    addTearDown(bootstrap.router.dispose);
    expect(
      bootstrap.capabilityRegistry.containsCapability('permissions'),
      isTrue,
    );
    final route = bootstrap.navigationRegistry.getRouteByPath('/permissions');
    expect(
      route.routeId,
      const NexaBizRouteId(namespace: 'permissions', routeName: 'home'),
    );
    expect(
      route.accessRequirement,
      const NexaBizRouteAccessRequirement(
        requiresReadySetup: true,
        requiresActiveSession: true,
        requiresCompanyScope: true,
      ),
    );
  });

  test('permissions translation keys exist in both ARB catalogs', () {
    final en =
        jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
            as Map<String, dynamic>;
    final ar =
        jsonDecode(File('lib/l10n/app_ar.arb').readAsStringSync())
            as Map<String, dynamic>;
    expect(en.keys.toSet(), ar.keys.toSet());
    for (final key in [
      'permissionsTitle',
      'permissionsSubtitle',
      'permissionsStatusFoundationOnly',
      'permissionsResponsibilityCatalog',
      'permissionsResponsibilityRouteIntent',
      'permissionsResponsibilityOperationIntent',
      'permissionsResponsibilityNoRuntimeGrants',
    ]) {
      expect(en[key], isA<String>());
      expect(ar[key], isA<String>());
    }
  });

  test('permissions shell uses public UI and defines no roles or grants', () {
    final capabilitySource = File(
      'lib/packages/permissions/permissions_capability.dart',
    ).readAsStringSync();
    final screenSource = File(
      'lib/packages/permissions/presentation/permissions_screen.dart',
    ).readAsStringSync();
    expect(screenSource, contains('package:nexabiz_ui/nexabiz_ui.dart'));
    for (final source in [capabilitySource, screenSource]) {
      expect(source, isNot(contains('package:nexabiz_ui/src/')));
      expect(source, isNot(contains('package:shadcn_flutter/')));
      expect(
        source,
        isNot(contains(RegExp(r'\bclass\s+\w*(?:Role|Grant)\w*'))),
      );
    }
  });

  testWidgets('permissions route renders in English and Arabic', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await AppLocaleController.setLocale(const Locale('en'));
    final bootstrap = await bootstrapForTest(initialLocation: '/permissions');
    addTearDown(bootstrap.router.dispose);
    await tester.pumpWidget(NexaBizApp(router: bootstrap.router));
    await tester.pumpAndSettle();
    expect(find.byType(PermissionsScreen), findsOneWidget);
    expect(find.text('Permissions'), findsOneWidget);
    expect(find.text('Permission definitions only'), findsOneWidget);
    expect(find.text('Permission catalog'), findsOneWidget);

    await AppLocaleController.setLocale(const Locale('ar'));
    await tester.pumpAndSettle();
    expect(find.text('الصلاحيات'), findsOneWidget);
    expect(find.text('تعريفات صلاحيات فقط'), findsOneWidget);
    expect(find.text('كتالوج الصلاحيات'), findsOneWidget);
    expect(
      bootstrap.router.routeInformationProvider.value.uri.path,
      '/permissions',
    );
  });
}
