import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  Widget wrapWithTheme(Widget child) {
    return shadcn.ShadcnApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: shadcn.Scaffold(child: Center(child: child)),
      ),
    );
  }

  group('AppAccordionCard Contract Tests', () {
    testWidgets('renders closed initially and expands on header tap', (
      tester,
    ) async {
      bool? lastExpanded;

      await tester.pumpWidget(
        wrapWithTheme(
          AppAccordionCard(
            title: const Text('Accordion Header'),
            subtitle: const Text('Accordion Subtitle'),
            onExpansionChanged: (val) => lastExpanded = val,
            child: const Text('Secret Content Revealed'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Accordion Header'), findsOneWidget);
      expect(find.text('Accordion Subtitle'), findsOneWidget);

      // Tap header to expand
      await tester.tap(find.text('Accordion Header'));
      await tester.pumpAndSettle();

      expect(lastExpanded, isTrue);
      expect(find.text('Secret Content Revealed'), findsOneWidget);

      // Tap again to collapse
      await tester.tap(find.text('Accordion Header'));
      await tester.pumpAndSettle();

      expect(lastExpanded, isFalse);
    });

    testWidgets('renders open initially when initiallyExpanded is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const AppAccordionCard(
            initiallyExpanded: true,
            title: Text('Initially Open'),
            child: Text('Already Visible Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Initially Open'), findsOneWidget);
      expect(find.text('Already Visible Content'), findsOneWidget);
    });
  });
}

