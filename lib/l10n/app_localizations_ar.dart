// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'نيكسابيز ERP';

  @override
  String get navDashboard => 'لوحة التحكم';

  @override
  String get navServices => 'الخدمات';

  @override
  String get navReports => 'التقارير';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get quickActionsTitle => 'إجراءات سريعة';

  @override
  String get quickActionsSubtitle =>
      'تنفيذ العمليات التجارية وأدوات المطور الشائعة';

  @override
  String get quickActionComponentGallery => 'معرض المكونات';

  @override
  String get quickActionComponentGalleryDesc =>
      'معرض واجهة المستخدم ومساحة المكونات';

  @override
  String get quickActionNewInvoice => 'فاتورة جديدة';

  @override
  String get quickActionNewInvoiceDesc => 'إنشاء فاتورة مبيعات';

  @override
  String get quickActionNewCustomer => 'عميل جديد';

  @override
  String get quickActionNewCustomerDesc => 'تسجيل حساب عميل';

  @override
  String get quickActionAddProduct => 'إضافة منتج';

  @override
  String get quickActionAddProductDesc => 'إدخال عنصر مخزون';

  @override
  String get exitDialogTitle => 'الخروج من التطبيق';

  @override
  String get exitDialogMessage =>
      'هل أنت تأكد من رغبتك في الخروج من نيكسابيز ERP؟';

  @override
  String get actionExit => 'خروج';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionOk => 'موافق';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionClearLog => 'مسح السجل';

  @override
  String get actionSystemReady => 'النظام جاهز';

  @override
  String get actionDocumentation => 'الوثائق';

  @override
  String get dashboardTitle => 'لوحة تحكم نيكسابيز';

  @override
  String get dashboardSubtitle => 'مرحباً بعودتك إلى نيكسابيز ERP';

  @override
  String get dashboardEnterpriseHighlights => 'أبرز إنجازات المؤسسة';

  @override
  String get dashboardHighlight1Title => 'ذروة الإيرادات المالية للربع الثالث';

  @override
  String get dashboardHighlight1Subtitle =>
      'تم تجاوز هدف المبيعات بنسبة +14.2% بإجمالي \$124,500.00.';

  @override
  String get dashboardHighlight1Badge => 'إنجاز مالي';

  @override
  String get dashboardHighlight2Title => 'تنبيه إعادة إمداد المخزون';

  @override
  String get dashboardHighlight2Subtitle =>
      '18 طلب شراء نشط قيد النقل عبر المستودعات الرئيسية.';

  @override
  String get dashboardHighlight2Badge => 'سلسلة الإمداد';

  @override
  String get dashboardHighlight3Title => 'مزامنة السندات الآلية';

  @override
  String get dashboardHighlight3Subtitle =>
      'تمت مزامنة جميع دفاتر سندات القبض والدفع الفورية بالكامل.';

  @override
  String get dashboardHighlight3Badge => 'دفتر الأستاذ الفوري';

  @override
  String get dashboardArchitectureActive => 'البنية النظيفة النمطية نشطة';

  @override
  String get dashboardArchitectureSubtitle =>
      'النظام يعمل • مزامنة الإمكانيات الفورية مفعلة';

  @override
  String get statusOnline => 'متصل';

  @override
  String get statusStandby => 'استعداد';

  @override
  String get statusSynced => 'متزامن';

  @override
  String get statusPrimary => 'رئيسي';

  @override
  String get kpiTotalSales => 'إجمالي المبيعات';

  @override
  String get kpiTotalSalesSubtitle => '+12.5% هذا الشهر';

  @override
  String get kpiPurchases => 'المشتريات';

  @override
  String get kpiPurchasesSubtitle => '18 أوامر شراء نشطة';

  @override
  String get kpiReceivables => 'المستحقات';

  @override
  String get kpiReceivablesSubtitle => '4 فواتير معلقة';

  @override
  String get kpiStockValuation => 'تقييم المخزون';

  @override
  String get kpiStockValuationSubtitle => '1,240 صنف مخزون';

  @override
  String get recentActivityTitle => 'النشاط الحديث';

  @override
  String get recentActivityItem1Title => 'فاتورة مبيعات #INV-2026-0042';

  @override
  String get recentActivityItem1Subtitle =>
      'العميل: شركة أكما للتجارة • \$3,450.00';

  @override
  String get recentActivityItem1Time => 'منذ 10 دقائق';

  @override
  String get recentActivityItem2Title => 'نقل مخزون #TR-902';

  @override
  String get recentActivityItem2Subtitle => 'المستودع الرئيسي ← فرع التجزئة ب';

  @override
  String get recentActivityItem2Time => 'منذ ساعة واحدة';

  @override
  String get recentActivityItem3Title => 'سند قبض #RCV-1021';

  @override
  String get recentActivityItem3Subtitle =>
      'تم استلام الدفعة للفاتورة #INV-2026-0019';

  @override
  String get recentActivityItem3Time => 'منذ 3 ساعات';

  @override
  String get servicesTitle => 'مركز الخدمات';

  @override
  String get servicesSubtitle => 'إمكانيات الأعمال ومُشغّلات الخدمات المتاحة';

  @override
  String get servicesDevSection => 'النظام وأدوات المطور';

  @override
  String get servicesDevSectionSubtitle =>
      'نظام تصميم واجهة المستخدم ومساحة المكونات';

  @override
  String get servicesComponentGallerySubtitle =>
      'مساحة تفاعلية لمكونات shadcn_flutter';

  @override
  String get servicesFinancialSection => 'المالية والمحاسبة';

  @override
  String get servicesFinancialSectionSubtitle =>
      'أدوات الإدارة المالية الأساسية';

  @override
  String get servicesGeneralLedger => 'دفتر الأستاذ العام';

  @override
  String get servicesGeneralLedgerSubtitle => 'قيود اليومية ودليل الحسابات';

  @override
  String get servicesTreasuryCash => 'الخزينة والسيولة';

  @override
  String get servicesTreasuryCashSubtitle =>
      'الحسابات البنكية التدفقات النقدية';

  @override
  String get servicesVoucherBooks => 'دفاتر السندات';

  @override
  String get servicesVoucherBooksSubtitle => 'ترقيم المستندات والدفاتر';

  @override
  String get servicesTaxVat => 'الضرائب والقيمة المضافة';

  @override
  String get servicesTaxVatSubtitle => 'نسب الضرائب والتقارير';

  @override
  String get servicesSupplyChainSection => 'سلسلة الإمداد والتجارة';

  @override
  String get servicesSupplyChainSectionSubtitle =>
      'تقييم المخزون، المشتريات، وعمليات المبيعات';

  @override
  String get servicesInventoryWarehouses => 'المخزون والمستودعات';

  @override
  String get servicesInventoryWarehousesSubtitle => 'أرصدة المخزون والتحويلات';

  @override
  String get servicesSalesBilling => 'المبيعات والفوترة';

  @override
  String get servicesSalesBillingSubtitle => 'الفواتير، الطلبات والعملاء';

  @override
  String get servicesPurchasingPOs => 'المشتريات وأوامر الشراء';

  @override
  String get servicesPurchasingPOSubtitle => 'أوامر الشراء والموردين';

  @override
  String get servicesLogisticsShipping => 'اللوجستيات والشحن';

  @override
  String get servicesLogisticsShippingSubtitle => 'تتبع الشحنات والإرسال';

  @override
  String get reportsTitle => 'مركز التقارير';

  @override
  String get reportsSubtitle => 'التقارير المالية، التشغيلية، والتحليلية';

  @override
  String get reportsEngineStatus => 'حالة المحرك';

  @override
  String get reportsEngineStatusBody =>
      'محرك التقارير في وضع الاستعداد • محولات البيانات جاهزة';

  @override
  String get reportsFinancialReports => 'التقارير المالية';

  @override
  String get reportsTrialBalance => 'ميزان المراجعة';

  @override
  String get reportsTrialBalanceSubtitle => 'ملخصات المدين/الدائن';

  @override
  String get reportsBalanceSheet => 'الميزانية العمومية';

  @override
  String get reportsBalanceSheetSubtitle => 'الأصول والخصوم';

  @override
  String get reportsProfitLoss => 'الأرباح والخسائر';

  @override
  String get reportsProfitLossSubtitle => 'الإيرادات مقابل المصروفات';

  @override
  String get reportsGLAudit => 'تدقيق دفتر الأستاذ العام';

  @override
  String get reportsGLAuditSubtitle => 'التحقق من القيود';

  @override
  String get settingsTitle => 'الإعدادات والتكوين';

  @override
  String get settingsSubtitle => 'تفضيلات التطبيق وإدارة ملف المؤسسة';

  @override
  String get settingsDevToolsSection => 'أدوات المطور ونظام التصميم';

  @override
  String get settingsNavTestLab => 'مختبر اختبار التنقل';

  @override
  String get settingsNavTestLabSubtitle =>
      'مختبر التنقل العميق، الفروع، والطبقات المتراكبة';

  @override
  String get settingsGallery => 'معرض مكونات واجهة المستخدم';

  @override
  String get settingsGallerySubtitle =>
      'بيئة تفاعلية لاختبار مكونات shadcn_flutter';

  @override
  String get settingsAppPreferencesSection => 'تفضيلات التطبيق';

  @override
  String get settingsDarkMode => 'الوضع الداكن';

  @override
  String get settingsDarkModeOn => 'المظهر الداكن مفعّل';

  @override
  String get settingsDarkModeOff => 'المظهر الفاتح مفعّل';

  @override
  String get settingsLanguage => 'اللغة والترجمة';

  @override
  String get settingsLanguageSelectTitle => 'اختر لغة التطبيق';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageEnglishSubtitle => 'English (US)';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageArabicSubtitle => 'العربية (المملكة العربية السعودية)';

  @override
  String get settingsCompanyProfileSection => 'ملف الشركة والعملة';

  @override
  String get settingsCompanyProfile => 'ملف الشركة';

  @override
  String get settingsCompanyProfileSubtitle => 'شركة نيكسابيز للمؤسسات';

  @override
  String get settingsFunctionalCurrency => 'العملة الوظيفية';

  @override
  String get settingsFunctionalCurrencySubtitle => 'USD - دولار أمريكي';

  @override
  String get settingsSecuritySyncSection => 'الأمان والمزامنة';

  @override
  String get settingsSecurityControls => 'الأمان وصلاحيات الوصول';

  @override
  String get settingsSecurityControlsSubtitle =>
      'إدارة أدوار المستخدمين وصلاحيات الإمكانيات';

  @override
  String get settingsOfflineSync => 'المزامنة والتخزين المحلي';

  @override
  String get settingsOfflineSyncSubtitle => 'جميع قواعد البيانات المحلية محدثة';

  @override
  String get demoTitle => 'إمكانية العرض التوضيحي لنيكسابيز';

  @override
  String get demoSubtitle =>
      'تم التحقق من تسجيل الإمكانية والبنية النظيفة مع تكامل shadcn_flutter';

  @override
  String get demoBadge => 'تم التحقق من بنية الإمكانية';

  @override
  String get demoDescription =>
      'توجد هذه الإمكانية لإثبات تسجيل الإمكانيات، الترتيب التوبولوجي، حل سجل التنقل، تكامل محول GoRouter، وتكامل نظام تصميم نيكسابيز.';

  @override
  String get demoArchPrinciples => 'مبادئ البنية';

  @override
  String get demoArchPrinciplesSubtitle => 'نمطية نظيفة / المنافذ والمحولات';

  @override
  String get demoArchPrinciple1 => '• الإمكانية هي وحدة التطبيق أثناء التشغيل.';

  @override
  String get demoArchPrinciple2 => '• الحزمة هي حد التنفيذ الفعلي.';

  @override
  String get demoArchPrinciple3 => '• يتم الإعلان عن التنقل بواسطة الإمكانيات.';

  @override
  String get demoArchPrinciple4 => '• GoRouter هو محول بنية تحتية.';

  @override
  String get demoArchPrinciple5 =>
      '• مكونات الواجهة تأتي من حزمة nexabiz_ui الرسمية.';

  @override
  String get navLabTitle => 'مختبر اختبار التنقل';

  @override
  String get navLabSubtitle => 'بيئة اختبار وتصليد التنقل للإنتاج';

  @override
  String get navLabBadge => 'مختبر التطوير';

  @override
  String get navLabTelemetryLabRoot => 'جذر المختبر';

  @override
  String get navLabTelemetryTargetRouter => 'الموجه المستهدف';

  @override
  String get navLabTelemetryRootScope => 'نطاق الجذر';

  @override
  String get navLabTelemetryStackStrategy => 'استراتيجية التكديس';

  @override
  String get navLabBranchLaunchersSection => 'مشغلات فروع الاختبار';

  @override
  String get navLabBranchATitle =>
      'الفرع أ (اختبار خطي 4 مستويات ومستويات شقيقة)';

  @override
  String get navLabBranchBTitle => 'الفرع ب (فرع بدييل عميق)';

  @override
  String get navLabBranchCTitle => 'الفرع ج (مسار مستقل)';

  @override
  String get navLabBranchParamTitle => 'المسارات المعلمية';

  @override
  String get navLabBranchDestructiveTitle => 'عروض التنقل التدميري';

  @override
  String get navLabManualInstructionsSection => 'تعليمات الاختبار اليدوي';

  @override
  String get navLabEventLogSection => 'سجل أحداث التنقل';

  @override
  String get navLabRecentTelemetryEvents => 'أحداث القياس السلكي الحديثة';

  @override
  String get navLabNoEventsLogged =>
      'لم يتم تسجيل أي أحداث بعد. انقر على أحد المشغلات أعلاه.';

  @override
  String get navLabNodeTelemetry => 'قياسات المسار الحالي';

  @override
  String get navLabNodeName => 'اسم العقدة';

  @override
  String get navLabRoutePath => 'مسار التنقل';

  @override
  String get navLabParentRoute => 'المسار الأب';

  @override
  String get navLabStackDepth => 'عمق التكدس';

  @override
  String get navLabBranch => 'الفرع';

  @override
  String get navLabChildNavigationPush => 'تنقل الأبناء (PUSH)';

  @override
  String get navLabTestControls => 'عناصر التحكم بالاختبار';

  @override
  String get navLabBackPop => 'رجوع (POP)';

  @override
  String get navLabBackPopSubtitle => 'سحب العقدة الحالية من تكدس التنقل';

  @override
  String get navLabOpenTestDialog => 'فتح نافذة اختبار';

  @override
  String get navLabOpenTestDialogSubtitle =>
      'فتح نافذة متراكبة (زر الرجوع يجب أن يغلق النافذة)';

  @override
  String get navLabTestOverlayDialogTitle => 'نافذة اختبار متراكبة';

  @override
  String get navLabTestOverlayDialogMessage =>
      'اضغط زر الرجوع أو إغلاق. يجب أن يظل المسار الحالي نشطاً.';

  @override
  String get navLabOpenTestSheet => 'فتح ورقة اختبار';

  @override
  String get navLabOpenTestSheetSubtitle =>
      'فتح ورقة الإجراءات السريعة الجانبية';

  @override
  String get navLabTestSheetTitle => 'ورقة اختبار الإجراءات السريعة';

  @override
  String get navLabTestSheetSubtitle =>
      'اضغط زر الرجوع أو اسحب لأسفل لإغلاق الورقة';

  @override
  String get navLabSampleAction => 'إجراء عينة';

  @override
  String navLabParamTitle(String itemId) {
    return 'اختبار المعلمة (العنصر #$itemId)';
  }

  @override
  String get navLabParamSubtitle =>
      'مختبر اختبار التنقل — التحقق من المسارات المعلمية';

  @override
  String get navLabParamTelemetry => 'قياسات المعلمة';

  @override
  String get navLabParamId => 'معرف المعلمة';

  @override
  String get navLabParamActions => 'إجراءات تنقل المعلمة';

  @override
  String get navLabNavigateToItem100 => 'الانتقال إلى العنصر 100';

  @override
  String get navLabNavigateToItem200 => 'الانتقال إلى العنصر 200';

  @override
  String get navLabDestructiveTitle => 'عروض التنقل التدميري';

  @override
  String get navLabDestructiveSubtitle =>
      'للعرض فقط — يوضح استبدال التكدس (context.go) مقابل حفظ التكدس (context.push)';

  @override
  String get navLabDestructiveWarning =>
      'تحذير: العمليات في هذا القسم تقوم بإعادة تعيين التكدس أو استبدال الفروع بشكل متعمد. التنقل العادي لميزات الأعمال يجب ألا يستخدم هذه الإجراءات.';

  @override
  String get navLabStackReplacementDemos => 'عروض استبدال التكدس';

  @override
  String get navLabReplaceA11 =>
      'استبدال: context.go(\"/dev/navigation/a/a1/a1-1\")';

  @override
  String get navLabReplaceA11Subtitle =>
      'يستبدل التكدس الحالي مباشرة بالعقدة A1.1 (تدميري)';

  @override
  String get navLabResetLab => 'إعادة تعيين: context.go(\"/dev/navigation\")';

  @override
  String get navLabResetLabSubtitle =>
      'يعيد تعيين التكدس إلى جذر مختبر الاختبار (تدميري)';

  @override
  String get navLabPreserveA11 =>
      'حفظ: context.push(\"/dev/navigation/a/a1/a1-1\")';

  @override
  String get navLabPreserveA11Subtitle =>
      'يدفع العقدة A1.1 فوق التكدس الحالي (يحفظ التكدس)';
}
