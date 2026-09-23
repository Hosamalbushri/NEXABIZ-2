import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/bootstrap/app_bootstrap.dart';
import 'package:nexabiz/core/identity/authenticate_local_user.dart';
import 'package:nexabiz/core/setup/initialize_nexabiz_core.dart';
import 'package:path/path.dart' as p;

/// Opens each bootstrap test against its own disposable Core database.
Future<AppBootstrapResult> bootstrapForTest({
  String initialLocation = '/dashboard',
  bool authenticated = true,
}) async {
  final directory = Directory.systemTemp.createTempSync(
    'nexabiz_bootstrap_test_',
  );
  try {
    final result = await AppBootstrap.initialize(
      initialLocation: initialLocation,
      databasePath: p.join(directory.path, 'nexabiz.sqlite'),
    );
    addTearDown(() async {
      await result.sessionController.dispose();
      await result.coreInstallationStore.close();
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });

    if (authenticated) {
      Future<void> runAuth() async {
        final initializer = InitializeNexaBizCore(result.coreInstallationStore);
        await initializer(
          const CoreInitializationInput(
            companyCode: 'COMP01',
            companyName: 'Test Company',
            adminName: 'Admin User',
            adminEmail: 'admin@nexabiz.test',
            password: 'Password123!',
          ),
        );

        await result.sessionController.login(
          const CoreAuthenticationInput(
            identifier: 'admin@nexabiz.test',
            password: 'Password123!',
          ),
        );

        result.router.go(initialLocation);
      }

      final binding = WidgetsBinding.instance;
      if (binding is TestWidgetsFlutterBinding) {
        await binding.runAsync(runAuth);
      } else {
        await runAuth();
      }
    }

    return result;
  } catch (_) {
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
    rethrow;
  }
}
