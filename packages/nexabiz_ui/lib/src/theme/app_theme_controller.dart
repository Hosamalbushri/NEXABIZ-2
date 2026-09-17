import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Global theme mode controller for NexaBiz UI.
abstract final class AppThemeController {
  /// Global ValueNotifier for active ThemeMode.
  static final ValueNotifier<shadcn.ThemeMode> themeModeNotifier =
      ValueNotifier<shadcn.ThemeMode>(shadcn.ThemeMode.system);

  /// Get current theme mode.
  static shadcn.ThemeMode get currentThemeMode => themeModeNotifier.value;

  /// Check whether active effective theme is dark.
  static bool isDark(BuildContext context) {
    if (themeModeNotifier.value == shadcn.ThemeMode.dark) return true;
    if (themeModeNotifier.value == shadcn.ThemeMode.light) return false;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }

  /// Explicitly set theme mode.
  static void setThemeMode(shadcn.ThemeMode mode) {
    themeModeNotifier.value = mode;
  }

  /// Toggle between light and dark theme mode.
  static void toggleTheme(bool isDark) {
    themeModeNotifier.value =
        isDark ? shadcn.ThemeMode.dark : shadcn.ThemeMode.light;
  }
}
