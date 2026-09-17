import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/packages/reports/presentation/reports_screen.dart';
import 'package:nexabiz/packages/services/presentation/services_screen.dart';
import 'package:nexabiz/packages/settings/presentation/settings_screen.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  group('Main Screens Widget Tests', () {
    Widget wrapWithApp(Widget child) {
      return NexaBizRootApp(
        home: child,
      );
    }

    testWidgets('renders ServicesScreen correctly with service categories', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWithApp(const ServicesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Services Hub'), findsOneWidget);
      expect(find.text('Available Business Capabilities & Service Launchers'), findsOneWidget);
      expect(find.text('Financial & Accounting'), findsOneWidget);
      expect(find.text('General Ledger'), findsOneWidget);
    });

    testWidgets('renders ReportsScreen correctly with report hub categories', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWithApp(const ReportsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Reports Hub'), findsOneWidget);
      expect(find.text('Financial, Operational, & Analytical Reports'), findsOneWidget);
      expect(find.text('Financial Reports'), findsOneWidget);
    });

    testWidgets('renders SettingsScreen correctly with theme and security settings', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWithApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Settings & Configuration'), findsOneWidget);
      expect(find.text('Application Preferences'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Company & Currency Profile'), findsOneWidget);
    });
  });
}
