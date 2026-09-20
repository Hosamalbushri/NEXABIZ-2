import 'package:flutter/material.dart';

/// Touch target sizes, control heights, and layout dimensions for NexaBiz.
class AppDimensions {
  const AppDimensions._();

  /// WCAG AA recommended minimum touch target size (48x48 px).
  static const double minTouchTarget = 48.0;

  /// Standard button height.
  static const double buttonHeight = 48.0;

  /// Desktop/dense button height.
  static const double desktopButtonHeight = 40.0;

  /// Compact button height.
  static const double buttonHeightCompact = 36.0;

  /// Input field height.
  static const double inputHeight = 48.0;

  /// Desktop/dense input field height.
  static const double desktopInputHeight = 40.0;

  /// Search bar height.
  static const double searchBarHeight = 44.0;

  /// Table header height.
  static const double tableHeaderHeight = 44.0;

  /// Table row height.
  static const double tableRowHeight = 52.0;

  /// Compact table row height.
  static const double tableRowHeightCompact = 40.0;

  /// Top AppBar / Header height.
  static const double appBarHeight = 64.0;

  /// Navigation Rail / Collapsed Sidebar width.
  static const double navRailWidth = 64.0;

  /// Enterprise structured top header height.
  static const double topHeaderHeight = 48.0;

  /// Navigation Sidebar expanded width.
  static const double navSidebarWidth = 240.0;

  /// Navigation Drawer expanded width (aliased to [navSidebarWidth]).
  static const double navDrawerWidth = navSidebarWidth;

  /// Navigation Collapsed Sidebar width.
  static const double navCollapsedSidebarWidth = 64.0;

  /// Standard minimum button size.
  static const Size minimumButtonSize = Size(64.0, buttonHeight);

  /// Compact minimum button size.
  static const Size minimumButtonSizeCompact = Size(48.0, buttonHeightCompact);
}
