import 'package:flutter/material.dart';

import '../layout/app_layout_tokens.dart';
import '../localization/nexabiz_ui_localizations.dart';
import '../theme/tokens/app_spacing.dart';
import 'app_button.dart';
import 'app_search_field.dart';

/// Canonical search toolbar composite for NexaBiz ERP lists and tables.
///
/// Combines search field with optional filter trigger, view mode toggle,
/// and sort action dropdown.
class AppSearchToolbar extends StatelessWidget {
  const AppSearchToolbar({
    super.key,
    this.searchController,
    this.onSearchChanged,
    this.onSearchClear,
    this.searchHint,
    this.onFilterTap,
    this.filterCount = 0,
    this.actions,
  });

  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClear;
  final String? searchHint;
  final VoidCallback? onFilterTap;
  final int filterCount;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final loc = NexaBizUiLocalizations.of(context);
    final effectiveSearchHint = searchHint ?? loc.searchHint;
    final toolbarActions = <Widget>[
      if (onFilterTap != null)
        AppButton(
          label: filterCount > 0 ? loc.filterCount(filterCount) : loc.filter,
          icon: Icons.tune_rounded,
          variant: filterCount > 0
              ? AppButtonVariant.filled
              : AppButtonVariant.outlined,
          onPressed: onFilterTap,
        ),
      ...?actions,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final search = AppSearchField(
            controller: searchController,
            hint: effectiveSearchHint,
            onChanged: onSearchChanged,
            onClear: onSearchClear,
          );
          final actionCluster = Wrap(
            alignment: WrapAlignment.end,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: toolbarActions,
          );
          final stack =
              toolbarActions.isNotEmpty &&
              (!constraints.hasBoundedWidth ||
                  constraints.maxWidth <
                      AppLayoutTokens.sectionHeaderStackMaxWidth);

          if (stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: actionCluster,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: search),
              if (toolbarActions.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                Flexible(child: actionCluster),
              ],
            ],
          );
        },
      ),
    );
  }
}
