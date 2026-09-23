import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'app_field_shell.dart';

/// Design-system text field primitive for NexaBiz ERP built natively on [shadcn.TextField].
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.required = false,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.showPrefixDivider = false,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.density = AppFieldDensity.standard,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final bool required;
  final String? errorText;
  final String? helperText;
  final dynamic prefixIcon;
  final bool showPrefixDivider;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool showPasswordToggle;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final bool autofocus;
  final AppFieldDensity density;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hintTextStyle = theme.typography.small.copyWith(
      color: colorScheme.mutedForeground,
    );

    Widget? effectiveSuffix = widget.suffixIcon;
    if (widget.showPasswordToggle && effectiveSuffix == null) {
      effectiveSuffix = GestureDetector(
        onTap: widget.enabled
            ? () => setState(() => _obscureText = !_obscureText)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 18,
            color: colorScheme.mutedForeground,
          ),
        ),
      );
    }

    final childInput = shadcn.TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      obscureText: _obscureText,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged != null
          ? (value) {
              final binding = WidgetsBinding.instance;
              if (binding.buildOwner?.debugBuilding ?? false) {
                binding.addPostFrameCallback((_) => widget.onChanged!(value));
              } else {
                widget.onChanged!(value);
              }
            }
          : null,
      onSubmitted: widget.onSubmitted != null
          ? (value) {
              final binding = WidgetsBinding.instance;
              if (binding.buildOwner?.debugBuilding ?? false) {
                binding.addPostFrameCallback((_) => widget.onSubmitted!(value));
              } else {
                widget.onSubmitted!(value);
              }
            }
          : null,
      placeholder: widget.hint != null
          ? Text(widget.hint!, style: hintTextStyle)
          : null,
      padding: EdgeInsets.zero,
      border: const Border(),
      features: const [],
    );

    final prefixWidget = widget.prefixIcon is IconData
        ? Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: widget.enabled
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : colorScheme.muted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                widget.prefixIcon as IconData,
                size: 16,
                color: widget.enabled
                    ? colorScheme.primary
                    : colorScheme.mutedForeground,
              ),
            ),
          )
        : widget.prefixIcon as Widget?;

    return AppFieldShell(
      label: widget.label,
      required: widget.required,
      errorText: widget.errorText,
      helperText: widget.helperText,
      density: widget.density,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      prefix: prefixWidget,
      showPrefixDivider: widget.showPrefixDivider,
      suffix: effectiveSuffix,
      child: childInput,
    );
  }
}
