import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return shadcn.ShadcnApp(
      home: shadcn.Scaffold(
        child: child,
      ),
    );
  }

  group('Page Architecture Contract Tests', () {
    test('Rule A: Canonical Page APIs are publicly exported in nexabiz_ui', () {
      // Verify all 8 canonical page classes can be referenced via public barrel
      expect(AppPage, isNotNull);
      expect(AppListPage, isNotNull);
      expect(AppFormPage, isNotNull);
      expect(AppDetailsPage, isNotNull);
      expect(AppTablePage, isNotNull);
      expect(AppDashboardPage, isNotNull);
      expect(AppSettingsPage, isNotNull);
      expect(AppMasterDetailPage, isNotNull);
    });

    testWidgets('Rule D: Legacy AppPageShell delegates to canonical AppPage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppPageShell(
            child: Text('Shell Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppPage), findsOneWidget);
      expect(find.text('Shell Content'), findsOneWidget);
    });

    testWidgets('Rule D: Legacy AppListPagePattern delegates to canonical AppListPage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppListPagePattern<String>(
            title: 'List Title',
            items: const ['Item A', 'Item B'],
            contentBuilder: (context, items) => Column(
              children: items.map((e) => Text(e)).toList(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppListPage<String>), findsOneWidget);
      expect(find.text('List Title'), findsOneWidget);
      expect(find.text('Item A'), findsOneWidget);
    });

    testWidgets('Rule D: Legacy AppFormPagePattern delegates to canonical AppFormPage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppFormPagePattern(
            title: 'Form Title',
            body: const Text('Form Fields'),
            onSubmit: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppFormPage), findsOneWidget);
      expect(find.text('Form Title'), findsOneWidget);
      expect(find.text('Form Fields'), findsOneWidget);
    });

    testWidgets('Rule D: Legacy AppDetailPagePattern delegates to canonical AppDetailsPage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppDetailPagePattern(
            title: 'Detail Title',
            body: Text('Detail Body'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppDetailsPage), findsOneWidget);
      expect(find.text('Detail Title'), findsOneWidget);
      expect(find.text('Detail Body'), findsOneWidget);
    });

    testWidgets('Rule D: Legacy ModuleListScaffold delegates to AppListPagePattern & AppListPage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ModuleListScaffold<String>(
            title: 'Scaffold List',
            items: const ['Row 1'],
            itemBuilder: (context, item) => Text(item),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppListPage<String>), findsOneWidget);
      expect(find.text('Scaffold List'), findsOneWidget);
      expect(find.text('Row 1'), findsOneWidget);
    });

    testWidgets('Rule D: Legacy ModuleFormScaffold delegates to AppFormPagePattern & AppFormPage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ModuleFormScaffold(
            title: 'Scaffold Form',
            body: const Text('Scaffold Fields'),
            onSave: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppFormPage), findsOneWidget);
      expect(find.text('Scaffold Form'), findsOneWidget);
      expect(find.text('Scaffold Fields'), findsOneWidget);
    });
  });
}
