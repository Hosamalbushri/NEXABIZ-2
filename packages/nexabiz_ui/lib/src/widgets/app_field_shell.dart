import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../localization/nexabiz_ui_localizations.dart';
import '../theme/tokens/tokens.dart';
import 'app_form.dart' show AppFormConfiguration;

/// Heights for standardized form field density derived directly from [AppDimensions].
enum AppFieldDensity {
  /// Compact density (40px height) — ideal for table cells or dense desktop layouts.
  compact,

  /// Standard density (48px height) — default for standard ERP forms.
  standard,

  /// Large density (56px height) — ideal for primary touch / prominent search inputs.
  large,
}

extension AppFieldDensityX on AppFieldDensity {
  double get height => switch (this) {
    AppFieldDensity.compact => AppDimensions.desktopInputHeight,
    AppFieldDensity.standard => AppDimensions.inputHeight,
    AppFieldDensity.large => AppDimensions.inputHeightLarge,
  };

  EdgeInsetsGeometry get contentPadding => switch (this) {
    AppFieldDensity.compact => const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    AppFieldDensity.standard => const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 12,
    ),
    AppFieldDensity.large => const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
  };
}

/// Canonical presentation shell for NexaBiz ERP form fields.
///
/// Fully aligned with NexaBiz design tokens and `shadcn_flutter` specifications.
/// Provides standardized label, required indicator (*), description, helper text,
/// error presentation, focus ring, hover/press state, prefix/suffix handling, and density heights.
class AppFieldShell extends StatefulWidget {
  const AppFieldShell({
    super.key,
    required this.child,
    this.label,
    this.required = false,
    this.description,
    this.helperText,
    this.errorText,
    this.density = AppFieldDensity.standard,
    this.enabled = true,
    this.readOnly = false,
    this.focused,
    this.borderless = false,
    this.isMultiline = false,
    this.prefix,
    this.showPrefixDivider = false,
    this.suffix,
    this.shortcutHint,
    this.onClear,
    this.onTap,
    this.focusNode,
  });

  final Widget child;
  final String? label;
  final bool required;
  final String? description;
  final String? helperText;
  final String? errorText;
  final AppFieldDensity density;
  final bool enabled;
  final bool readOnly;
  final bool? focused;
  final bool borderless;
  final bool isMultiline;
  final Widget? prefix;
  final bool showPrefixDivider;
  final Widget? suffix;
  final String? shortcutHint;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  @override
  State<AppFieldShell> createState() => _AppFieldShellState();
}

class _AppFieldShellState extends State<AppFieldShell> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Inherit submission / enabled state from ancestor AppForm if present
    final formConfig = shadcn.Data.maybeOf<AppFormConfiguration>(context);
    final effectiveEnabled = widget.enabled && (formConfig?.enabled ?? true);
    final effectiveReadOnly =
        widget.readOnly || (formConfig?.readOnly ?? false);

    final isDark = theme.brightness == Brightness.dark;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final isFocused =
        (widget.focused ?? false) ||
        _isFocused ||
        (widget.focusNode?.hasFocus ?? false);

    final fillColor = !effectiveEnabled
        ? colorScheme.muted.withValues(alpha: 0.5)
        : effectiveReadOnly
        ? colorScheme.muted.withValues(alpha: 0.3)
        : (isDark
              ? colorScheme.muted.withValues(alpha: 0.2)
              : colorScheme.muted.withValues(alpha: 0.1));

    Color borderColor;
    double borderWidth = AppBorders.thin;
    if (hasError) {
      borderColor = colorScheme.destructive;
      borderWidth = AppBorders.medium;
    } else if (isFocused) {
      borderColor = colorScheme.ring;
      borderWidth = AppBorders.medium;
    } else {
      borderColor = colorScheme.border.withValues(alpha: 0.5);
      borderWidth = AppBorders.thin;
    }

    final effectiveRadius = BorderRadius.circular(AppRadii.smOf(context));

    Widget content;
    final rowChildren = <Widget>[
      if (widget.prefix != null) ...[
        widget.prefix!,
        const SizedBox(width: AppSpacing.xs),
        if (widget.showPrefixDivider) ...[
          Container(
            width: AppBorders.thin,
            height: widget.density.height * 0.4,
            color: colorScheme.border.withValues(alpha: 0.5),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ],
      Expanded(child: widget.child),
      if (widget.onClear != null && effectiveEnabled && !effectiveReadOnly) ...[
        const SizedBox(width: AppSpacing.xxs),
        GestureDetector(
          onTap: widget.onClear,
          behavior: HitTestBehavior.opaque,
          child: Icon(
            shadcn.LucideIcons.circleX,
            size: AppIcons.xs,
            color: colorScheme.mutedForeground,
          ),
        ),
      ],
      if (widget.suffix != null) ...[
        const SizedBox(width: AppSpacing.xs),
        widget.suffix!,
      ],
    ];

    if (widget.borderless) {
      content = Row(
        crossAxisAlignment: widget.isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: rowChildren,
      );
    } else {
      content = GestureDetector(
        onTap: effectiveEnabled && !effectiveReadOnly ? widget.onTap : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.curveDecelerate,
          constraints: BoxConstraints(
            minHeight: widget.isMultiline ? 0 : widget.density.height,
          ),
          padding: widget.density.contentPadding,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: effectiveRadius,
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            crossAxisAlignment: widget.isMultiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: rowChildren,
          ),
        ),
      );
    }

    final loc = NexaBizUiLocalizations.of(context);

    return Focus(
      focusNode: widget.focusNode,
      onFocusChange: (focused) {
        if (_isFocused != focused) {
          setState(() => _isFocused = focused);
        }
      },
      child: Semantics(
        label: widget.label,
        enabled: effectiveEnabled,
        readOnly: effectiveReadOnly,
        hint: widget.errorText ?? widget.helperText,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label case final String lbl when lbl.isNotEmpty) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      lbl,
                      style: theme.typography.small.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: effectiveEnabled
                            ? colorScheme.foreground
                            : colorScheme.mutedForeground,
                      ),
                    ),
                  ),
                  if (widget.required) ...[
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      '*',
                      semanticsLabel: loc.required,
                      style: TextStyle(
                        color: colorScheme.destructive,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
            ],
            if (widget.description case final String desc
                when desc.isNotEmpty) ...[
              Text(
                desc,
                style: theme.typography.small.copyWith(
                  fontSize: 12,
                  color: colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
            ],
            content,
            if (hasError) ...[
              const SizedBox(height: AppSpacing.xxs),
              Semantics(
                liveRegion: true,
                child: Row(
                  children: [
                    Icon(
                      shadcn.LucideIcons.circleAlert,
                      size: 13,
                      color: colorScheme.destructive,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Text(
                        widget.errorText!,
                        style: theme.typography.small.copyWith(
                          fontSize: 12.5,
                          color: colorScheme.destructive,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (widget.helperText case final String helper
                when helper.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                helper,
                style: theme.typography.small.copyWith(
                  fontSize: 12.5,
                  color: colorScheme.mutedForeground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
