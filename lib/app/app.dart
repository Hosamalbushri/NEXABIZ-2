import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../l10n/app_localizations.dart';
import 'localization/app_locale_controller.dart';

/// Primary root widget for the NexaBiz application.
class NexaBizApp extends StatelessWidget {
  final GoRouter router;

  const NexaBizApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppThemeController.themeModeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            return NexaBizRootApp.router(
              title: 'NexaBiz ERP',
              routerConfig: router,
              themeMode: themeMode,
              locale: locale,
              supportedLocales: AppLocaleController.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                NexaBizShadcnLocalizationsDelegate.delegate,
              ],
            );
          },
        );
      },
    );
  }
}
