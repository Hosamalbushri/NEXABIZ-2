import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  group('AppModuleHubGrid & AppModuleHubTile Contract Tests', () {
    Widget wrapWithApp(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets(
      'post-fix: clean rendering without overflow across viewports (320, 360, 390, 600, 800, 1200, 1440)',
      (tester) async {
        final viewports = [
          const Size(320, 640),
          const Size(360, 800),
          const Size(390, 844),
          const Size(600, 900),
          const Size(800, 600),
          const Size(1200, 800),
          const Size(1440, 900),
        ];

        for (final size in viewports) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            wrapWithApp(
              AppModuleHubGrid(
                children: [
                  AppModuleHubTile(
                    title: 'General Ledger Audit Verification',
                    subtitle:
                        'Journal verification and multi-currency balancing',
                    icon: AppIcons.check,
                    onTap: () {},
                  ),
                  AppModuleHubTile(
                    title: 'Trial Balance & Financial Summaries',
                    subtitle: 'Debit/Credit summaries and account ledgers',
                    icon: AppIcons.wallet,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('General Ledger Audit Verification'),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        }
        tester.view.resetPhysicalSize();
      },
    );

    testWidgets(
      'supports RTL directionality with long Arabic labels without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.rtl,
            child: wrapWithApp(
              AppModuleHubGrid(
                children: [
                  AppModuleHubTile(
                    title: 'مراجعة التدقيق المالي الشامل والتسويات',
                    subtitle: 'ملخص الحسابات والعملات الأجنبية',
                    icon: AppIcons.check,
                    onTap: () {},
                  ),
                  AppModuleHubTile(
                    title: 'ميزان المراجعة والقوائم المالية',
                    subtitle: 'الأصول والخصومات والمدين والدائن',
                    icon: AppIcons.wallet,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('مراجعة التدقيق المالي الشامل والتسويات'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'tolerates extreme text scaling (1.0, 1.3, 1.5, 2.0) on 360px RTL viewport',
      (tester) async {
        final textScales = [1.0, 1.3, 1.5, 2.0];

        for (final scale in textScales) {
          tester.view.physicalSize = const Size(360, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: wrapWithApp(
                  AppModuleHubGrid(
                    children: [
                      AppModuleHubTile(
                        title: 'General Ledger Audit Verification',
                        subtitle:
                            'Journal verification and multi-currency balancing',
                        icon: AppIcons.check,
                        onTap: () {},
                      ),
                      AppModuleHubTile(
                        title: 'Trial Balance & Financial Summaries',
                        subtitle: 'Debit/Credit summaries and account ledgers',
                        icon: AppIcons.wallet,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('General Ledger Audit Verification'),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        }
        tester.view.resetPhysicalSize();
      },
    );

    testWidgets('preserves tap interaction callback on AppModuleHubTile', (
      tester,
    ) async {
      var tapped = false;
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        wrapWithApp(
          AppModuleHubGrid(
            children: [
              AppModuleHubTile(
                title: 'Tap Target Test',
                subtitle: 'Tap callback verification',
                icon: AppIcons.check,
                onTap: () {
                  tapped = true;
                },
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tap Target Test'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
