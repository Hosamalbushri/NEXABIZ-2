import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  Widget buildTestApp(
    Widget child, {
    TextDirection textDirection = TextDirection.ltr,
    double textScaleFactor = 1.0,
  }) {
    return shadcn.ShadcnApp(
      theme: AppTheme.light(),
      home: Directionality(
        textDirection: textDirection,
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScaleFactor)),
          child: child,
        ),
      ),
    );
  }

  group('Phase 07 — Canonical Page Architecture Multi-Viewport Tests', () {
    const representativeWidths = <double>[
      320.0,
      430.0,
      599.0,
      600.0,
      800.0,
      999.0,
      1000.0,
      1200.0,
      1439.0,
      1440.0,
      1920.0,
    ];

    for (final width in representativeWidths) {
      testWidgets('AppPage renders without overflow on width ${width}px', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = Size(width, 800.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildTestApp(
            AppPage(
              header: const AppPageHeader(
                title: 'General Ledger',
                subtitle: 'Financial entries audit',
              ),
              child: Column(
                children: [
                  for (int i = 0; i < 5; i++)
                    AppCard(child: Text('Transaction Row #$i')),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('General Ledger'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('AppFormPage renders without overflow on width ${width}px', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = Size(width, 800.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildTestApp(
            AppFormPage(
              title: 'Create Account',
              subtitle: 'Chart of accounts setup',
              body: Column(
                children: [
                  AppTextField(
                    label: 'Account Code',
                    controller: TextEditingController(text: '1010'),
                  ),
                  AppTextField(
                    label: 'Account Name',
                    controller: TextEditingController(text: 'Cash on Hand'),
                  ),
                ],
              ),
              onSubmit: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Create Account'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('AppListPage renders without overflow on width ${width}px', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = Size(width, 800.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final items = List.generate(10, (i) => 'Entity Record $i');
        await tester.pumpWidget(
          buildTestApp(
            AppListPage<String>(
              title: 'Suppliers Directory',
              items: items,
              contentBuilder: (context, records) {
                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, i) =>
                      AppListTile(title: Text(records[i])),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Suppliers Directory'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('AppTablePage renders without overflow on width ${width}px', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = Size(width, 800.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildTestApp(
            AppTablePage(
              title: 'Balance Sheet',
              table: const Center(child: Text('Data Table Body')),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Balance Sheet'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'AppDetailsPage renders without overflow on width ${width}px',
        (WidgetTester tester) async {
          tester.view.physicalSize = Size(width, 800.0);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          await tester.pumpWidget(
            buildTestApp(
              const AppDetailsPage(
                title: 'Customer Details',
                subtitle: 'ID: CUST-00921',
                body: AppCard(child: Text('Customer Profile Content')),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Customer Details'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'AppDashboardPage renders without overflow on width ${width}px',
        (WidgetTester tester) async {
          tester.view.physicalSize = Size(width, 800.0);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          await tester.pumpWidget(
            buildTestApp(
              const AppDashboardPage(
                title: 'Executive Dashboard',
                subtitle: 'Real-time financial summary',
                statsGrid: AppCard(child: Text('KPI Grid')),
                content: AppCard(child: Text('Main Analytics Stream')),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Executive Dashboard'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'AppSettingsPage renders without overflow on width ${width}px',
        (WidgetTester tester) async {
          tester.view.physicalSize = Size(width, 800.0);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          await tester.pumpWidget(
            buildTestApp(
              AppSettingsPage(
                title: 'System Preferences',
                subtitle: 'Application configuration',
                sections: [
                  AppSection(
                    title: 'Security',
                    child: const AppCard(child: Text('2FA Configuration')),
                  ),
                  AppSection(
                    title: 'Localization',
                    child: const AppCard(child: Text('Language and Currency')),
                  ),
                ],
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('System Preferences'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'AppMasterDetailPage renders without overflow on width ${width}px',
        (WidgetTester tester) async {
          tester.view.physicalSize = Size(width, 800.0);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          await tester.pumpWidget(
            buildTestApp(
              const AppMasterDetailPage(
                title: 'Permissions & Roles',
                master: AppCard(child: Text('Roles List')),
                detail: AppCard(child: Text('Selected Role Matrix')),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Permissions & Roles'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('Phase 07 — Directionality, Text Scaling & Local Width Tests', () {
    testWidgets(
      'AppPage and AppPageHeader render in Arabic RTL without collision',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360.0, 700.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildTestApp(
            AppPage(
              header: AppPageHeader(
                title: 'دليل الحسابات والمراكز المالية',
                subtitle: 'نظام إدارة المعاملات المالية',
                showBackButton: true,
                actions: [
                  AppIconButton(
                    icon: AppIcons.plus,
                    tooltip: 'إضافة',
                    onPressed: () {},
                  ),
                ],
              ),
              child: const Text('محتوى الصفحة العربي'),
            ),
            textDirection: TextDirection.rtl,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('دليل الحسابات والمراكز المالية'), findsOneWidget);
        expect(find.text('محتوى الصفحة العربي'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('AppPage renders cleanly at 200% text scale without overflow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360.0, 700.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestApp(
          const AppPage(
            header: AppPageHeader(
              title: 'Accessible Audit Page',
              subtitle: 'High contrast & 200% font scaling verification',
            ),
            child: AppCard(
              child: Text(
                'Large text content verified under double typography scale factor.',
              ),
            ),
          ),
          textScaleFactor: 2.0,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Accessible Audit Page'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      '420px container in 1600px window responds to local container width',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1600.0, 1000.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        AppBreakpointTier? detectedTier;

        await tester.pumpWidget(
          buildTestApp(
            Center(
              child: SizedBox(
                width: 420.0,
                height: 700.0,
                child: AppResponsiveScope(
                  info: const AppResponsiveInfo(
                    tier: AppBreakpointTier.compact,
                    constraints: BoxConstraints.tightFor(width: 420.0),
                    availableWidth: 420.0,
                  ),
                  child: AppPage(
                    header: const AppPageHeader(title: 'Nested Container'),
                    child: Builder(
                      builder: (context) {
                        detectedTier = AppResponsive.tierOf(context);
                        return Text('Detected Tier: $detectedTier');
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Nested Container'), findsOneWidget);
        expect(detectedTier, equals(AppBreakpointTier.compact));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'AppPageHeader with long title and multiple actions scales cleanly without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320.0, 600.0);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildTestApp(
            AppPageHeader(
              title:
                  'Extremely Long Financial Document Title That Must Scale Down',
              subtitle: 'Fiscal Period 2026 Q3 Final Reconciliation Report',
              showBackButton: true,
              actions: [
                AppIconButton(
                  icon: AppIcons.search,
                  tooltip: 'Search',
                  onPressed: () {},
                ),
                AppIconButton(
                  icon: AppIcons.settings,
                  tooltip: 'Settings',
                  onPressed: () {},
                ),
                AppIconButton(
                  icon: AppIcons.refresh,
                  tooltip: 'Refresh',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Canonical pages handle Loading, Empty and Error states properly',
      (WidgetTester tester) async {
        // 1. Loading
        await tester.pumpWidget(
          buildTestApp(
            const AppListPage<String>(
              title: 'Audit Logs',
              items: [],
              isLoading: true,
              contentBuilder: _dummyContentBuilder,
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(AppLoading), findsOneWidget);

        // 2. Empty
        await tester.pumpWidget(
          buildTestApp(
            const AppListPage<String>(
              title: 'Audit Logs',
              items: [],
              emptyTitle: 'No records found',
              contentBuilder: _dummyContentBuilder,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AppEmptyState), findsOneWidget);
        expect(find.text('No records found'), findsOneWidget);

        // 3. Error with retry
        bool retried = false;
        await tester.pumpWidget(
          buildTestApp(
            AppListPage<String>(
              title: 'Audit Logs',
              items: const [],
              errorText: 'Database connection failed',
              onRetry: () => retried = true,
              contentBuilder: _dummyContentBuilder,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AppErrorState), findsOneWidget);
        expect(find.text('Database connection failed'), findsOneWidget);

        await tester.tap(find.byType(AppButton));
        await tester.pumpAndSettle();
        expect(retried, isTrue);
      },
    );
  });
}

Widget _dummyContentBuilder(BuildContext context, List<String> items) {
  return const SizedBox.shrink();
}
