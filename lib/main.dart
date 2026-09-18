import 'package:flutter/widgets.dart';
import 'app/app.dart';
import 'app/bootstrap/app_bootstrap.dart';
import 'app/localization/app_locale_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocaleController.initialize();
  final bootstrap = await AppBootstrap.initialize();
  runApp(NexaBizApp(router: bootstrap.router));
}
