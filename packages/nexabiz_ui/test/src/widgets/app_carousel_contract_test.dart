import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:nexabiz_ui/src/widgets/app_carousel.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return shadcn.ShadcnApp(
      home: shadcn.Scaffold(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }

  testWidgets('AppCarousel: internally created controller lifecycle',
      (WidgetTester tester) async {
    bool showCarousel = true;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return buildTestableWidget(
            Column(
              children: [
                if (showCarousel)
                  AppCarousel<String>(
                    items: const ['Slide 1', 'Slide 2'],
                    itemBuilder: (context, item, index) => Text(item),
                  ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showCarousel = false;
                    });
                  },
                  child: const Text('Hide'),
                ),
              ],
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Slide 1'), findsOneWidget);

    await tester.tap(find.text('Hide'));
    await tester.pumpAndSettle();

    expect(find.text('Slide 1'), findsNothing);
  });

  testWidgets('AppCarousel: caller-owned controller survives widget disposal',
      (WidgetTester tester) async {
    final controller = shadcn.CarouselController();
    bool showCarousel = true;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return buildTestableWidget(
            Column(
              children: [
                if (showCarousel)
                  AppCarousel<String>(
                    controller: controller,
                    items: const ['Card A', 'Card B'],
                    itemBuilder: (context, item, index) => Text(item),
                  ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showCarousel = false;
                    });
                  },
                  child: const Text('Remove Carousel'),
                ),
              ],
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Card A'), findsOneWidget);

    await tester.tap(find.text('Remove Carousel'));
    await tester.pumpAndSettle();

    // Verify caller-owned controller remains active and non-disposed
    expect(() => controller.animateNext(const Duration(milliseconds: 100)),
        returnsNormally);

    controller.dispose();
  });
}
