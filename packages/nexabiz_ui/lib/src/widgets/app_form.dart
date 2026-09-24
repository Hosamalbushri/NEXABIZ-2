import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../theme/tokens/tokens.dart';
import '../layout/app_layout_tokens.dart';
import 'app_form_actions.dart';

/// Canonical NexaBiz Form Section Container.
///
/// Groups related form fields with a clear visual section header, description,
/// and rounded border container consistent with shadcn_flutter theme tokens.
class AppFormSection extends StatelessWidget {
  const AppFormSection({
    super.key,
    this.title,
    this.description,
    String? subtitle,
    this.icon,
    this.children = const [],
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.spacing = AppSpacing.md,
    this.topSpacing,
    this.bottomSpacing,
  }) : subtitle = subtitle ?? description;

  final String? title;
  final String? description;
  final String? subtitle;
  final IconData? icon;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double? topSpacing;
  final double? bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return _buildSection(context);
  }

  Widget _buildSection(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasHeader = title != null || description != null || icon != null;

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasHeader) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(theme.radiusSm),
                  ),
                  child: Icon(icon, size: 18, color: colorScheme.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
              ] else ...[
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(theme.radiusSm),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: theme.typography.p.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.foreground,
                        ),
                      ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: theme.typography.small.copyWith(
                          color: colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.border.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) SizedBox(height: spacing),
        ],
      ],
    );

    return Padding(
      padding: EdgeInsets.only(
        top: topSpacing ?? 0,
        bottom: bottomSpacing ?? 0,
      ),
      child: column,
    );
  }
}

/// Canonical constraint-aware form composition for NexaBiz forms.
///
/// Fields use the width granted by the immediate parent, a minimum useful
/// column width, and text scaling to choose a safe column count. This is a
/// local composition policy, not a device-tier breakpoint. [fullWidthChildren]
/// remain full width at every column count.
class AppFormRow extends StatelessWidget {
  const AppFormRow({
    super.key,
    required this.children,
    this.fullWidthChildren = const [],
    this.spacing = AppSpacing.md,
    this.runSpacing = AppSpacing.md,
    this.minColumnWidth = AppLayoutTokens.formColumnMinWidth,
    this.maxColumns = AppLayoutTokens.formMaxColumns,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  }) : assert(minColumnWidth > 0),
       assert(maxColumns > 0);

  final List<Widget> children;
  final List<Widget> fullWidthChildren;
  final double spacing;
  final double runSpacing;
  final double minColumnWidth;
  final int maxColumns;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty && fullWidthChildren.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScaler = MediaQuery.textScalerOf(context);
        final textScaleFactor = (textScaler.scale(14) / 14).clamp(1.0, 1.5);
        final effectiveMinWidth = minColumnWidth * textScaleFactor;
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : effectiveMinWidth;
        final computedColumns =
            ((availableWidth + spacing) / (effectiveMinWidth + spacing))
                .floor();
        final columns = math.max(1, math.min(maxColumns, computedColumns));

        final regularFields = columns == 1
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < children.length; index++) ...[
                    if (index > 0) SizedBox(height: runSpacing),
                    children[index],
                  ],
                ],
              )
            : Wrap(
                spacing: spacing,
                runSpacing: runSpacing,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  for (final child in children)
                    SizedBox(
                      width:
                          (availableWidth - spacing * (columns - 1)) / columns,
                      child: child,
                    ),
                ],
              );

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            if (children.isNotEmpty)
              SizedBox(width: double.infinity, child: regularFields),
            for (var index = 0; index < fullWidthChildren.length; index++) ...[
              if (children.isNotEmpty || index > 0)
                SizedBox(height: runSpacing),
              SizedBox(width: double.infinity, child: fullWidthChildren[index]),
            ],
          ],
        );
      },
    );
  }
}

/// Immutable configuration data passed down the widget tree via [shadcn.Data.inherit].
class AppFormConfiguration {
  const AppFormConfiguration({
    this.isSubmitting = false,
    this.enabled = true,
    this.readOnly = false,
    this.spacing = AppSpacing.lg,
  });

  final bool isSubmitting;
  final bool enabled;
  final bool readOnly;
  final double spacing;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppFormConfiguration &&
          runtimeType == other.runtimeType &&
          isSubmitting == other.isSubmitting &&
          enabled == other.enabled &&
          readOnly == other.readOnly &&
          spacing == other.spacing;

  @override
  int get hashCode => Object.hash(isSubmitting, enabled, readOnly, spacing);
}

/// Canonical Form Container for NexaBiz ERP.
///
/// Centralizes layout, form key binding, section spacing, submit/cancel action bar,
/// error banner presentation, and submitting state.
class AppForm extends StatelessWidget {
  const AppForm({
    super.key,
    this.formKey,
    this.title,
    this.subtitle,
    this.icon,
    this.errorMessage,
    required this.children,
    this.onSubmit,
    this.submitLabel,
    this.onCancel,
    this.cancelLabel,
    this.isSubmitting = false,
    this.maxWidth = 640,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.spacing = AppSpacing.lg,
    this.stickyActions = true,
    this.extraActions,
  });

  final GlobalKey<FormState>? formKey;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final String? errorMessage;
  final List<Widget> children;
  final VoidCallback? onSubmit;
  final String? submitLabel;
  final VoidCallback? onCancel;
  final String? cancelLabel;
  final bool isSubmitting;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final bool stickyActions;
  final List<Widget>? extraActions;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasHeader = title != null || subtitle != null || icon != null;

    final formBody = shadcn.Data<AppFormConfiguration>.inherit(
      data: AppFormConfiguration(
        isSubmitting: isSubmitting,
        enabled: !isSubmitting,
        spacing: spacing,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: padding,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Bar
                  if (hasHeader) ...[
                    Row(
                      children: [
                        if (icon != null) ...[
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(
                                theme.radiusSm,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title != null)
                                Text(
                                  title!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.foreground,
                                  ),
                                ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.mutedForeground,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Global Error Banner
                  if (errorMessage != null &&
                      errorMessage!.trim().isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colorScheme.destructive.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(theme.radiusMd),
                        border: Border.all(
                          color: colorScheme.destructive.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: colorScheme.destructive,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.destructive,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Form Children / Sections
                  for (int i = 0; i < children.length; i++) ...[
                    children[i],
                    if (i < children.length - 1) SizedBox(height: spacing),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final actionsWidget = AppFormActions(
      onSubmit: onSubmit,
      submitLabel: submitLabel,
      onCancel: onCancel,
      cancelLabel: cancelLabel,
      isLoading: isSubmitting,
      isSticky: stickyActions,
      extraActions: extraActions,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: formBody),
        actionsWidget,
      ],
    );
  }
}
