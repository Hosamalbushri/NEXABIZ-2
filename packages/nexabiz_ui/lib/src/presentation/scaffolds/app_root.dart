import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../../localization/nexa_biz_shadcn_localizations_delegate.dart';
import '../../localization/nexabiz_ui_localizations.dart';
import '../../theme/app_theme.dart';

/// NexaBiz Design System canonical root application container.
///
/// Encapsulates `shadcn_flutter`'s [shadcn.ShadcnApp] internal root, exposing
/// the single entry point for the NexaBiz application shell without requiring
/// direct application-level imports of `shadcn_flutter`.
class NexaBizRootApp extends StatelessWidget {
  final RouterConfig<Object>? routerConfig;
  final Widget? home;
  final String title;
  final bool debugShowCheckedModeBanner;
  final Widget Function(BuildContext context, Widget? child)? builder;
  final Locale? locale;
  final Iterable<Locale>? supportedLocales;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final shadcn.ThemeMode? themeMode;

  const NexaBizRootApp.router({
    super.key,
    required this.routerConfig,
    this.title = 'NexaBiz ERP',
    this.debugShowCheckedModeBanner = false,
    this.builder,
    this.locale,
    this.supportedLocales,
    this.localizationsDelegates,
    this.themeMode,
  }) : home = null;

  const NexaBizRootApp({
    super.key,
    this.home,
    this.title = 'NexaBiz ERP',
    this.debugShowCheckedModeBanner = false,
    this.builder,
    this.locale,
    this.supportedLocales,
    this.localizationsDelegates,
    this.themeMode,
  }) : routerConfig = null;

  @override
  Widget build(BuildContext context) {
    final lightMaterialTheme = AppTheme.materialLight();
    final darkMaterialTheme = AppTheme.materialDark();

    final shadcnLight = AppTheme.shadcnLight();
    final shadcnDark = AppTheme.shadcnDark();

    final activeThemeMode = themeMode ?? shadcn.ThemeMode.system;

    final resolvedMaterialTheme = switch (activeThemeMode) {
      shadcn.ThemeMode.dark => darkMaterialTheme,
      shadcn.ThemeMode.light => lightMaterialTheme,
      shadcn.ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark
            ? darkMaterialTheme
            : lightMaterialTheme,
    };

    final locales = supportedLocales ?? const <Locale>[Locale('en', 'US')];
    final effectiveDelegates = [
      NexaBizUiLocalizations.delegate,
      NexaBizShadcnLocalizationsDelegate.delegate,
      ...?localizationsDelegates,
    ];

    Widget effectiveBuilder(BuildContext context, Widget? child) {
      final drawerWrappedChild = shadcn.DrawerOverlay(
        child: child ?? const SizedBox.shrink(),
      );
      if (builder != null) {
        return builder!(context, drawerWrappedChild);
      }
      return drawerWrappedChild;
    }

    if (routerConfig != null) {
      return shadcn.ShadcnApp.router(
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        title: title,
        routerConfig: routerConfig,
        themeMode: activeThemeMode,
        theme: shadcnLight,
        darkTheme: shadcnDark,
        materialTheme: resolvedMaterialTheme,
        locale: locale,
        supportedLocales: locales,
        localizationsDelegates: effectiveDelegates,
        builder: effectiveBuilder,
      );
    }

    return shadcn.ShadcnApp(
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      title: title,
      home: home,
      themeMode: activeThemeMode,
      theme: shadcnLight,
      darkTheme: shadcnDark,
      materialTheme: resolvedMaterialTheme,
      locale: locale,
      supportedLocales: locales,
      localizationsDelegates: effectiveDelegates,
      builder: effectiveBuilder,
    );
  }
}
