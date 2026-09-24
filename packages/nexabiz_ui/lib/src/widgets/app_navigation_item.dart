import 'package:flutter/widgets.dart';

/// Router-agnostic data shared by NexaBiz application navigation surfaces.
@immutable
class AppNavigationItem {
  const AppNavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
    this.trailing,
    this.enabled = true,
  });

  /// Opaque destination identifier interpreted by the application callback.
  final String id;

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final Widget? badge;
  final Widget? trailing;
  final bool enabled;
}
