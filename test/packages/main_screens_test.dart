import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/localization/app_locale_controller.dart';
import 'package:nexabiz/l10n/app_localizations.dart';
import 'package:nexabiz/packages/reports/presentation/reports_screen.dart';
import 'package:nexabiz/packages/services/presentation/services_screen.dart';
import 'package:nexabiz/packages/settings/presentation/settings_screen.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  group('Main Screens Widget Tests', () {
    Widget wrapWithApp(Widget child) {
      return ValueListenableBuilder<Locale>(
        valueListenable: AppLocaleController.localeNotifier,
        builder: (context, locale, _) {
          return NexaBizRootApp(
            home: child,
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
    }

    testWidgets('renders ServicesScreen correctly with service categories', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWithApp(const ServicesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Services Hub'), findsOneWidget);
      expect(
        find.text('Available Business Capabilities & Service Launchers'),
        findsOneWidget,
      );
      expect(find.text('Financial & Accounting'), findsOneWidget);
      expect(find.text('General Ledger'), findsOneWidget);
    });

    testWidgets('renders ReportsScreen correctly with report hub categories', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWithApp(const ReportsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Reports Hub'), findsOneWidget);
      expect(
        find.text('Financial, Operational, & Analytical Reports'),
        findsOneWidget,
      );
      expect(find.text('Financial Reports'), findsOneWidget);
    });

    testWidgets(
      'renders SettingsScreen correctly with theme and security settings',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(wrapWithApp(const SettingsScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Settings & Configuration'), findsOneWidget);
        expect(find.text('Application Preferences'), findsOneWidget);
        expect(find.text('Dark Mode'), findsOneWidget);
        expect(find.text('Company & Currency Profile'), findsOneWidget);
        expect(find.text('Select Company'), findsOneWidget);
      },
    );

    testWidgets(
      'SettingsScreen renders without overflow across all viewports (360, 600, 800, 1200, 1440)',
      (tester) async {
        final viewports = [
          const Size(360, 800),
          const Size(600, 800),
          const Size(800, 600),
          const Size(1200, 800),
          const Size(1440, 900),
        ];

        for (final size in viewports) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(wrapWithApp(const SettingsScreen()));
          await tester.pumpAndSettle();

          expect(find.text('Settings & Configuration'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        tester.view.resetPhysicalSize();
      },
    );

    testWidgets(
      'ReportsScreen renders cleanly across viewports (360, 600, 800, 1200, 1440)',
      (tester) async {
        final viewports = [
          const Size(360, 800),
          const Size(600, 800),
          const Size(800, 600),
          const Size(1200, 800),
          const Size(1440, 900),
        ];

        for (final size in viewports) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(wrapWithApp(const ReportsScreen()));
          await tester.pumpAndSettle();

          expect(find.text('Reports Hub'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        tester.view.resetPhysicalSize();
      },
    );

    testWidgets(
      'SettingsScreen and ReportsScreen render cleanly under RTL directionality',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.rtl,
            child: wrapWithApp(const SettingsScreen()),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Settings & Configuration'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.rtl,
            child: wrapWithApp(const ReportsScreen()),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Reports Hub'), findsOneWidget);
        expect(tester.takeException(), isNull);

        tester.view.resetPhysicalSize();
      },
    );

    testWidgets(
      'SettingsScreen and ReportsScreen tolerate increased text scale (1.0, 1.3, 1.5) under RTL',
      (tester) async {
        final textScales = [1.0, 1.3, 1.5];

        for (final scale in textScales) {
          tester.view.physicalSize = const Size(360, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: wrapWithApp(const SettingsScreen()),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Settings & Configuration'), findsOneWidget);
          expect(tester.takeException(), isNull);

          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: wrapWithApp(const ReportsScreen()),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Reports Hub'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        tester.view.resetPhysicalSize();
      },
    );

    testWidgets('SettingsScreen dark mode switch toggles theme state on tap', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWithApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Dark Mode'), findsOneWidget);
      final switchFinder = find.byType(AppSwitch);
      expect(switchFinder, findsOneWidget);

      final initialMode = AppThemeController.themeModeNotifier.value;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      final updatedMode = AppThemeController.themeModeNotifier.value;
      expect(updatedMode, isNot(initialMode));
    });
  });
}
