import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 10 public API guardrails', () {
    test('production barrel has the exact reviewed export set', () {
      final barrel = _packageFile('lib/nexabiz_ui.dart').readAsStringSync();
      final actual = RegExp(
        r"^export '([^']+)'",
        multiLine: true,
      ).allMatches(barrel).map((match) => match.group(1)!).toSet();

      expect(actual, _productionExports);
    });

    test('development entrypoint is isolated from production exports', () {
      final production = _packageFile('lib/nexabiz_ui.dart').readAsStringSync();
      final development = _packageFile(
        'lib/nexabiz_ui_dev.dart',
      ).readAsStringSync();

      for (final path in _developmentExports) {
        expect(production.contains(path), isFalse, reason: path);
        expect(development.contains("export '$path';"), isTrue, reason: path);
      }
    });

    test('removed compatibility declarations and files stay absent', () {
      const removedFiles = <String>[
        'lib/src/widgets/nexabiz_aliases.dart',
        'lib/src/widgets/app_dropdown.dart',
        'lib/src/widgets/app_draggable_quick_nav.dart',
        'lib/src/constants/app_constants.dart',
        'lib/src/presentation/patterns/app_page_shell.dart',
        'lib/src/presentation/patterns/app_list_page_pattern.dart',
        'lib/src/presentation/patterns/app_form_page_pattern.dart',
        'lib/src/presentation/patterns/app_detail_page_pattern.dart',
        'lib/src/presentation/scaffolds/module_list_scaffold.dart',
        'lib/src/presentation/scaffolds/module_form_scaffold.dart',
      ];
      for (final path in removedFiles) {
        expect(_packageFile(path).existsSync(), isFalse, reason: path);
      }

      final libraryText = _packageLibraryText();
      for (final symbol in <String>[
        'AppPageShell',
        'AppListPagePattern',
        'AppFormPagePattern',
        'AppDetailPagePattern',
        'ModuleListScaffold',
        'ModuleFormScaffold',
        'AppDropdown',
        'AppDropdownItem',
        'AppSelectItem',
        'AppNavItem',
        'AppSidebarItem',
      ]) {
        expect(
          RegExp('(?:class|typedef)\\s+$symbol\\b').hasMatch(libraryText),
          isFalse,
          reason: symbol,
        );
      }
      expect(RegExp(r'typedef\s+NexaBiz\w+').hasMatch(libraryText), isFalse);
    });

    test('every production AppIconButton call has a specific label', () {
      final implementation = _packageFile(
        'lib/src/widgets/app_icon_button.dart',
      ).readAsStringSync();
      expect(implementation.contains('loc.action'), isFalse);
      expect(
        implementation.contains(
          'AppIconButton requires a non-empty tooltip or semanticLabel.',
        ),
        isTrue,
      );

      final files =
          <File>[
            ..._dartFiles(Directory('lib')),
            ..._dartFiles(_packageDirectory('lib/src')),
          ].where((file) {
            final path = file.path.replaceAll('\\', '/');
            return !path.endsWith('/app_icon_button.dart') &&
                !path.contains('/gallery/') &&
                !path.contains('/playground/');
          });

      final unlabeled = <String>[];
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final invocation in _constructorInvocations(
          source,
          'AppIconButton',
        )) {
          if (!invocation.contains('tooltip:') &&
              !invocation.contains('semanticLabel:')) {
            unlabeled.add(file.path);
          }
        }
      }
      expect(unlabeled, isEmpty);
    });

    test('canonical widgets do not use raw shadcn.IconButton directly', () {
      final widgetFiles = _dartFiles(_packageDirectory('lib/src/widgets'))
          .where((f) {
            final path = f.path.replaceAll('\\', '/');
            return !path.endsWith('/app_icon_button.dart');
          });

      final violating = <String>[];
      for (final file in widgetFiles) {
        final source = file.readAsStringSync();
        if (source.contains('shadcn.IconButton')) {
          violating.add(file.path);
        }
      }
      expect(violating, isEmpty);
    });
  });
}

const _developmentExports = <String>{
  'src/gallery/component_gallery_page.dart',
  'src/gallery/gallery_state_controller.dart',
  'src/playground/mobile_ui_playground_page.dart',
};

const _productionExports = <String>{
  'src/theme/app_theme.dart',
  'src/theme/app_theme_controller.dart',
  'src/layout/layout.dart',
  'src/theme/tokens/app_borders.dart',
  'src/theme/tokens/app_colors.dart',
  'src/theme/tokens/app_dimensions.dart',
  'src/theme/tokens/app_elevation.dart',
  'src/theme/tokens/app_icons.dart',
  'src/theme/tokens/app_motion.dart',
  'src/theme/tokens/app_radii.dart',
  'src/theme/tokens/app_spacing.dart',
  'src/theme/tokens/app_typography.dart',
  'src/widgets/app_button.dart',
  'src/widgets/app_text_field.dart',
  'src/widgets/app_async_autocomplete_field.dart',
  'src/widgets/app_data_table.dart',
  'src/widgets/app_dialog.dart',
  'src/widgets/app_form_dialog.dart',
  'src/widgets/app_confirmation_dialog.dart',
  'src/widgets/app_loading.dart',
  'src/widgets/app_card.dart',
  'src/widgets/app_status_badge.dart',
  'src/widgets/app_pagination_bar.dart',
  'src/widgets/app_collection_view.dart',
  'src/widgets/app_view_mode_toggle.dart',
  'src/widgets/app_customer_search_field.dart',
  'src/widgets/app_search_field.dart',
  'src/widgets/app_search_toolbar.dart',
  'src/widgets/app_editable_table_shell.dart',
  'src/widgets/app_document_line_table_shell.dart',
  'src/widgets/app_empty_state.dart',
  'src/widgets/app_error_state.dart',
  'src/widgets/app_checkbox.dart',
  'src/widgets/app_radio.dart',
  'src/widgets/app_chip_input.dart',
  'src/widgets/app_chip_autocomplete.dart',
  'src/widgets/app_multi_select_field.dart',
  'src/widgets/app_number_field.dart',
  'src/widgets/app_phone_field.dart',
  'src/widgets/app_choice_card_group.dart',
  'src/widgets/app_searchable_select.dart',
  'src/widgets/app_slider_field.dart',
  'src/widgets/app_multiline_field.dart',
  'src/widgets/app_exclusive_toggle_group.dart',
  'src/widgets/app_carousel.dart',
  'src/widgets/app_switch.dart',
  'src/widgets/app_amount_field.dart',
  'src/widgets/app_bottom_actions.dart',
  'src/widgets/app_field_shell.dart',
  'src/widgets/app_form_actions.dart',
  'src/widgets/app_page_header.dart',
  'src/widgets/app_module_hub_card.dart',
  'src/widgets/app_module_hub_grid.dart',
  'src/widgets/app_detail_info_row.dart',
  'src/widgets/app_detail_surface_card.dart',
  'src/widgets/app_expandable_text.dart',
  'src/widgets/app_date_field.dart',
  'src/widgets/app_date_range_field.dart',
  'src/widgets/app_select_option.dart',
  'src/widgets/app_selection_foundation.dart',
  'src/widgets/app_select_field.dart',
  'src/widgets/app_snackbar.dart',
  'src/widgets/app_surface.dart',
  'src/widgets/app_icon_button.dart',
  'src/widgets/app_icon_avatar.dart',
  'src/widgets/app_tree.dart',
  'src/widgets/app_form.dart',
  'src/widgets/app_split_view.dart',
  'src/widgets/app_sortable_list.dart',
  'src/widgets/app_stepper.dart',
  'src/widgets/app_breadcrumb.dart',
  'src/widgets/app_content_switcher.dart',
  'src/widgets/app_tabs.dart',
  'src/widgets/app_tab_workspace.dart',
  'src/widgets/app_drawer_sheet.dart',
  'src/widgets/app_hover_preview.dart',
  'src/widgets/app_tooltip.dart',
  'src/widgets/app_pinned_dock_sheet.dart',
  'src/widgets/app_form_sheet.dart',
  'src/widgets/app_swiper_sheet.dart',
  'src/widgets/app_list_tile.dart',
  'src/widgets/app_separator.dart',
  'src/widgets/app_custom_bottom_nav.dart',
  'src/widgets/app_navigation_item.dart',
  'src/widgets/app_custom_app_bar.dart',
  'src/widgets/app_sidebar.dart',
  'src/widgets/app_top_header.dart',
  'src/widgets/app_company_switcher.dart',
  'src/widgets/app_quick_actions_panel.dart',
  'src/widgets/app_bottom_sheet.dart',
  'src/widgets/app_accordion.dart',
  'src/localization/nexa_biz_shadcn_localizations_delegate.dart',
  'src/localization/nexabiz_ui_localizations.dart',
  'src/presentation/scaffolds/app_root.dart',
  'src/presentation/scaffolds/app_responsive_scaffold.dart',
};

Directory _packageDirectory(String relativePath) {
  final local = Directory(relativePath);
  if (File('pubspec.yaml').readAsStringSync().contains('name: nexabiz_ui')) {
    return local;
  }
  return Directory('packages/nexabiz_ui/$relativePath');
}

File _packageFile(String relativePath) =>
    File('${_packageDirectory('.').path}/$relativePath');

Iterable<File> _dartFiles(Directory directory) sync* {
  if (!directory.existsSync()) return;
  yield* directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

String _packageLibraryText() => _dartFiles(
  _packageDirectory('lib'),
).map((file) => file.readAsStringSync()).join('\n');

Iterable<String> _constructorInvocations(String source, String name) sync* {
  final marker = '$name(';
  var start = 0;
  while ((start = source.indexOf(marker, start)) != -1) {
    var depth = 0;
    var end = start + marker.length;
    for (; end < source.length; end++) {
      final character = source[end];
      if (character == '(') depth++;
      if (character == ')') {
        if (depth == 0) break;
        depth--;
      }
    }
    yield source.substring(start, end.clamp(start, source.length));
    start = end + 1;
  }
}
