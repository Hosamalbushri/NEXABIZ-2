import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/bootstrap/app_bootstrap.dart';
import 'package:nexabiz/packages/company/company_capability.dart';
import 'package:nexabiz/packages/identity/identity_capability.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Identity & Company Capability & Presentation Tests', () {
    late Directory tempDir;
    late String testDbPath;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('nexabiz_cap_test_');
      testDbPath = '${tempDir.path}/nexabiz_capability_test.sqlite';
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test(
      'IdentityCapability and CompanyCapability contribute routes correctly',
      () {
        final identityCap = IdentityCapability();
        final companyCap = CompanyCapability();

        expect(identityCap.capabilityId, equals('identity'));
        expect(companyCap.capabilityId, equals('company'));

        final identityRoutes = identityCap.navigationContribution.routes;
        final companyRoutes = companyCap.navigationContribution.routes;

        expect(
          identityRoutes.map((r) => r.path),
          containsAll(['/identity', '/login']),
        );
        expect(
          companyRoutes.map((r) => r.path),
          containsAll(['/company', '/company-selection']),
        );
      },
    );

    test(
      'AppBootstrap initializes CoreSessionController and router with identity/company routes',
      () async {
        final result = await AppBootstrap.initialize(databasePath: testDbPath);
        try {
          expect(result.sessionController, isNotNull);
          expect(
            result.navigationRegistry.routes.any((r) => r.path == '/login'),
            isTrue,
          );
          expect(
            result.navigationRegistry.routes.any(
              (r) => r.path == '/company-selection',
            ),
            isTrue,
          );
        } finally {
          await result.coreInstallationStore.close();
        }
      },
    );

    test(
      'Identity and Company presentation files restrict UI imports to nexabiz_ui',
      () {
        final loginFile = File(
          'lib/packages/identity/presentation/login_screen.dart',
        );
        final companySelectionFile = File(
          'lib/packages/company/presentation/company_selection_screen.dart',
        );

        final loginContent = loginFile.readAsStringSync();
        final companySelectionContent = companySelectionFile.readAsStringSync();

        expect(loginContent.contains("package:shadcn_flutter"), isFalse);
        expect(
          companySelectionContent.contains("package:shadcn_flutter"),
          isFalse,
        );

        expect(
          loginContent.contains("package:nexabiz_ui/nexabiz_ui.dart"),
          isTrue,
        );
        expect(
          companySelectionContent.contains(
            "package:nexabiz_ui/nexabiz_ui.dart",
          ),
          isTrue,
        );
      },
    );
  });
}
