# NexaBiz UI public API

This document is the Phase 10 audited contract for package version 0.1.0. The production surface moved from 222 top-level symbols across 106 direct exports to 169 symbols across 94 direct exports. Fifty-four symbols left the production surface, one canonical navigation model was added, and seven of the removed symbols remain available from the development entrypoint. Production code imports only:

```dart
import 'package:nexabiz_ui/nexabiz_ui.dart';
```

Gallery and playground code imports the separate development entrypoint:

```dart
import 'package:nexabiz_ui/nexabiz_ui_dev.dart';
```

Application and feature code must not import `package:nexabiz_ui/src/...`, `shadcn_flutter`, or development-only symbols. The package exposes 169 production symbols: 149 classes, 14 enums, one extension, three functions, and two justified typedefs. The development entrypoint exposes seven symbols. Consumer counts below are production Dart-file references outside the defining file and public entrypoints; gallery/playground implementation references are included.

## Public API matrix

| Symbol                               | Defining file                                                      | Category                     |     Consumers | Replacement | Action |
| ------------------------------------ | ------------------------------------------------------------------ | ---------------------------- | ------------: | ----------- | ------ |
| `AppAccordionCard`                   | `lib/src/widgets/app_accordion.dart`                               | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppAmountField`                     | `lib/src/widgets/app_amount_field.dart`                            | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppAsyncAutocompleteField`          | `lib/src/widgets/app_async_autocomplete_field.dart`                | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppBorders`                         | `lib/src/theme/tokens/app_borders.dart`                            | CANONICAL_ADVANCED (class)   |  5 Dart files | —           | KEEP   |
| `AppBottomActions`                   | `lib/src/widgets/app_bottom_actions.dart`                          | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppBottomSheet`                     | `lib/src/widgets/app_bottom_sheet.dart`                            | CANONICAL_PUBLIC (class)     |  5 Dart files | —           | KEEP   |
| `AppBottomSheetSelectionItem`        | `lib/src/widgets/app_bottom_sheet.dart`                            | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppBreadcrumb`                      | `lib/src/widgets/app_breadcrumb.dart`                              | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppBreadcrumbItem`                  | `lib/src/widgets/app_breadcrumb.dart`                              | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppBreakpointTier`                  | `lib/src/layout/app_breakpoints.dart`                              | CANONICAL_ADVANCED (enum)    |  7 Dart files | —           | KEEP   |
| `AppBreakpoints`                     | `lib/src/layout/app_breakpoints.dart`                              | CANONICAL_ADVANCED (class)   | 11 Dart files | —           | KEEP   |
| `AppButton`                          | `lib/src/widgets/app_button.dart`                                  | CANONICAL_PUBLIC (class)     | 24 Dart files | —           | KEEP   |
| `AppButtonVariant`                   | `lib/src/widgets/app_button.dart`                                  | CANONICAL_PUBLIC (enum)      | 21 Dart files | —           | KEEP   |
| `AppCard`                            | `lib/src/widgets/app_card.dart`                                    | CANONICAL_PUBLIC (class)     | 24 Dart files | —           | KEEP   |
| `AppCarousel`                        | `lib/src/widgets/app_carousel.dart`                                | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppCheckbox`                        | `lib/src/widgets/app_checkbox.dart`                                | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppChipAutocomplete`                | `lib/src/widgets/app_chip_autocomplete.dart`                       | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppChipInput`                       | `lib/src/widgets/app_chip_input.dart`                              | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppChoiceCardGroup`                 | `lib/src/widgets/app_choice_card_group.dart`                       | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppChoiceOption`                    | `lib/src/widgets/app_choice_card_group.dart`                       | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppCollectionView`                  | `lib/src/widgets/app_collection_view.dart`                         | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppCollectionViewMode`              | `lib/src/widgets/app_collection_view.dart`                         | CANONICAL_PUBLIC (enum)      |  0 Dart files | —           | KEEP   |
| `AppColors`                          | `lib/src/theme/tokens/app_colors.dart`                             | CANONICAL_ADVANCED (class)   | 25 Dart files | —           | KEEP   |
| `AppCompanySwitcher`                 | `lib/src/widgets/app_company_switcher.dart`                        | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppConfirmationDialog`              | `lib/src/widgets/app_confirmation_dialog.dart`                     | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppContainer`                       | `lib/src/layout/app_container.dart`                                | CANONICAL_ADVANCED (class)   |  2 Dart files | —           | KEEP   |
| `AppContainerWidths`                 | `lib/src/layout/app_container.dart`                                | CANONICAL_ADVANCED (class)   |  0 Dart files | —           | KEEP   |
| `AppContent`                         | `lib/src/layout/app_content.dart`                                  | CANONICAL_ADVANCED (class)   |  0 Dart files | —           | KEEP   |
| `AppContentConstraint`               | `lib/src/layout/app_constraints.dart`                              | CANONICAL_ADVANCED (class)   |  1 Dart files | —           | KEEP   |
| `AppContentSwitcher`                 | `lib/src/widgets/app_content_switcher.dart`                        | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppCustomAppBar`                    | `lib/src/widgets/app_custom_app_bar.dart`                          | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppCustomAppBarStyle`               | `lib/src/widgets/app_custom_app_bar.dart`                          | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppCustomBottomNav`                 | `lib/src/widgets/app_custom_bottom_nav.dart`                       | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppCustomerSearchField`             | `lib/src/widgets/app_customer_search_field.dart`                   | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppDashboardConstraint`             | `lib/src/layout/app_constraints.dart`                              | CANONICAL_ADVANCED (class)   |  0 Dart files | —           | KEEP   |
| `AppDashboardPage`                   | `lib/src/layout/app_dashboard_page.dart`                           | CANONICAL_ADVANCED (class)   |  4 Dart files | —           | KEEP   |
| `AppDataTable`                       | `lib/src/widgets/app_data_table.dart`                              | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppDateField`                       | `lib/src/widgets/app_date_field.dart`                              | CANONICAL_PUBLIC (class)     |  3 Dart files | —           | KEEP   |
| `AppDateRangeField`                  | `lib/src/widgets/app_date_range_field.dart`                        | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppDetailInfoRow`                   | `lib/src/widgets/app_detail_info_row.dart`                         | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppDetailSurfaceCard`               | `lib/src/widgets/app_detail_surface_card.dart`                     | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppDetailsConstraint`               | `lib/src/layout/app_constraints.dart`                              | CANONICAL_ADVANCED (class)   |  0 Dart files | —           | KEEP   |
| `AppDetailsPage`                     | `lib/src/layout/app_details_page.dart`                             | CANONICAL_ADVANCED (class)   |  0 Dart files | —           | KEEP   |
| `AppDialog`                          | `lib/src/widgets/app_dialog.dart`                                  | CANONICAL_PUBLIC (class)     |  9 Dart files | —           | KEEP   |
| `AppDialogController`                | `lib/src/widgets/app_dialog.dart`                                  | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppDialogSize`                      | `lib/src/widgets/app_dialog.dart`                                  | CANONICAL_PUBLIC (enum)      |  6 Dart files | —           | KEEP   |
| `AppDialogTone`                      | `lib/src/widgets/app_dialog.dart`                                  | CANONICAL_PUBLIC (enum)      |  4 Dart files | —           | KEEP   |
| `AppDimensions`                      | `lib/src/theme/tokens/app_dimensions.dart`                         | CANONICAL_ADVANCED (class)   |  6 Dart files | —           | KEEP   |
| `AppDivider`                         | `lib/src/widgets/app_separator.dart`                               | CANONICAL_PUBLIC (class)     | 13 Dart files | —           | KEEP   |
| `AppDocumentLineTableShell`          | `lib/src/widgets/app_document_line_table_shell.dart`               | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppDrawerSheet`                     | `lib/src/widgets/app_drawer_sheet.dart`                            | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppEditableTableColumn`             | `lib/src/widgets/app_editable_table_shell.dart`                    | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppEditableTableShell`              | `lib/src/widgets/app_editable_table_shell.dart`                    | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppElevation`                       | `lib/src/theme/tokens/app_elevation.dart`                          | CANONICAL_ADVANCED (class)   |  1 Dart files | —           | KEEP   |
| `AppEmptyState`                      | `lib/src/widgets/app_empty_state.dart`                             | CANONICAL_PUBLIC (class)     |  8 Dart files | —           | KEEP   |
| `AppErrorState`                      | `lib/src/widgets/app_error_state.dart`                             | CANONICAL_PUBLIC (class)     | 10 Dart files | —           | KEEP   |
| `AppExclusiveToggleGroup`            | `lib/src/widgets/app_exclusive_toggle_group.dart`                  | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppExpandableText`                  | `lib/src/widgets/app_expandable_text.dart`                         | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppFieldDensity`                    | `lib/src/widgets/app_field_shell.dart`                             | CANONICAL_PUBLIC (enum)      | 12 Dart files | —           | KEEP   |
| `AppFieldDensityX`                   | `lib/src/widgets/app_field_shell.dart`                             | CANONICAL_PUBLIC (extension) |  0 Dart files | —           | KEEP   |
| `AppFieldShell`                      | `lib/src/widgets/app_field_shell.dart`                             | CANONICAL_PUBLIC (class)     | 14 Dart files | —           | KEEP   |
| `AppForm`                            | `lib/src/widgets/app_form.dart`                                    | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppFormActions`                     | `lib/src/widgets/app_form_actions.dart`                            | CANONICAL_PUBLIC (class)     |  3 Dart files | —           | KEEP   |
| `AppFormConfiguration`               | `lib/src/widgets/app_form.dart`                                    | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppFormConstraint`                  | `lib/src/layout/app_constraints.dart`                              | CANONICAL_ADVANCED (class)   |  0 Dart files | —           | KEEP   |
| `AppFormDialog`                      | `lib/src/widgets/app_form_dialog.dart`                             | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppFormPage`                        | `lib/src/layout/app_form_page.dart`                                | CANONICAL_ADVANCED (class)   |  1 Dart files | —           | KEEP   |
| `AppFormRow`                         | `lib/src/widgets/app_form.dart`                                    | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppFormSection`                     | `lib/src/widgets/app_form.dart`                                    | CANONICAL_PUBLIC (class)     |  3 Dart files | —           | KEEP   |
| `AppFormSheet`                       | `lib/src/widgets/app_form_sheet.dart`                              | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppGrid`                            | `lib/src/layout/app_grid.dart`                                     | CANONICAL_ADVANCED (class)   |  1 Dart files | —           | KEEP   |
| `AppHoverPreview`                    | `lib/src/widgets/app_hover_preview.dart`                           | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppHoverPreviewField`               | `lib/src/widgets/app_hover_preview.dart`                           | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppIconAvatar`                      | `lib/src/widgets/app_icon_avatar.dart`                             | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppIconAvatarSize`                  | `lib/src/widgets/app_icon_avatar.dart`                             | CANONICAL_PUBLIC (enum)      |  2 Dart files | —           | KEEP   |
| `AppIconAvatarTone`                  | `lib/src/widgets/app_icon_avatar.dart`                             | CANONICAL_PUBLIC (enum)      |  2 Dart files | —           | KEEP   |
| `AppIconButton`                      | `lib/src/widgets/app_icon_button.dart`                             | CANONICAL_PUBLIC (class)     |  7 Dart files | —           | KEEP   |
| `AppIconButtonVariant`               | `lib/src/widgets/app_icon_button.dart`                             | CANONICAL_PUBLIC (enum)      |  5 Dart files | —           | KEEP   |
| `AppIcons`                           | `lib/src/theme/tokens/app_icons.dart`                              | CANONICAL_ADVANCED (class)   | 30 Dart files | —           | KEEP   |
| `AppLayoutTokens`                    | `lib/src/layout/app_layout_tokens.dart`                            | CANONICAL_ADVANCED (class)   | 18 Dart files | —           | KEEP   |
| `AppListPage`                        | `lib/src/layout/app_list_page.dart`                                | CANONICAL_ADVANCED (class)   |  1 Dart files | —           | KEEP   |
| `AppListTile`                        | `lib/src/widgets/app_list_tile.dart`                               | CANONICAL_PUBLIC (class)     | 15 Dart files | —           | KEEP   |
| `AppLoading`                         | `lib/src/widgets/app_loading.dart`                                 | CANONICAL_PUBLIC (class)     | 12 Dart files | —           | KEEP   |
| `AppLoadingStyle`                    | `lib/src/widgets/app_loading.dart`                                 | CANONICAL_PUBLIC (enum)      |  4 Dart files | —           | KEEP   |
| `AppMasterDetailPage`                | `lib/src/layout/app_master_detail_page.dart`                       | CANONICAL_ADVANCED (class)   |  1 Dart files | —           | KEEP   |
| `AppModuleHubCard`                   | `lib/src/widgets/app_module_hub_card.dart`                         | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppModuleHubGrid`                   | `lib/src/widgets/app_module_hub_grid.dart`                         | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppModuleHubHeader`                 | `lib/src/widgets/app_module_hub_grid.dart`                         | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppModuleHubItem`                   | `lib/src/widgets/app_module_hub_grid.dart`                         | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppModuleHubTile`                   | `lib/src/widgets/app_module_hub_grid.dart`                         | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppModuleHubView`                   | `lib/src/widgets/app_module_hub_grid.dart`                         | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppMotion`                          | `lib/src/theme/tokens/app_motion.dart`                             | CANONICAL_ADVANCED (class)   |  1 Dart files | —           | KEEP   |
| `AppMultiSelectField`                | `lib/src/widgets/app_multi_select_field.dart`                      | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppMultilineField`                  | `lib/src/widgets/app_multiline_field.dart`                         | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppNavigationItem`                  | `lib/src/widgets/app_navigation_item.dart`                         | CANONICAL_PUBLIC (class)     |  3 Dart files | —           | KEEP   |
| `AppNumberField`                     | `lib/src/widgets/app_number_field.dart`                            | CANONICAL_PUBLIC (class)     |  3 Dart files | —           | KEEP   |
| `AppPage`                            | `lib/src/layout/app_page.dart`                                     | CANONICAL_ADVANCED (class)   | 19 Dart files | —           | KEEP   |
| `AppPageHeader`                      | `lib/src/widgets/app_page_header.dart`                             | CANONICAL_PUBLIC (class)     | 16 Dart files | —           | KEEP   |
| `AppPaginationBar`                   | `lib/src/widgets/app_pagination_bar.dart`                          | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppPhoneField`                      | `lib/src/widgets/app_phone_field.dart`                             | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppPinnedDockSheet`                 | `lib/src/widgets/app_pinned_dock_sheet.dart`                       | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppQuickActionItem`                 | `lib/src/widgets/app_quick_actions_panel.dart`                     | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppQuickActionsPanel`               | `lib/src/widgets/app_quick_actions_panel.dart`                     | CANONICAL_PUBLIC (class)     |  3 Dart files | —           | KEEP   |
| `AppRadii`                           | `lib/src/theme/tokens/app_radii.dart`                              | CANONICAL_ADVANCED (class)   | 25 Dart files | —           | KEEP   |
| `AppRadio`                           | `lib/src/widgets/app_radio.dart`                                   | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppRadioGroup`                      | `lib/src/widgets/app_radio.dart`                                   | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppRadius`                          | `lib/src/theme/tokens/app_radii.dart`                              | CANONICAL_ADVANCED (class)   |  9 Dart files | —           | KEEP   |
| `AppResponsive`                      | `lib/src/layout/app_responsive.dart`                               | CANONICAL_ADVANCED (class)   |  4 Dart files | —           | KEEP   |
| `AppResponsiveInfo`                  | `lib/src/layout/app_responsive.dart`                               | CANONICAL_ADVANCED (class)   |  0 Dart files | —           | KEEP   |
| `AppResponsiveLayout`                | `lib/src/layout/app_responsive.dart`                               | CANONICAL_ADVANCED (class)   |  0 Dart files | —           | KEEP   |
| `AppResponsiveScaffold`              | `lib/src/presentation/scaffolds/app_responsive_scaffold.dart`      | CANONICAL_ADVANCED (class)   |  2 Dart files | —           | KEEP   |
| `AppResponsiveScope`                 | `lib/src/layout/app_responsive.dart`                               | CANONICAL_ADVANCED (class)   |  6 Dart files | —           | KEEP   |
| `AppResponsiveWidgetBuilder`         | `lib/src/layout/app_responsive.dart`                               | CANONICAL_ADVANCED (typedef) |  0 Dart files | —           | KEEP   |
| `AppSearchField`                     | `lib/src/widgets/app_search_field.dart`                            | CANONICAL_PUBLIC (class)     |  3 Dart files | —           | KEEP   |
| `AppSearchToolbar`                   | `lib/src/widgets/app_search_toolbar.dart`                          | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppSearchableSelect`                | `lib/src/widgets/app_searchable_select.dart`                       | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppSection`                         | `lib/src/layout/app_section.dart`                                  | CANONICAL_ADVANCED (class)   | 13 Dart files | —           | KEEP   |
| `AppSelectField`                     | `lib/src/widgets/app_select_field.dart`                            | CANONICAL_PUBLIC (class)     |  7 Dart files | —           | KEEP   |
| `AppSelectOption`                    | `lib/src/widgets/app_select_option.dart`                           | CANONICAL_PUBLIC (class)     | 12 Dart files | —           | KEEP   |
| `AppSelectOptionTile`                | `lib/src/widgets/app_selection_foundation.dart`                    | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppSelectOverlayContainer`          | `lib/src/widgets/app_selection_foundation.dart`                    | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppSelectionSearchMatcher`          | `lib/src/widgets/app_selection_foundation.dart`                    | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppSeparator`                       | `lib/src/widgets/app_separator.dart`                               | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppSettingsConstraint`              | `lib/src/layout/app_constraints.dart`                              | CANONICAL_ADVANCED (class)   |  0 Dart files | —           | KEEP   |
| `AppSettingsPage`                    | `lib/src/layout/app_settings_page.dart`                            | CANONICAL_ADVANCED (class)   |  1 Dart files | —           | KEEP   |
| `AppShadows`                         | `lib/src/theme/tokens/app_elevation.dart`                          | CANONICAL_ADVANCED (class)   |  1 Dart files | —           | KEEP   |
| `AppSidebar`                         | `lib/src/widgets/app_sidebar.dart`                                 | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppSidebarGroup`                    | `lib/src/widgets/app_sidebar.dart`                                 | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppSliderField`                     | `lib/src/widgets/app_slider_field.dart`                            | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppSortableList`                    | `lib/src/widgets/app_sortable_list.dart`                           | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppSpacing`                         | `lib/src/theme/tokens/app_spacing.dart`                            | CANONICAL_ADVANCED (class)   | 79 Dart files | —           | KEEP   |
| `AppSplitView`                       | `lib/src/widgets/app_split_view.dart`                              | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppStatusBadge`                     | `lib/src/widgets/app_status_badge.dart`                            | CANONICAL_PUBLIC (class)     | 20 Dart files | —           | KEEP   |
| `AppStatusTone`                      | `lib/src/widgets/app_status_badge.dart`                            | CANONICAL_PUBLIC (enum)      | 20 Dart files | —           | KEEP   |
| `AppStepItem`                        | `lib/src/widgets/app_stepper.dart`                                 | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppStepper`                         | `lib/src/widgets/app_stepper.dart`                                 | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppSurface`                         | `lib/src/widgets/app_surface.dart`                                 | CANONICAL_PUBLIC (class)     | 11 Dart files | —           | KEEP   |
| `AppSurfaceVariant`                  | `lib/src/widgets/app_surface.dart`                                 | CANONICAL_PUBLIC (enum)      |  0 Dart files | —           | KEEP   |
| `AppSwiperSheet`                     | `lib/src/widgets/app_swiper_sheet.dart`                            | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppSwiperStyle`                     | `lib/src/widgets/app_swiper_sheet.dart`                            | CANONICAL_PUBLIC (enum)      |  0 Dart files | —           | KEEP   |
| `AppSwitch`                          | `lib/src/widgets/app_switch.dart`                                  | CANONICAL_PUBLIC (class)     |  7 Dart files | —           | KEEP   |
| `AppTabItem`                         | `lib/src/widgets/app_tabs.dart`                                    | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppTabStyle`                        | `lib/src/widgets/app_tabs.dart`                                    | CANONICAL_PUBLIC (enum)      |  1 Dart files | —           | KEEP   |
| `AppTabWorkspace`                    | `lib/src/widgets/app_tab_workspace.dart`                           | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppTableColumn`                     | `lib/src/widgets/app_data_table.dart`                              | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppTableConstraint`                 | `lib/src/layout/app_constraints.dart`                              | CANONICAL_ADVANCED (class)   |  0 Dart files | —           | KEEP   |
| `AppTableDashedBorderPainter`        | `lib/src/widgets/app_editable_table_shell.dart`                    | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppTablePage`                       | `lib/src/layout/app_table_page.dart`                               | CANONICAL_ADVANCED (class)   |  0 Dart files | —           | KEEP   |
| `AppTabs`                            | `lib/src/widgets/app_tabs.dart`                                    | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppTextField`                       | `lib/src/widgets/app_text_field.dart`                              | CANONICAL_PUBLIC (class)     | 17 Dart files | —           | KEEP   |
| `AppTheme`                           | `lib/src/theme/app_theme.dart`                                     | CANONICAL_ADVANCED (class)   |  5 Dart files | —           | KEEP   |
| `AppThemeController`                 | `lib/src/theme/app_theme_controller.dart`                          | CANONICAL_ADVANCED (class)   |  6 Dart files | —           | KEEP   |
| `AppTooltip`                         | `lib/src/widgets/app_tooltip.dart`                                 | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppTopHeader`                       | `lib/src/widgets/app_top_header.dart`                              | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `AppTree`                            | `lib/src/widgets/app_tree.dart`                                    | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppTreeNodeRow`                     | `lib/src/widgets/app_tree.dart`                                    | CANONICAL_PUBLIC (class)     |  1 Dart files | —           | KEEP   |
| `AppTypography`                      | `lib/src/theme/tokens/app_typography.dart`                         | CANONICAL_ADVANCED (class)   | 34 Dart files | —           | KEEP   |
| `AppViewModeOption`                  | `lib/src/widgets/app_view_mode_toggle.dart`                        | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `AppViewModeToggle`                  | `lib/src/widgets/app_view_mode_toggle.dart`                        | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `DashedBorderPainter`                | `lib/src/widgets/app_document_line_table_shell.dart`               | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `NexaBizRootApp`                     | `lib/src/presentation/scaffolds/app_root.dart`                     | CANONICAL_ADVANCED (class)   |  1 Dart files | —           | KEEP   |
| `NexaBizShadcnLocalizationsDelegate` | `lib/src/localization/nexa_biz_shadcn_localizations_delegate.dart` | CANONICAL_ADVANCED (class)   |  2 Dart files | —           | KEEP   |
| `NexaBizUiLocalizations`             | `lib/src/localization/nexabiz_ui_localizations.dart`               | CANONICAL_ADVANCED (class)   | 23 Dart files | —           | KEEP   |
| `NexaBizUiLocalizationsDelegate`     | `lib/src/localization/nexabiz_ui_localizations.dart`               | CANONICAL_ADVANCED (class)   |  0 Dart files | —           | KEEP   |
| `QuickActionsFab`                    | `lib/src/widgets/app_custom_bottom_nav.dart`                       | CANONICAL_PUBLIC (class)     |  0 Dart files | —           | KEEP   |
| `ShowAppSnackBarFn`                  | `lib/src/widgets/app_snackbar.dart`                                | CANONICAL_PUBLIC (typedef)   |  0 Dart files | —           | KEEP   |
| `ToggleOption`                       | `lib/src/widgets/app_exclusive_toggle_group.dart`                  | CANONICAL_PUBLIC (class)     |  2 Dart files | —           | KEEP   |
| `registerAppSnackBarHandler`         | `lib/src/widgets/app_snackbar.dart`                                | CANONICAL_PUBLIC (function)  |  0 Dart files | —           | KEEP   |
| `showAppSnackBar`                    | `lib/src/widgets/app_snackbar.dart`                                | CANONICAL_PUBLIC (function)  |  0 Dart files | —           | KEEP   |
| `wrapSelectWithErrorTheme`           | `lib/src/widgets/app_multi_select_field.dart`                      | CANONICAL_PUBLIC (function)  |  3 Dart files | —           | KEEP   |

## Development-only API

| Symbol                        | File                                                | Category         | Consumers                | Replacement | Action                 |
| ----------------------------- | --------------------------------------------------- | ---------------- | ------------------------ | ----------- | ---------------------- |
| `ComponentGalleryPage`        | `lib/src/gallery/component_gallery_page.dart`       | DEVELOPMENT_ONLY | gallery capability/tests | —           | MOVE to dev entrypoint |
| `GalleryStateController`      | `lib/src/gallery/gallery_state_controller.dart`     | DEVELOPMENT_ONLY | gallery/tests            | —           | MOVE to dev entrypoint |
| `GalleryCategory`             | `lib/src/gallery/gallery_state_controller.dart`     | DEVELOPMENT_ONLY | gallery                  | —           | MOVE to dev entrypoint |
| `GalleryViewportSize`         | `lib/src/gallery/gallery_state_controller.dart`     | DEVELOPMENT_ONLY | gallery                  | —           | MOVE to dev entrypoint |
| `MobileUiPlaygroundPage`      | `lib/src/playground/mobile_ui_playground_page.dart` | DEVELOPMENT_ONLY | gallery capability/tests | —           | MOVE to dev entrypoint |
| `PlaygroundScenario`          | `lib/src/playground/mobile_ui_playground_page.dart` | DEVELOPMENT_ONLY | playground/tests         | —           | MOVE to dev entrypoint |
| `PlaygroundScenarioExtension` | `lib/src/playground/mobile_ui_playground_page.dart` | DEVELOPMENT_ONLY | playground/tests         | —           | MOVE to dev entrypoint |

## Removed compatibility API

The six page wrappers had zero production consumers and were removed: `AppPageShell`, `AppListPagePattern`, `AppFormPagePattern`, `AppDetailPagePattern`, `ModuleListScaffold`, and `ModuleFormScaffold`. Their replacements are respectively `AppPage`, `AppListPage`, `AppFormPage`, `AppDetailsPage`, `AppListPage`, and `AppFormPage`.

The selection compatibility surface `AppDropdown`, `AppDropdownItem`, and `AppSelectItem` was migrated to `AppSelectField` and `AppSelectOption`. `AppNavItem` and `AppSidebarItem` were consolidated into `AppNavigationItem`. `AppDraggableQuickNav` was unconsumed and removed.

All 34 alias typedefs from `nexabiz_aliases.dart` and its `showNexaBizDialog` forwarding function were removed. The 36 removed typedefs comprise those 34 aliases plus `AppDropdownItem` and `AppSelectItem`. The only retained typedefs are `AppResponsiveWidgetBuilder` and `ShowAppSnackBarFn`, both true callback contracts rather than compatibility names.

| Removed symbol              | Former category   | Canonical replacement              | Action |
| --------------------------- | ----------------- | ---------------------------------- | ------ |
| `AppPageShell`              | LEGACY_REDUNDANT  | `AppPage`                          | REMOVE |
| `AppListPagePattern`        | LEGACY_REDUNDANT  | `AppListPage`                      | REMOVE |
| `AppFormPagePattern`        | LEGACY_REDUNDANT  | `AppFormPage`                      | REMOVE |
| `AppDetailPagePattern`      | LEGACY_REDUNDANT  | `AppDetailsPage`                   | REMOVE |
| `ModuleListScaffold`        | LEGACY_REDUNDANT  | `AppListPage`                      | REMOVE |
| `ModuleFormScaffold`        | LEGACY_REDUNDANT  | `AppFormPage`                      | REMOVE |
| `AppDropdown`               | DEPRECATED_PUBLIC | `AppSelectField`                   | REMOVE |
| `AppDropdownItem`           | COMPAT_ALIAS      | `AppSelectOption`                  | REMOVE |
| `AppSelectItem`             | COMPAT_ALIAS      | `AppSelectOption`                  | REMOVE |
| `AppNavItem`                | LEGACY_REDUNDANT  | `AppNavigationItem`                | REMOVE |
| `AppSidebarItem`            | LEGACY_REDUNDANT  | `AppNavigationItem`                | REMOVE |
| `AppDraggableQuickNav`      | LEGACY_REDUNDANT  | canonical shell navigation         | REMOVE |
| `NexaBizDialog`             | COMPAT_ALIAS      | `AppDialog`                        | REMOVE |
| `NexaBizDialogSize`         | COMPAT_ALIAS      | `AppDialogSize`                    | REMOVE |
| `NexaBizConfirmationDialog` | COMPAT_ALIAS      | `AppConfirmationDialog`            | REMOVE |
| `NexaBizFormDialog`         | COMPAT_ALIAS      | `AppFormDialog`                    | REMOVE |
| `NexaBizForm`               | COMPAT_ALIAS      | `AppForm`                          | REMOVE |
| `NexaBizFormSection`        | COMPAT_ALIAS      | `AppFormSection`                   | REMOVE |
| `NexaBizFormActions`        | COMPAT_ALIAS      | `AppFormActions`                   | REMOVE |
| `NexaBizButton`             | COMPAT_ALIAS      | `AppButton`                        | REMOVE |
| `NexaBizButtonVariant`      | COMPAT_ALIAS      | `AppButtonVariant`                 | REMOVE |
| `NexaBizIconButton`         | COMPAT_ALIAS      | `AppIconButton`                    | REMOVE |
| `NexaBizIconButtonVariant`  | COMPAT_ALIAS      | `AppIconButtonVariant`             | REMOVE |
| `NexaBizSurface`            | COMPAT_ALIAS      | `AppSurface`                       | REMOVE |
| `NexaBizSurfaceVariant`     | COMPAT_ALIAS      | `AppSurfaceVariant`                | REMOVE |
| `NexaBizTextField`          | COMPAT_ALIAS      | `AppTextField`                     | REMOVE |
| `NexaBizSelectField`        | COMPAT_ALIAS      | `AppSelectField`                   | REMOVE |
| `NexaBizSelectItem`         | COMPAT_ALIAS      | `AppSelectOption`                  | REMOVE |
| `NexaBizCheckbox`           | COMPAT_ALIAS      | `AppCheckbox`                      | REMOVE |
| `NexaBizSwitch`             | COMPAT_ALIAS      | `AppSwitch`                        | REMOVE |
| `NexaBizCard`               | COMPAT_ALIAS      | `AppCard`                          | REMOVE |
| `NexaBizLoading`            | COMPAT_ALIAS      | `AppLoading`                       | REMOVE |
| `NexaBizLoadingStyle`       | COMPAT_ALIAS      | `AppLoadingStyle`                  | REMOVE |
| `NexaBizEmptyState`         | COMPAT_ALIAS      | `AppEmptyState`                    | REMOVE |
| `NexaBizErrorState`         | COMPAT_ALIAS      | `AppErrorState`                    | REMOVE |
| `NexaBizStatusBadge`        | COMPAT_ALIAS      | `AppStatusBadge`                   | REMOVE |
| `NexaBizDateField`          | COMPAT_ALIAS      | `AppDateField`                     | REMOVE |
| `NexaBizDataTable`          | COMPAT_ALIAS      | `AppDataTable`                     | REMOVE |
| `CustomAppBar`              | COMPAT_ALIAS      | `AppCustomAppBar`                  | REMOVE |
| `AppTopBar`                 | COMPAT_ALIAS      | `AppCustomAppBar`                  | REMOVE |
| `NexaBizTree`               | COMPAT_ALIAS      | `AppTree`                          | REMOVE |
| `NexaBizTreeNodeRow`        | COMPAT_ALIAS      | `AppTreeNodeRow`                   | REMOVE |
| `NexaBizTreeNode`           | COMPAT_ALIAS      | package-internal shadcn tree model | REMOVE |
| `NexaBizTreeItemNode`       | COMPAT_ALIAS      | package-internal shadcn tree model | REMOVE |
| `NexaBizTreeRootNode`       | COMPAT_ALIAS      | package-internal shadcn tree model | REMOVE |
| `NexaBizBranchLine`         | COMPAT_ALIAS      | package-internal shadcn tree model | REMOVE |
| `showNexaBizDialog`         | COMPAT_ALIAS      | `AppDialog.show`                   | REMOVE |

## Canonical decisions

- Page layout: `AppPage` and its seven specialized page types.
- Forms: `AppForm`, `AppFormSection`, `AppFormRow`, and `AppFormActions`.
- Fields: canonical `App*Field` components; selection uses `AppSelectField` with `AppSelectOption`.
- Dialogs and sheets: `AppDialog`, `AppFormDialog`, `AppBottomSheet`, `AppDrawerSheet`, `AppFormSheet`, and `AppSwiperSheet`.
- Application navigation: `AppResponsiveScaffold`, `AppSidebar`, `AppCustomBottomNav`, and `AppNavigationItem`. The application owns route interpretation.
- Localization: application strings use generated `AppLocalizations`; reusable package strings use `NexaBizUiLocalizations`.
- Responsive behavior: `AppResponsive` and `AppBreakpoints`; compact is below 600, medium 600–999, expanded 1000–1439, and wide 1440 and above.

The exact export-set guardrail lives in `test/architecture/public_api_architecture_guardrail_test.dart` and intentionally requires review when a public export changes.
