import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

/// Primary root widget for the NexaBiz application.
class NexaBizApp extends StatelessWidget {
  final GoRouter router;

  const NexaBizApp({
    super.key,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppThemeController.themeModeNotifier,
      builder: (context, themeMode, _) {
        return NexaBizRootApp.router(
          title: 'NexaBiz ERP',
          routerConfig: router,
          themeMode: themeMode,
        );
      },
    );
  }
}
