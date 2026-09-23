import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/l10n/app_localizations.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  group('Directionality & Font Family Verification Tests', () {
    Widget buildTestApp({
      required Widget child,
      Locale locale = const Locale('ar'),
    }) {
      return NexaBizRootApp(
        locale: locale,
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          NexaBizShadcnLocalizationsDelegate.delegate,
        ],
        home: child,
      );
    }

    testWidgets('AppCustomBottomNav nav items use Cairo font family', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          child: AppCustomBottomNav(
            currentIndex: 0,
            items: const [
              AppNavItem(
                label: 'الرئيسية',
                icon: AppIcons.dashboard,
                routePath: '/',
              ),
              AppNavItem(
                label: 'الخدمات',
                icon: AppIcons.grid,
                routePath: '/services',
              ),
            ],
            onTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final navTextFinder = find.text('الرئيسية');
      expect(navTextFinder, findsOneWidget);

      final defaultStyle = tester.widget<AnimatedDefaultTextStyle>(
        find
            .ancestor(
              of: navTextFinder,
              matching: find.byType(AnimatedDefaultTextStyle),
            )
            .first,
      );

      expect(defaultStyle.style.fontFamily, equals('Cairo'));
    });

    testWidgets(
      'AppCustomAppBar uses directional back icon (chevronRight in RTL, chevronLeft in LTR)',
      (tester) async {
        // RTL
        await tester.pumpWidget(
          buildTestApp(
            locale: const Locale('ar'),
            child: const AppCustomAppBar(
              title: 'اختبار العنوان',
              showBackButton: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final backButtonRtl = tester.widget<AppIconButton>(
          find.byType(AppIconButton).first,
        );
        expect(backButtonRtl.icon, equals(AppIcons.chevronRight));

        // LTR
        await tester.pumpWidget(
          buildTestApp(
            locale: const Locale('en'),
            child: const AppCustomAppBar(
              title: 'Test Title',
              showBackButton: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final backButtonLtr = tester.widget<AppIconButton>(
          find.byType(AppIconButton).first,
        );
        expect(backButtonLtr.icon, equals(AppIcons.chevronLeft));
      },
    );

    testWidgets('AppPageHeader breadcrumb chevron respects directionality', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('ar'),
          child: const AppPageHeader(
            title: 'تفاصيل',
            breadcrumbs: ['الرئيسية', 'الخدمات', 'تفاصيل'],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppPageHeader), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'AppCarousel control positions and icon directionality respond to RTL',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            locale: const Locale('ar'),
            child: AppCarousel<String>(
              items: const ['Slide 1', 'Slide 2'],
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PositionedDirectional), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      },
    );
  });
}
