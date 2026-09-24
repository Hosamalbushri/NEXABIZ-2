import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Canonical Switch control for NexaBiz ERP backed natively by `shadcn_flutter`.
///
/// Fully supports bidirectional layouts (RTL/LTR). In RTL directionality,
/// the switch orientation is mirrored so the active (ON) state moves towards
/// the reading end (left) and the inactive (OFF) state rests at the start (right).
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    Widget switchWidget = shadcn.Switch(
      value: value,
      onChanged: enabled && onChanged != null ? onChanged : null,
    );

    if (isRtl) {
      switchWidget = Transform.flip(flipX: true, child: switchWidget);
    }

    if (label == null) {
      return switchWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [switchWidget, const SizedBox(width: 8.0), Text(label!)],
    );
  }
}
