import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/l10n/app_localizations.dart';
import 'package:nexabiz/packages/splash/presentation/splash_screen.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

Widget _buildSplashApp({Locale locale = const Locale('en')}) {
  return NexaBizRootApp(
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('ar')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      NexaBizShadcnLocalizationsDelegate.delegate,
    ],
    home: const SplashScreen(),
  );
}

void main() {
  group('SplashScreen Rendering & Visual Integrity', () {
    testWidgets('renders brand title, subtitle, and circular loading state', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSplashApp(locale: const Locale('en')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final l10n = AppLocalizations.of(
        tester.element(find.byType(SplashScreen)),
      );

      expect(find.text(l10n.splashTitle), findsOneWidget);
      expect(find.text(l10n.authAppSubtitle), findsOneWidget);
      expect(find.text(l10n.splashSubtitle), findsOneWidget);
      expect(find.byType(AppLoading), findsOneWidget);
    });

    testWidgets('renders correctly in Arabic RTL without layout issues', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSplashApp(locale: const Locale('ar')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final l10n = AppLocalizations.of(
        tester.element(find.byType(SplashScreen)),
      );

      expect(find.text(l10n.splashTitle), findsOneWidget);
      expect(find.text(l10n.authAppSubtitle), findsOneWidget);
      expect(find.text(l10n.splashSubtitle), findsOneWidget);
      expect(find.byType(AppLoading), findsOneWidget);
    });

    for (final width in [320.0, 360.0, 600.0, 1024.0]) {
      testWidgets('renders across viewport width $width without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 700);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildSplashApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(tester.takeException(), isNull);
        expect(find.byType(SplashScreen), findsOneWidget);
      });
    }
  });
}
