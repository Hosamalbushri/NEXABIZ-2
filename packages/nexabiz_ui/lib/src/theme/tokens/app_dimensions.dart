import 'package:flutter/material.dart';

import '../../layout/app_layout_tokens.dart';

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

  /// Standard input field height.
  static const double inputHeight = 48.0;

  /// Desktop/dense input field height.
  static const double desktopInputHeight = 40.0;

  /// Large input field height.
  static const double inputHeightLarge = 56.0;

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
  static const double navRailWidth = navCollapsedSidebarWidth;

  /// Enterprise structured top header height.
  static const double topHeaderHeight = 48.0;

  /// Navigation Sidebar expanded width.
  /// Deprecated: Authoritative layout tokens reside in [AppLayoutTokens.navSidebarWidth].
  @Deprecated('Use AppLayoutTokens.navSidebarWidth instead')
  static const double navSidebarWidth = AppLayoutTokens.navSidebarWidth;

  /// Navigation Drawer expanded width (aliased to [navSidebarWidth]).
  static const double navDrawerWidth = navSidebarWidth;

  /// Navigation Collapsed Sidebar width.
  /// Deprecated: Authoritative layout tokens reside in [AppLayoutTokens.navCollapsedSidebarWidth].
  @Deprecated('Use AppLayoutTokens.navCollapsedSidebarWidth instead')
  static const double navCollapsedSidebarWidth =
      AppLayoutTokens.navCollapsedSidebarWidth;

  /// Standard minimum button size.
  static const Size minimumButtonSize = Size(64.0, buttonHeight);

  /// Compact minimum button size.
  static const Size minimumButtonSizeCompact = Size(48.0, buttonHeightCompact);
}
