import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Canonical localization authority for `nexabiz_ui`.
///
/// Provides single-source-of-truth strings for UI components, eliminating
/// hardcoded strings and decoupling language from text directionality (RTL/LTR).
class NexaBizUiLocalizations {
  const NexaBizUiLocalizations(this.locale);

  final Locale locale;

  /// Canonical delegate instance.
  static const LocalizationsDelegate<NexaBizUiLocalizations> delegate =
      NexaBizUiLocalizationsDelegate();

  /// Obtains the [NexaBizUiLocalizations] from the given [context].
  ///
  /// If no delegate is registered in the current [context] (e.g. during isolated
  /// widget tests), falls back to resolving by [Localizations.maybeLocaleOf] or
  /// defaulting to English without throwing an exception.
  static NexaBizUiLocalizations of(BuildContext context) {
    final instance = Localizations.of<NexaBizUiLocalizations>(
      context,
      NexaBizUiLocalizations,
    );
    if (instance != null) {
      return instance;
    }
    final activeLocale =
        Localizations.maybeLocaleOf(context) ?? const Locale('en');
    return NexaBizUiLocalizations(activeLocale);
  }

  bool get _isArabic => locale.languageCode == 'ar';

  String get save => _isArabic ? 'حفظ' : 'Save';
  String get cancel => _isArabic ? 'إلغاء' : 'Cancel';
  String get confirm => _isArabic ? 'تأكيد' : 'Confirm';
  String get ok => _isArabic ? 'موافق' : 'OK';
  String get delete => _isArabic ? 'حذف' : 'Delete';
  String get proceed => _isArabic ? 'متابعة' : 'Proceed';
  String get action => _isArabic ? 'إجراء' : 'Action';
  String get search => _isArabic ? 'بحث' : 'Search';
  String get searchHint => _isArabic ? 'بحث...' : 'Search...';
  String get searchPlaceholder => _isArabic ? 'بحث...' : 'Search...';
  String get searchCountry =>
      _isArabic ? 'ابحث عن الدولة...' : 'Search country...';
  String get searchFailed => _isArabic ? 'فشلت عملية البحث' : 'Search failed';
  String get noResults => _isArabic ? 'لا توجد نتائج' : 'No results found';
  String get closeSearch => _isArabic ? 'إغلاق البحث' : 'Close Search';
  String get close => _isArabic ? 'إغلاق' : 'Close';
  String get clear => _isArabic ? 'مسح' : 'Clear';
  String get back => _isArabic ? 'رجوع' : 'Back';
  String get filter => _isArabic ? 'تصفية' : 'Filter';
  String filterCount(int count) =>
      _isArabic ? 'عوامل التصفية النشطة: $count' : 'Active filters: $count';
  String get menu => _isArabic ? 'القائمة' : 'Menu';
  String get notifications => _isArabic ? 'الإشعارات' : 'Notifications';
  String get itemsPerPage =>
      _isArabic ? 'عدد العناصر في الصفحة' : 'Items per page';
  String get select => _isArabic ? 'اختر...' : 'Select...';
  String get selectOption => _isArabic ? 'اختر الخيار...' : 'Select option...';
  String get selectItems => _isArabic ? 'اختر العناصر...' : 'Select items...';
  String get selectDate => _isArabic ? 'اختر التاريخ...' : 'Select date...';
  String get selectDateRange =>
      _isArabic ? 'اختر الفترة الزمنية...' : 'Select date range...';
  String get noRecords => _isArabic ? 'لا توجد سجلات' : 'No records found';
  String get noRecordsSubtitle => _isArabic
      ? 'جرّب تعديل كلمة البحث أو تصفية البيانات'
      : 'Try adjusting your search or filter';
  String get noLinesData =>
      _isArabic ? 'جدول الأسطر فارغ' : 'No line items available';
  String get addLine => _isArabic ? 'إضافة سطر' : 'Add line';
  String get scanBarcode => _isArabic ? 'مسح الضوئي' : 'Scan barcode';
  String get noItemsInTable =>
      _isArabic ? 'لا توجد عناصر في الجدول' : 'No items in table';
  String get showFullText => _isArabic ? 'عرض النص كاملًا' : 'Show full text';
  String get hideDetails => _isArabic ? 'إخفاء التفاصيل' : 'Hide details';
  String get required => _isArabic ? 'مطلوب' : 'Required';
}

/// [LocalizationsDelegate] for [NexaBizUiLocalizations].
class NexaBizUiLocalizationsDelegate
    extends LocalizationsDelegate<NexaBizUiLocalizations> {
  const NexaBizUiLocalizationsDelegate();

  static const NexaBizUiLocalizationsDelegate delegate =
      NexaBizUiLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<NexaBizUiLocalizations> load(Locale locale) {
    return SynchronousFuture<NexaBizUiLocalizations>(
      NexaBizUiLocalizations(locale),
    );
  }

  @override
  bool shouldReload(NexaBizUiLocalizationsDelegate old) => false;
}
