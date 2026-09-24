import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/tokens.dart';
import '../utils/digit_normalization.dart';
import 'app_select_option.dart';

/// Single source of truth search matching engine for selection components.
class AppSelectionSearchMatcher {
  const AppSelectionSearchMatcher._();

  /// Matches [query] against [target] and optional [keywords].
  static bool matches({
    required String query,
    required String target,
    List<String> keywords = const [],
  }) {
    final cleanQuery = normalizeDigitsToWestern(query).trim().toLowerCase();
    if (cleanQuery.isEmpty) return true;

    final normTarget = normalizeDigitsToWestern(target).toLowerCase();
    if (normTarget.contains(cleanQuery)) return true;

    for (final kw in keywords) {
      final normKw = normalizeDigitsToWestern(kw).toLowerCase();
      if (normKw.contains(cleanQuery)) return true;
    }

    return false;
  }
}

/// Standardized canonical tile for rendering a selection option across dropdowns,
/// multi-select menus, and popovers.
class AppSelectOptionTile<T> extends StatelessWidget {
  const AppSelectOptionTile({
    super.key,
    required this.option,
    this.isSelected = false,
    this.showCheckmark = false,
    this.customBuilder,
  });

  final AppSelectOption<T> option;
  final bool isSelected;
  final bool showCheckmark;
  final Widget Function(
    BuildContext context,
    AppSelectOption<T> option,
    bool isSelected,
  )?
  customBuilder;

  @override
  Widget build(BuildContext context) {
    if (customBuilder != null) {
      return customBuilder!(context, option, isSelected);
    }

    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;
    final typography = theme.typography;

    final labelColor = !option.enabled
        ? colorScheme.mutedForeground
        : isSelected
        ? colorScheme.primary
        : colorScheme.foreground;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (option.icon != null) ...[
            option.icon!,
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  option.label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: typography.small.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: labelColor,
                  ),
                ),
                if (option.subtitle != null && option.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    option.subtitle!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: typography.xSmall.copyWith(
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showCheckmark && isSelected) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(
              shadcn.LucideIcons.check,
              size: AppIcons.xs,
              color: colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }
}

/// Standardized card container for selection overlays, search popups,
/// and autocomplete dropdowns.
class AppSelectOverlayContainer extends StatelessWidget {
  const AppSelectOverlayContainer({
    super.key,
    required this.child,
    this.constraints,
    this.maxHeight = 280,
    this.minWidth = 220,
    this.padding,
  });

  final Widget child;
  final BoxConstraints? constraints;
  final double maxHeight;
  final double minWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints:
          constraints ??
          BoxConstraints(maxHeight: maxHeight, minWidth: minWidth),
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: BorderRadius.circular(AppRadii.smOf(context)),
        border: Border.all(
          color: colorScheme.border.withValues(alpha: 0.5),
          width: AppBorders.thin,
        ),
        boxShadow: AppElevation.card(theme.brightness),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.smOf(context)),
        child: child,
      ),
    );
  }
}

/// Injects error border styling into descendant [shadcn.Select] outline buttons
/// when [hasError] is true, ensuring seamless composition with borderless [AppFieldShell].
Widget wrapSelectWithErrorTheme({
  required BuildContext context,
  required bool hasError,
  required Widget child,
}) {
  if (!hasError) return child;

  final theme = shadcn.Theme.of(context);
  return shadcn.ComponentTheme<shadcn.OutlineButtonTheme>(
    data: shadcn.OutlineButtonTheme(
      decoration: (context, states, value) {
        if (value is BoxDecoration) {
          return value.copyWith(
            border: Border.all(
              color: theme.colorScheme.destructive,
              width: AppBorders.medium,
            ),
          );
        }
        return BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.smOf(context)),
          border: Border.all(
            color: theme.colorScheme.destructive,
            width: AppBorders.medium,
          ),
        );
      },
    ),
    child: child,
  );
}
