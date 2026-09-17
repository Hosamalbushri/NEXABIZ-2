import 'package:flutter/widgets.dart';

/// Represents a top-level navigation destination in the application shell.
@immutable
class ShellNavigationItem {
  final String id;
  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const ShellNavigationItem({
    required this.id,
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
