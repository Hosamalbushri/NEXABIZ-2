import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/localization/app_locale_controller.dart';
import 'package:nexabiz/l10n/app_localizations.dart';
import 'package:nexabiz/packages/dashboard/presentation/dashboard_screen.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLocaleController.initialize();
  });

  Widget buildTestableWidget({
    Widget? child,
    Size viewport = const Size(800, 600),
    TextDirection textDirection = TextDirection.ltr,
    double textScaleFactor = 1.0,
  }) {
    return MediaQuery(
      data: MediaQueryData(
        size: viewport,
        textScaler: TextScaler.linear(textScaleFactor),
      ),
      child: Directionality(
        textDirection: textDirection,
        child: ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            return NexaBizRootApp(
              locale: locale,
              supportedLocales: AppLocaleController.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                NexaBizShadcnLocalizationsDelegate.delegate,
              ],
              home: child ?? const DashboardScreen(),
            );
          },
        ),
      ),
    );
  }

  group('DashboardScreen RTL Contract & Responsive Regression Test Suite', () {
    testWidgets('Test A — LTR rendering and KPI structure', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('NexaBiz Dashboard'), findsOneWidget);
      expect(find.text('Mobile UI Playground'), findsOneWidget);
      expect(find.text('Total Sales'), findsOneWidget);
      expect(find.text('\$124,500.00'), findsAtLeastNWidgets(1));
      expect(find.text('Enterprise Highlights'), findsOneWidget);
      expect(find.text('Recent Activity'), findsOneWidget);
    });

    testWidgets('Test B — RTL rendering and directional alignment', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableWidget(textDirection: TextDirection.rtl),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('NexaBiz Dashboard'), findsOneWidget);
      expect(find.text('Mobile UI Playground'), findsOneWidget);
      expect(find.text('Total Sales'), findsOneWidget);
      expect(find.text('Recent Activity'), findsOneWidget);
    });

    testWidgets('Test C — Compact RTL viewport (360x800) without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableWidget(
          viewport: const Size(360, 800),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('NexaBiz Dashboard'), findsOneWidget);
    });

    testWidgets('Test D — Expanded RTL viewport (1200x800) without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableWidget(
          viewport: const Size(1200, 800),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('NexaBiz Dashboard'), findsOneWidget);
    });

    testWidgets('Test E — Text scale stress (1.5x) at compact RTL (360px)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableWidget(
          viewport: const Size(360, 1000),
          textDirection: TextDirection.rtl,
          textScaleFactor: 1.5,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('NexaBiz Dashboard'), findsOneWidget);
    });

    testWidgets(
      'Test F — Arabic locale rendering with Mobile UI Playground banner',
      (tester) async {
        await AppLocaleController.setLocale(const Locale('ar'));

        await tester.pumpWidget(
          buildTestableWidget(textDirection: TextDirection.rtl),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(DashboardScreen), findsOneWidget);
        expect(find.text('لوحة تحكم نيكسابيز'), findsOneWidget);
        expect(find.text('مختبر واجهات الجوال'), findsOneWidget);
        expect(find.text('UI-01'), findsOneWidget);
      },
    );
  });
}
