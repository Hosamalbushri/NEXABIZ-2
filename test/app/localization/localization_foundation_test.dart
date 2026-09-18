import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nexabiz/app/localization/app_locale_controller.dart';
import 'package:nexabiz/l10n/app_localizations.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLocaleController.initialize();
  });

  group('AppLocaleController Unit Tests', () {
    test('initializes with default fallback locale (en)', () {
      expect(AppLocaleController.currentLocale.languageCode, equals('en'));
      expect(AppLocaleController.isRtl, isFalse);
    });

    test('supports en and ar locales', () {
      expect(AppLocaleController.isSupportedCode('en'), isTrue);
      expect(AppLocaleController.isSupportedCode('ar'), isTrue);
      expect(AppLocaleController.isSupportedCode('fr'), isFalse);
    });

    test('sets locale and toggles language', () async {
      await AppLocaleController.setLocale(const Locale('ar'));
      expect(AppLocaleController.currentLocale.languageCode, equals('ar'));
      expect(AppLocaleController.isRtl, isTrue);

      await AppLocaleController.toggleLanguage();
      expect(AppLocaleController.currentLocale.languageCode, equals('en'));
      expect(AppLocaleController.isRtl, isFalse);
    });

    test('persists locale choice across initialize call', () async {
      await AppLocaleController.setLocale(const Locale('ar'));
      expect(AppLocaleController.currentLocale.languageCode, equals('ar'));

      // Simulate app restart by re-initializing controller
      await AppLocaleController.initialize();
      expect(AppLocaleController.currentLocale.languageCode, equals('ar'));
      expect(AppLocaleController.isRtl, isTrue);
    });
  });

  group('Localization Foundation Widget Tests', () {
    Widget buildTestApp({required Widget child}) {
      return ValueListenableBuilder<Locale>(
        valueListenable: AppLocaleController.localeNotifier,
        builder: (context, locale, _) {
          return NexaBizRootApp(
            title: 'NexaBiz ERP Test',
            locale: locale,
            supportedLocales: AppLocaleController.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              NexaBizShadcnLocalizationsDelegate.delegate,
            ],
            home: child,
          );
        },
      );
    }

    testWidgets('renders English UI text and LTR directionality',
        (tester) async {
      await AppLocaleController.setLocale(const Locale('en'));

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Column(
                children: [
                  Text(l10n.dashboardTitle),
                  Text(l10n.navDashboard),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('NexaBiz Dashboard'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);

      final directionality =
          tester.widget<Directionality>(find.byType(Directionality).first);
      expect(directionality.textDirection, equals(TextDirection.ltr));
    });

    testWidgets('renders Arabic UI text and RTL directionality',
        (tester) async {
      await AppLocaleController.setLocale(const Locale('ar'));

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Column(
                children: [
                  Text(l10n.dashboardTitle),
                  Text(l10n.navDashboard),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('لوحة تحكم نيكسابيز'), findsOneWidget);
      expect(find.text('لوحة التحكم'), findsOneWidget);

      final directionality =
          tester.widget<Directionality>(find.byType(Directionality).first);
      expect(directionality.textDirection, equals(TextDirection.rtl));
    });

    testWidgets(
        'runtime locale switch updates string resources without breaking widget tree',
        (tester) async {
      await AppLocaleController.setLocale(const Locale('en'));

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(l10n.servicesTitle);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Services Hub'), findsOneWidget);

      // Switch runtime locale to Arabic
      await AppLocaleController.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();

      expect(find.text('مركز الخدمات'), findsOneWidget);
      expect(find.text('Services Hub'), findsNothing);
    });

    testWidgets(
        'runtime locale switch preserves GoRouter deep navigation stack',
        (tester) async {
      await AppLocaleController.setLocale(const Locale('en'));

      final router = GoRouter(
        initialLocation: '/deep/step1',
        routes: [
          GoRoute(
            path: '/deep/step1',
            builder: (context, state) => Column(
              children: [
                const Text('Step 1 Root'),
                AppButton(
                  label: 'Push Step 2',
                  onPressed: () => context.push('/deep/step2'),
                ),
              ],
            ),
          ),
          GoRoute(
            path: '/deep/step2',
            builder: (context, state) {
              final l10n = AppLocalizations.of(context);
              return Column(
                children: [
                  Text('Active Node: ${l10n.navSettings}'),
                  AppButton(
                    label: 'Pop',
                    onPressed: () => context.pop(),
                  ),
                ],
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            return NexaBizRootApp.router(
              title: 'Router Test',
              routerConfig: router,
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
        ),
      );
      await tester.pumpAndSettle();

      // Navigate deep into step 2
      await tester.tap(find.text('Push Step 2'));
      await tester.pumpAndSettle();

      expect(find.text('Active Node: Settings'), findsOneWidget);

      // Switch language to Arabic while deep in stack
      await AppLocaleController.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();

      // Verify node remains Active Step 2 in Arabic
      expect(find.text('Active Node: الإعدادات'), findsOneWidget);

      // Verify popping step 2 returns to step 1
      await tester.tap(find.text('Pop'));
      await tester.pumpAndSettle();

      expect(find.text('Step 1 Root'), findsOneWidget);
    });
  });
}
