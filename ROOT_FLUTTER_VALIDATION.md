# Root Flutter validation

The actual Git checkout already tracks the root pubspec, analyzer options, root tests, and platform scaffolding. No replacement scaffolding or tests were generated. Git inventory and ignored-file inspection confirmed Android, iOS, Linux, macOS, web, and Windows, consistent with `.metadata`. No root Dart workspace, FVM configuration, or AGENTS.md was found.

## SDK and dependencies

Installed SDK: Flutter 3.44.4 stable, revision ad70ec4617; Dart 3.12.2. The usable SDK is `/home/hosam/Downloads/flutter-sdk/flutter`. Flutter and Dart are absent from PATH; the wrappers in `/home/hosam/Android/Sdk/bin` fail because that directory is not a Flutter Git clone.

Root and UI package retain Dart `^3.12.2` (>=3.12.2 <4.0.0). Root Flutter constraint is now `>=3.44.0`, matching the existing resolved dependency floor in both lockfiles. Installed versions satisfy these requirements. UI package dependencies and constraints were preserved.

All 27 root Dart files were scanned for imports. Exact direct production dependencies: `flutter` (SDK), `go_router: ^14.8.1`, `shadcn_flutter: ^0.0.53`, and `nexabiz_ui` at local path `packages/nexabiz_ui`. Root dev dependencies remain `flutter_test` (SDK) and `flutter_lints: ^6.0.0`. Removed unused root `flutter_localizations`; localization remains transitive through the UI package. Retained existing `cupertino_icons: ^1.0.8` as an asset dependency: an initial web build without it warned about the missing Cupertino font family. Root source imports do not directly import this package. No retained dependency version was upgraded; the UI package lockfile is unchanged.

Analyzer includes Flutter lints plus strict casts, strict inference, and strict raw types. Removed an obsolete exclusion for an absent `untitled2` directory. Fixed resulting diagnostics with explicit generic arguments, a String-valued gallery map with required-key assertions, and braces. Formatting was applied across existing Dart sources and tests; no assertions or test expectations were changed.

Existing dirty source changes in dashboard_screen.dart, settings_screen.dart, app_section.dart, app_list_tile.dart, and app_module_hub_grid.dart were preserved. The pre-existing untracked app_responsive_layout_constraints_test.dart was preserved and formatted. Generated plugin registrants were not manually edited. The package contains tracked build artifacts; changes to them caused by clean/test were restored from HEAD.

## Command results

Root `flutter clean`: exit 0; generated build and tool state removed.
Root `flutter pub get`: exit 0, `Got dependencies!`.
Initial format check: exit 1, 104 files needed formatting; sandbox also prevented writing Dart telemetry. Formatting and subsequent commands used approved SDK access.
Final `dart format --output=none --set-exit-if-changed .`: exit 0, `Formatted 183 files (0 changed)`.
Root `flutter analyze`: exit 0, `No issues found!`.
Root `flutter test --reporter expanded`: exit 1, 46 passed, 3 failed.
UI package `flutter clean`: exit 0.
UI package `flutter pub get`: exit 0, `Got dependencies!`.
UI package `flutter analyze`: exit 0, `No issues found!`.
UI package `flutter test --reporter expanded`: exit 0, `00:18 +49: All tests passed!`.
Initial `flutter build web --no-pub`: exit 0, `✓ Built build/web`, with missing Cupertino font warning. The existing icon dependency was subsequently restored and pub get passed with only localization changing from direct to transitive.
Final `flutter build web --no-pub`: exit 0, `✓ Built build/web` (103.5s), Cupertino font included and missing-font warning resolved. This verifies compilation; no interactive application session or native builds were performed.
Final root `flutter test --no-pub --reporter expanded`: exit 1, `00:16 +46 -3: Some tests failed.`, same three failures. Complete output: `/tmp/nexabiz-root-validation.log`.
Final root analyzer and formatting checks: exit 0.
Targeted gallery diagnostic run: exit 1, 3 passed and 1 failed; output captured in `/tmp/nexabiz-gallery-validation.log`.

## Remaining test blockers

1. `test/integration/app_bootstrap_test.dart:32`: expected 4 routes, actual 5. The capability manifest includes dashboard, services, reports, settings, and gallery. Removing gallery changes application behavior; changing the expectation would violate this task's test integrity constraint.
2. `test/architecture/bottom_sheet_architecture_test.dart`: literal text scan matches `showModalBottomSheet` inside the user-visible description at `packages/nexabiz_ui/lib/src/gallery/sections/gallery_overlays_playground.dart:39`. This is a description rejecting Material sheets, not a Material API call. Changing this description changes UI; weakening the scan changes the guardrail.
3. `test/widgets/component_gallery_test.dart`: seven RenderFlex exceptions. Right overflow: `app_field_shell.dart:135` (37 px), `gallery_feedback_playground.dart:125` (0.250 px), `gallery_layout_playground.dart:55` (215 px), `gallery_layout_playground.dart:107` (277 px). Bottom overflow: `gallery_data_playground.dart:269` (28 px, three occurrences). Paths are under `packages/nexabiz_ui/lib/src/widgets` or `src/gallery/sections`. Fixing these requires UI layout changes outside this metadata-only task.

## Inspected files and inventory

Whole-repository tracked/ignored file inventories, platform scaffolding presence, SDK locations, and both source/test package import inventories were inspected. Metadata and root import files:

- `pubspec.yaml`
- `pubspec.lock`
- `analysis_options.yaml`
- `.metadata`
- `.gitignore`
- `README.md`
- `android/local.properties`
- `packages/nexabiz_ui/pubspec.yaml`
- `packages/nexabiz_ui/pubspec.lock`
- `packages/nexabiz_ui/SHADCN_FLUTTER_INTEGRATION.md`
- `lib/app/app.dart`
- `lib/app/bootstrap/app_bootstrap.dart`
- `lib/app/bootstrap/nexabiz_capability_manifest.dart`
- `lib/app/router/nexabiz_router_adapter.dart`
- `lib/app/shell/application_shell.dart`
- `lib/app/shell/shell_navigation_item.dart`
- `lib/core/capabilities/capability_metadata.dart`
- `lib/core/capabilities/nexabiz_capability.dart`
- `lib/core/capabilities/nexabiz_capability_registry.dart`
- `lib/core/navigation/nexabiz_navigation_contribution.dart`
- `lib/core/navigation/nexabiz_navigation_controller.dart`
- `lib/core/navigation/nexabiz_navigation_registry.dart`
- `lib/core/navigation/nexabiz_route_definition.dart`
- `lib/core/navigation/nexabiz_route_id.dart`
- `lib/main.dart`
- `lib/packages/dashboard/dashboard_capability.dart`
- `lib/packages/dashboard/presentation/dashboard_screen.dart`
- `lib/packages/demo/demo_capability.dart`
- `lib/packages/demo/presentation/demo_page.dart`
- `lib/packages/gallery/gallery_capability.dart`
- `lib/packages/reports/presentation/reports_screen.dart`
- `lib/packages/reports/reports_capability.dart`
- `lib/packages/services/presentation/services_screen.dart`
- `lib/packages/services/services_capability.dart`
- `lib/packages/settings/presentation/settings_screen.dart`
- `lib/packages/settings/settings_capability.dart`
- `lib/presentation/showcase/nexabiz_ui_showcase_page.dart`

## Created/modified files

Created this report. Modified metadata and existing Dart files listed below; most Dart changes are formatter-only. This list includes the five source files already modified before this task. The existing untracked package test was also formatted.

- `analysis_options.yaml`
- `lib/app/app.dart`
- `lib/app/bootstrap/nexabiz_capability_manifest.dart`
- `lib/app/router/nexabiz_router_adapter.dart`
- `lib/app/shell/application_shell.dart`
- `lib/core/capabilities/nexabiz_capability_registry.dart`
- `lib/core/navigation/nexabiz_navigation_controller.dart`
- `lib/core/navigation/nexabiz_navigation_registry.dart`
- `lib/core/navigation/nexabiz_route_id.dart`
- `lib/packages/dashboard/presentation/dashboard_screen.dart`
- `lib/packages/demo/demo_capability.dart`
- `lib/packages/demo/presentation/demo_page.dart`
- `lib/packages/gallery/gallery_capability.dart`
- `lib/packages/settings/presentation/settings_screen.dart`
- `lib/presentation/showcase/nexabiz_ui_showcase_page.dart`
- `packages/nexabiz_ui/lib/nexabiz_ui.dart`
- `packages/nexabiz_ui/lib/src/gallery/component_gallery_page.dart`
- `packages/nexabiz_ui/lib/src/gallery/gallery_preview_card.dart`
- `packages/nexabiz_ui/lib/src/gallery/gallery_state_controller.dart`
- `packages/nexabiz_ui/lib/src/gallery/sections/gallery_actions_playground.dart`
- `packages/nexabiz_ui/lib/src/gallery/sections/gallery_data_playground.dart`
- `packages/nexabiz_ui/lib/src/gallery/sections/gallery_datetime_playground.dart`
- `packages/nexabiz_ui/lib/src/gallery/sections/gallery_feedback_playground.dart`
- `packages/nexabiz_ui/lib/src/gallery/sections/gallery_forms_playground.dart`
- `packages/nexabiz_ui/lib/src/gallery/sections/gallery_layout_playground.dart`
- `packages/nexabiz_ui/lib/src/gallery/sections/gallery_navigation_playground.dart`
- `packages/nexabiz_ui/lib/src/gallery/sections/gallery_overlays_playground.dart`
- `packages/nexabiz_ui/lib/src/layout/app_breakpoints.dart`
- `packages/nexabiz_ui/lib/src/layout/app_constraints.dart`
- `packages/nexabiz_ui/lib/src/layout/app_container.dart`
- `packages/nexabiz_ui/lib/src/layout/app_content.dart`
- `packages/nexabiz_ui/lib/src/layout/app_dashboard_page.dart`
- `packages/nexabiz_ui/lib/src/layout/app_form_page.dart`
- `packages/nexabiz_ui/lib/src/layout/app_list_page.dart`
- `packages/nexabiz_ui/lib/src/layout/app_master_detail_page.dart`
- `packages/nexabiz_ui/lib/src/layout/app_page.dart`
- `packages/nexabiz_ui/lib/src/layout/app_responsive.dart`
- `packages/nexabiz_ui/lib/src/layout/app_section.dart`
- `packages/nexabiz_ui/lib/src/layout/app_settings_page.dart`
- `packages/nexabiz_ui/lib/src/layout/app_table_page.dart`
- `packages/nexabiz_ui/lib/src/theme/app_theme.dart`
- `packages/nexabiz_ui/lib/src/theme/app_theme_controller.dart`
- `packages/nexabiz_ui/lib/src/theme/tokens/app_spacing.dart`
- `packages/nexabiz_ui/lib/src/theme/tokens/app_typography.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_bottom_sheet.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_breadcrumb.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_button.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_card.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_carousel.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_checkbox.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_chip_input.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_choice_card_group.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_confirmation_dialog.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_custom_app_bar.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_custom_bottom_nav.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_data_table.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_dialog.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_draggable_quick_nav.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_drawer_sheet.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_dropdown.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_empty_state.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_error_state.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_exclusive_toggle_group.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_field_shell.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_form.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_form_actions.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_form_sheet.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_hover_preview.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_icon_avatar.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_icon_button.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_list_tile.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_loading.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_module_hub_grid.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_multi_select_field.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_number_field.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_page_header.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_pagination_bar.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_pinned_dock_sheet.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_quick_actions_panel.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_searchable_select.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_select_field.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_slider_field.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_sortable_list.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_split_view.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_status_badge.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_surface.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_tab_workspace.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_tabs.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_text_field.dart`
- `packages/nexabiz_ui/lib/src/widgets/app_tree.dart`
- `packages/nexabiz_ui/lib/src/widgets/nexabiz_aliases.dart`
- `packages/nexabiz_ui/test/architecture_guardrails_test.dart`
- `packages/nexabiz_ui/test/architecture_layout_guardrails_test.dart`
- `packages/nexabiz_ui/test/canonical_layout_system_test.dart`
- `packages/nexabiz_ui/test/design_system_theme_enforcement_test.dart`
- `packages/nexabiz_ui/test/nexabiz_ui_components_test.dart`
- `pubspec.lock`
- `pubspec.yaml`
- `test/app/architecture/navigation_architecture_guardrails_test.dart`
- `test/app/architecture/ui_architecture_guardrails_test.dart`
- `test/app/shell/application_shell_test.dart`
- `test/architecture/bottom_sheet_architecture_test.dart`
- `test/architecture/responsive_ui_foundation_architecture_test.dart`
- `test/core/capabilities/nexabiz_capability_registry_test.dart`
- `test/core/navigation/nexabiz_navigation_registry_test.dart`
- `test/integration/app_bootstrap_test.dart`
- `test/packages/main_screens_test.dart`
- `test/widget_test.dart`
- `test/widgets/app_bottom_sheet_test.dart`
- `test/widgets/app_ui_foundation_test.dart`
- `test/widgets/component_gallery_test.dart`
