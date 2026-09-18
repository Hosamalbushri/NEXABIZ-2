import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:nexabiz_ui/src/gallery/gallery_preview_card.dart';
import 'package:nexabiz_ui/src/gallery/sections/gallery_data_playground.dart';
import 'package:nexabiz_ui/src/gallery/sections/gallery_feedback_playground.dart';
import 'package:nexabiz_ui/src/gallery/sections/gallery_layout_playground.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  for (final owner in ['Progress', 'Card', 'Accordion', 'Carousel']) {
    for (final width in [280.0, 600.0, 1024.0]) {
      for (final scale in [1.0, 1.3, 2.0]) {
        for (final direction in TextDirection.values) {
          testWidgets('$owner preview $width $direction scale $scale', (
            tester,
          ) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = Size(width, 600);
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final controller = GalleryStateController()..setSearchQuery(owner);
            addTearDown(controller.dispose);
            Widget app(Widget child) => shadcn.ShadcnApp(
              home: Builder(
                builder: (context) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: Directionality(
                    textDirection: direction,
                    child: SingleChildScrollView(child: child),
                  ),
                ),
              ),
            );
            final section = switch (owner) {
              'Progress' => GalleryFeedbackPlayground(controller: controller),
              'Carousel' => GalleryDataPlayground(controller: controller),
              _ => GalleryLayoutPlayground(controller: controller),
            };
            // Obtain the actual gallery-owned composition; test it bounded directly
            // so the existing preview host's horizontal scrolling cannot mask bugs.
            await tester.pumpWidget(app(section));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final card = tester.widget<GalleryPreviewCard>(
              find.byType(GalleryPreviewCard).first,
            );
            await tester.pumpWidget(app(card.preview));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(
              find.text(switch (owner) {
                'Progress' => 'Batch Ledger Sync:',
                'Card' => 'General Ledger Card',
                'Accordion' => 'Tax Settings & VAT Rates',
                _ => 'Executive Insight',
              }),
              findsWidgets,
            );
            if (owner == 'Carousel') {
              final carousel = tester.widget<AppCarousel<String>>(
                find.byType(AppCarousel<String>),
              );
              expect(carousel.items, hasLength(3));
              await tester.tap(find.byIcon(shadcn.LucideIcons.chevronRight));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              await tester.drag(
                find.byType(shadcn.Carousel),
                const Offset(-120, 0),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
          });
        }
      }
    }
  }

  testWidgets('gallery controls still change progress and expand tax content', (
    tester,
  ) async {
    final controller = GalleryStateController()..setSearchQuery('Progress');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      shadcn.ShadcnApp(
        home: SingleChildScrollView(
          child: GalleryFeedbackPlayground(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final previous = tester
        .widget<shadcn.Progress>(find.byType(shadcn.Progress))
        .progress;
    await tester.ensureVisible(find.text('Simulate Progress'));
    await tester.tap(find.text('Simulate Progress'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester.widget<shadcn.Progress>(find.byType(shadcn.Progress)).progress,
      isNot(previous),
    );
    controller.setSearchQuery('Accordion');
    await tester.pumpWidget(
      shadcn.ShadcnApp(
        home: SingleChildScrollView(
          child: GalleryLayoutPlayground(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(shadcn.GhostButton));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      find.text(
        'Standard VAT Rate: 15.0% • Tax Registration Number: 300129048100003',
      ),
      findsOneWidget,
    );
  });
}
