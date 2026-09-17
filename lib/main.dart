import 'package:flutter/widgets.dart';
import 'app/app.dart';
import 'app/bootstrap/app_bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrap = await AppBootstrap.initialize();
  runApp(NexaBizApp(router: bootstrap.router));
}
