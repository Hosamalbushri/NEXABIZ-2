import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global locale controller for NexaBiz ERP application.
/// Manages active Locale state and persists user language selection across restarts.
abstract final class AppLocaleController {
  static const String _prefsKey = 'nexabiz_user_locale';

  /// Supported application locales: English (en) and Arabic (ar).
  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];

  /// Fallback locale when device/selected locale is unsupported.
  static const Locale defaultFallbackLocale = Locale('en');

  /// Global ValueNotifier for active Locale.
  static final ValueNotifier<Locale> localeNotifier = ValueNotifier<Locale>(
    defaultFallbackLocale,
  );

  /// Get current active Locale.
  static Locale get currentLocale => localeNotifier.value;

  /// Check whether current locale is RTL (Arabic).
  static bool get isRtl => localeNotifier.value.languageCode == 'ar';

  /// Initialize locale controller from persistent storage or system environment.
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefsKey);
      if (savedCode != null && savedCode.isNotEmpty) {
        if (isSupportedCode(savedCode)) {
          localeNotifier.value = Locale(savedCode);
          return;
        }
      }
    } catch (_) {
      // Preferences access error fallback
    }

    // Default to device locale if supported, else fallback
    final platformLocale = WidgetsBinding.instance.platformDispatcher.locale;
    if (isSupportedCode(platformLocale.languageCode)) {
      localeNotifier.value = Locale(platformLocale.languageCode);
    } else {
      localeNotifier.value = defaultFallbackLocale;
    }
  }

  /// Check if a language code string is supported.
  static bool isSupportedCode(String code) {
    return supportedLocales.any((loc) => loc.languageCode == code);
  }

  /// Explicitly set application locale and persist choice.
  static Future<void> setLocale(Locale locale) async {
    final code = locale.languageCode;
    if (!isSupportedCode(code)) return;

    localeNotifier.value = Locale(code);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, code);
    } catch (_) {
      // Persist error fallback
    }
  }

  /// Switch between Arabic and English.
  static Future<void> toggleLanguage() async {
    final nextCode = currentLocale.languageCode == 'ar' ? 'en' : 'ar';
    await setLocale(Locale(nextCode));
  }
}
