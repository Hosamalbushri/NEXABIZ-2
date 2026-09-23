import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

import '../core/authorization/nexabiz_permission_evaluator.dart';
import '../core/session/core_session_controller.dart';
import '../l10n/app_localizations.dart';
import 'authorization/app_permission_scope.dart';
import 'authorization/nexabiz_authorization_administration.dart';
import 'localization/app_locale_controller.dart';

/// Primary root widget for the NexaBiz application.
class NexaBizApp extends StatelessWidget {
  final GoRouter router;
  final NexaBizPermissionEvaluator? permissionEvaluator;
  final CoreSessionController? sessionController;
  final Listenable? authorizationInvalidationSignal;
  final NexaBizAuthorizationAdministration? authorizationAdministration;

  const NexaBizApp({
    super.key,
    required this.router,
    this.permissionEvaluator,
    this.sessionController,
    this.authorizationInvalidationSignal,
    this.authorizationAdministration,
  });

  @override
  Widget build(BuildContext context) {
    Widget app = ValueListenableBuilder(
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

    if (permissionEvaluator != null && sessionController != null) {
      app = AppPermissionScope(
        permissionEvaluator: permissionEvaluator!,
        sessionController: sessionController!,
        invalidationSignal: authorizationInvalidationSignal,
        authorizationAdministration: authorizationAdministration,
        child: app,
      );
    }

    return app;
  }
}
