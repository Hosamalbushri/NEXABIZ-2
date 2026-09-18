import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/localization/app_locale_controller.dart';
import 'package:nexabiz/l10n/app_localizations.dart';
import 'package:nexabiz/packages/demo/presentation/demo_page.dart';
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
              home: child ?? const DemoPage(),
            );
          },
        ),
      ),
    );
  }

  group('DemoPage Migration Regression Test Suite', () {
    testWidgets('Test A — Canonical rendering with AppPage architecture', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(DemoPage), findsOneWidget);
      expect(find.byType(AppPage), findsOneWidget);
      expect(find.byType(AppSurface), findsOneWidget);
      expect(find.byType(AppCard), findsOneWidget);
      expect(find.text('NexaBiz Demo Capability'), findsOneWidget);
      expect(find.text('Architecture Principles'), findsOneWidget);
      expect(find.text('System Ready'), findsOneWidget);
      expect(find.text('Documentation'), findsOneWidget);
    });

    testWidgets('Test B — Primary interaction with System Ready action', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final readyButton = find.widgetWithText(AppButton, 'System Ready');
      expect(readyButton, findsOneWidget);

      await tester.ensureVisible(readyButton);
      await tester.tap(readyButton);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Test C — Compact viewport (360x640) without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableWidget(viewport: const Size(360, 640)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DemoPage), findsOneWidget);
      expect(find.text('System Ready'), findsOneWidget);
    });

    testWidgets('Test D — Expanded viewport (1200x800) without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableWidget(viewport: const Size(1200, 800)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DemoPage), findsOneWidget);
      expect(find.text('System Ready'), findsOneWidget);
    });

    testWidgets('Test E — RTL directionality rendering', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableWidget(textDirection: TextDirection.rtl),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DemoPage), findsOneWidget);
      expect(find.text('NexaBiz Demo Capability'), findsOneWidget);
      expect(find.text('Architecture Principles'), findsOneWidget);
    });

    testWidgets('Test F — Text scale (1.5x) at compact viewport (360px)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableWidget(
          viewport: const Size(360, 800),
          textScaleFactor: 1.5,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DemoPage), findsOneWidget);
      expect(find.text('System Ready'), findsOneWidget);
    });
  });
}
