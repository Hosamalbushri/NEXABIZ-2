import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz/app/bootstrap/nexabiz_capability_manifest.dart';
import 'package:nexabiz/core/navigation/nexabiz_route_id.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  testWidgets('ComponentGalleryPage renders header and category filters correctly', (tester) async {
    await tester.pumpWidget(
      const shadcn.ShadcnApp(
        home: ComponentGalleryPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shadcn Flutter Component Gallery & Playground'), findsOneWidget);
    expect(find.text('Forms & Inputs'), findsWidgets);
    expect(find.text('Actions & Menus'), findsWidgets);
    expect(find.text('Overlays & Sheets'), findsWidgets);
  });

  testWidgets('GalleryStateController updates search query and category filters', (tester) async {
    final controller = GalleryStateController();

    expect(controller.selectedCategory, equals(GalleryCategory.all));
    controller.setCategory(GalleryCategory.forms);
    expect(controller.selectedCategory, equals(GalleryCategory.forms));

    controller.setSearchQuery('Button');
    expect(controller.searchQuery, equals('button'));
    expect(controller.isComponentMatching('Button', 'Action trigger', GalleryCategory.actions), isFalse);

    controller.setCategory(GalleryCategory.actions);
    expect(controller.isComponentMatching('Button', 'Action trigger', GalleryCategory.actions), isTrue);

    controller.dispose();
  });

  testWidgets('GalleryStateController toggles directionality and viewport size', (tester) async {
    final controller = GalleryStateController();

    expect(controller.directionality, equals(TextDirection.rtl));
    controller.toggleDirectionality();
    expect(controller.directionality, equals(TextDirection.ltr));

    controller.setViewportSize(GalleryViewportSize.compact);
    expect(controller.viewportSize, equals(GalleryViewportSize.compact));

    controller.dispose();
  });

  test('GalleryCapability registers /gallery route in NexaBizCapabilityManifest', () {
    final capabilities = NexaBizCapabilityManifest.capabilities;
    final hasGallery = capabilities.any((c) => c.capabilityId == 'gallery');
    expect(hasGallery, isTrue);

    final galleryCap = capabilities.firstWhere((c) => c.capabilityId == 'gallery');
    expect(galleryCap.navigationContribution?.rootRouteId, equals(const NexaBizRouteId(namespace: 'gallery', routeName: 'root')));
    expect(galleryCap.navigationContribution?.routes.first.path, equals('/gallery'));
  });
}
