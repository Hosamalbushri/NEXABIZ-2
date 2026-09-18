import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/l10n/app_localizations.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  group('Specific Components Directionality & Localization Tests', () {
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

    testWidgets('AppModuleHubTile icon flips in RTL when mirrorIconInRtl is true', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('ar'),
          child: AppModuleHubTile(
            icon: Icons.arrow_forward,
            title: 'المبيعات',
            subtitle: 'إدارة المبيعات',
            mirrorIconInRtl: true,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final transformFinder = find.ancestor(
        of: find.byIcon(Icons.arrow_forward),
        matching: find.byType(Transform),
      );
      expect(transformFinder, findsOneWidget);
    });

    testWidgets('AppModuleHubCard chevron adapts to RTL and LTR', (tester) async {
      // RTL
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('ar'),
          child: AppModuleHubCard(
            icon: Icons.star,
            title: 'المبيعات',
            subtitle: 'إدارة المبيعات',
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final rtlIconWidget = tester.widget<Icon>(find.byIcon(Icons.chevron_left));
      expect(rtlIconWidget, isNotNull);

      // LTR
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('en'),
          child: AppModuleHubCard(
            icon: Icons.star,
            title: 'Sales',
            subtitle: 'Sales Management',
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final ltrIconWidget = tester.widget<Icon>(find.byIcon(Icons.chevron_right));
      expect(ltrIconWidget, isNotNull);
    });

    testWidgets('AppDropdown hint adapts dynamically to locale', (tester) async {
      // RTL
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('ar'),
          child: AppDropdown<String>(
            items: const [AppDropdownItem(value: '1', label: 'الخيار 1')],
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('اختر الخيار...'), findsOneWidget);

      // LTR
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('en'),
          child: AppDropdown<String>(
            items: const [AppDropdownItem(value: '1', label: 'Option 1')],
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select option...'), findsOneWidget);
    });

    testWidgets('AppDateField hint adapts dynamically to locale', (tester) async {
      // RTL
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('ar'),
          child: AppDateField(
            value: null,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('اختر التاريخ...'), findsOneWidget);

      // LTR
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('en'),
          child: AppDateField(
            value: null,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select date...'), findsOneWidget);
    });

    testWidgets('AppDateRangeField hint adapts dynamically to locale', (tester) async {
      // RTL
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('ar'),
          child: AppDateRangeField(
            value: null,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('اختر الفترة الزمنية...'), findsOneWidget);

      // LTR
      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('en'),
          child: AppDateRangeField(
            value: null,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select date range...'), findsOneWidget);
    });

    testWidgets('AppCheckbox and AppSwitch render labels without errors', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: Column(
            children: [
              AppCheckbox(
                value: true,
                label: 'موافق على الشروط',
                onChanged: (_) {},
              ),
              AppSwitch(
                value: true,
                label: 'تفعيل التنبيهات',
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('موافق على الشروط'), findsOneWidget);
      expect(find.text('تفعيل التنبيهات'), findsOneWidget);
    });

    testWidgets('AppSliderField renders min max labels correctly', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: AppSliderField(
            value: const shadcn.SliderValue.single(50),
            min: 0,
            max: 100,
            label: 'الحجم',
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    });
  });
}
