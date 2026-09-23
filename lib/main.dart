import 'package:flutter/widgets.dart';
import 'app/app.dart';
import 'app/bootstrap/app_bootstrap.dart';
import 'app/localization/app_locale_controller.dart';

NexaBizApp createProductionApp(AppBootstrapResult bootstrap) => NexaBizApp(
  router: bootstrap.router,
  permissionEvaluator: bootstrap.permissionEvaluator,
  sessionController: bootstrap.sessionController,
  authorizationInvalidationSignal: bootstrap.authorizationInvalidationSignal,
  authorizationAdministration: bootstrap.authorizationAdministration,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocaleController.initialize();
  final bootstrap = await AppBootstrap.initialize();
  runApp(createProductionApp(bootstrap));
}
