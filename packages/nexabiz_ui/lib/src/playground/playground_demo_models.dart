import 'package:flutter/foundation.dart';

/// Status enum for demo records.
enum DemoVoucherStatus {
  draft,
  pending,
  posted,
  voided;

  String get labelEn => switch (this) {
    DemoVoucherStatus.draft => 'Draft',
    DemoVoucherStatus.pending => 'Pending Approval',
    DemoVoucherStatus.posted => 'Posted',
    DemoVoucherStatus.voided => 'Void',
  };

  String get labelAr => switch (this) {
    DemoVoucherStatus.draft => 'مسودة',
    DemoVoucherStatus.pending => 'قيد الاعتماد',
    DemoVoucherStatus.posted => 'مرحل',
    DemoVoucherStatus.voided => 'ملغى',
  };
}

/// Domain-neutral Demo Voucher record for mobile list and detail presentation.
@immutable
class DemoVoucherItem {
  const DemoVoucherItem({
    required this.id,
    required this.referenceNumber,
    required this.date,
    required this.titleEn,
    required this.titleAr,
    required this.subtitleEn,
    required this.subtitleAr,
    required this.amount,
    required this.currency,
    required this.status,
    required this.branchEn,
    required this.branchAr,
    this.notesEn,
    this.notesAr,
  });

  final String id;
  final String referenceNumber;
  final String date;
  final String titleEn;
  final String titleAr;
  final String subtitleEn;
  final String subtitleAr;
  final double amount;
  final String currency;
  final DemoVoucherStatus status;
  final String branchEn;
  final String branchAr;
  final String? notesEn;
  final String? notesAr;

  String title(bool isArabic) => isArabic ? titleAr : titleEn;
  String subtitle(bool isArabic) => isArabic ? subtitleAr : subtitleEn;
  String branch(bool isArabic) => isArabic ? branchAr : branchEn;
  String statusLabel(bool isArabic) =>
      isArabic ? status.labelAr : status.labelEn;
}

/// Demo Journal Entry Line item for the mobile line editor demonstration.
@immutable
class DemoJournalLine {
  const DemoJournalLine({
    required this.id,
    required this.accountCode,
    required this.accountNameEn,
    required this.accountNameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.debit,
    required this.credit,
  });

  final String id;
  final String accountCode;
  final String accountNameEn;
  final String accountNameAr;
  final String descriptionEn;
  final String descriptionAr;
  final double debit;
  final double credit;

  String accountName(bool isArabic) => isArabic ? accountNameAr : accountNameEn;
  String description(bool isArabic) => isArabic ? descriptionAr : descriptionEn;

  DemoJournalLine copyWith({
    String? id,
    String? accountCode,
    String? accountNameEn,
    String? accountNameAr,
    String? descriptionEn,
    String? descriptionAr,
    double? debit,
    double? credit,
  }) {
    return DemoJournalLine(
      id: id ?? this.id,
      accountCode: accountCode ?? this.accountCode,
      accountNameEn: accountNameEn ?? this.accountNameEn,
      accountNameAr: accountNameAr ?? this.accountNameAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
    );
  }
}

/// Demo Company representation for the mobile company switcher.
@immutable
class DemoCompanyItem {
  const DemoCompanyItem({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.branchEn,
    required this.branchAr,
    required this.currency,
    required this.code,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String branchEn;
  final String branchAr;
  final String currency;
  final String code;

  String name(bool isArabic) => isArabic ? nameAr : nameEn;
  String branch(bool isArabic) => isArabic ? branchAr : branchEn;
}

/// Demo Account entity for searchable sheet selection.
@immutable
class DemoAccountOption {
  const DemoAccountOption({
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.categoryEn,
    required this.categoryAr,
  });

  final String code;
  final String nameEn;
  final String nameAr;
  final String categoryEn;
  final String categoryAr;

  String name(bool isArabic) => isArabic ? nameAr : nameEn;
  String category(bool isArabic) => isArabic ? categoryAr : categoryEn;
}

/// Playground mock fixtures catalog.
abstract class PlaygroundFixtures {
  static const List<DemoCompanyItem> companies = [
    DemoCompanyItem(
      id: 'comp-01',
      nameEn: 'NexaBiz Holding Group',
      nameAr: 'مجموعة نكسا بيز القابضة',
      branchEn: 'Main Headquarters — Riyadh',
      branchAr: 'المقر الرئيسي — الرياض',
      currency: 'SAR',
      code: 'NB-HQ',
    ),
    DemoCompanyItem(
      id: 'comp-02',
      nameEn: 'Al-Madina Trading LLC',
      nameAr: 'شركة المدينة للتجارة ذ.م.م',
      branchEn: 'Western Region Branch — Jeddah',
      branchAr: 'فرع المنطقة الغربية — جدة',
      currency: 'SAR',
      code: 'MDT-JED',
    ),
    DemoCompanyItem(
      id: 'comp-03',
      nameEn: 'Global Logistics Solutions',
      nameAr: 'حلول اللوجستيات العالمية',
      branchEn: 'Eastern Port Branch — Dammam',
      branchAr: 'فرع الميناء الشرقي — الدمام',
      currency: 'USD',
      code: 'GLS-DMM',
    ),
  ];

  static const List<DemoAccountOption> accounts = [
    DemoAccountOption(
      code: '101001',
      nameEn: 'Main Cash Vault',
      nameAr: 'خزينة النقدية الرئيسية',
      categoryEn: 'Current Assets',
      categoryAr: 'أصول متداولة',
    ),
    DemoAccountOption(
      code: '101002',
      nameEn: 'Petty Cash — Operations',
      nameAr: 'عهدة نقدية — العمليات',
      categoryEn: 'Current Assets',
      categoryAr: 'أصول متداولة',
    ),
    DemoAccountOption(
      code: '102001',
      nameEn: 'Al-Rajhi Bank — SAR Account',
      nameAr: 'مصرف الراجحي — حساب الريال',
      categoryEn: 'Cash & Banks',
      categoryAr: 'نقدية وبنوك',
    ),
    DemoAccountOption(
      code: '102002',
      nameEn: 'SNB Bank — USD Operating',
      nameAr: 'البنك الأهلي — حساب الدولار',
      categoryEn: 'Cash & Banks',
      categoryAr: 'نقدية وبنوك',
    ),
    DemoAccountOption(
      code: '103001',
      nameEn: 'Accounts Receivable — Trade',
      nameAr: 'العملاء والمدينون التجاريون',
      categoryEn: 'Receivables',
      categoryAr: 'مدينون',
    ),
    DemoAccountOption(
      code: '104001',
      nameEn: 'Inventory — Finished Goods',
      nameAr: 'مخزون البضائع التامة',
      categoryEn: 'Inventory',
      categoryAr: 'مخزون',
    ),
    DemoAccountOption(
      code: '201001',
      nameEn: 'Accounts Payable — Trade',
      nameAr: 'الموردون والدائنون التجاريون',
      categoryEn: 'Current Liabilities',
      categoryAr: 'التزامات متداولة',
    ),
    DemoAccountOption(
      code: '202001',
      nameEn: 'Accrued VAT Payable (15%)',
      nameAr: 'ضريبة القيمة المضافة المستحقة (15%)',
      categoryEn: 'Liabilities',
      categoryAr: 'التزامات',
    ),
    DemoAccountOption(
      code: '301001',
      nameEn: 'Paid-in Share Capital',
      nameAr: 'رأس المال المدفوع',
      categoryEn: 'Equity',
      categoryAr: 'حقوق الملكية',
    ),
    DemoAccountOption(
      code: '401001',
      nameEn: 'Commercial Wholesale Revenue',
      nameAr: 'إيرادات المبيعات التجارية بالجملة',
      categoryEn: 'Revenue',
      categoryAr: 'إيرادات',
    ),
    DemoAccountOption(
      code: '501001',
      nameEn: 'Cost of Goods Sold',
      nameAr: 'تكلفة البضاعة المباعة',
      categoryEn: 'Direct Cost',
      categoryAr: 'تكاليف مباشرة',
    ),
    DemoAccountOption(
      code: '502001',
      nameEn: 'Office Rent & Facilities',
      nameAr: 'إيجار المكاتب والمرافق',
      categoryEn: 'Operating Expenses',
      categoryAr: 'مصروفات تشغيلية',
    ),
  ];

  static const List<DemoVoucherItem> vouchers = [
    DemoVoucherItem(
      id: 'VOUCH-01',
      referenceNumber: 'JV-2026-00142',
      date: '15 Sep 2026',
      titleEn: 'Monthly Office Utility & Facility Payment',
      titleAr: 'سداد فواتير الخدمات والمرافق الشهرية',
      subtitleEn: 'Al-Rajhi Bank • Vendor Services',
      subtitleAr: 'مصرف الراجحي • خدمات الموردين',
      amount: 12500.00,
      currency: 'USD',
      status: DemoVoucherStatus.posted,
      branchEn: 'Main HQ',
      branchAr: 'الفرع الرئيسي',
      notesEn: 'Approved by Financial Controller under Q3 Facilities Budget.',
      notesAr: 'معتمد من المدير المالي ضمن ميزانية مرافق الربع الثالث.',
    ),
    DemoVoucherItem(
      id: 'VOUCH-02',
      referenceNumber: 'JV-2026-00143',
      date: '18 Sep 2026',
      titleEn:
          'Opening Balance Inventory Settlement and Adjustments for Central Warehouse Logistics',
      titleAr:
          'سند قيد افتتاحي لتسوية بضاعة أول المدة لمستودع العمليات اللوجستية الرئيسي',
      subtitleEn: 'Inter-warehouse transfer • Stock Adjustment',
      subtitleAr: 'تحويل بين المستودعات • تسوية جردية',
      amount: 145289320.50,
      currency: 'SAR',
      status: DemoVoucherStatus.posted,
      branchEn: 'Central Logistics Hub',
      branchAr: 'مركز الإمداد اللوجستي',
      notesEn:
          'Consolidated physical inventory count audit variance reconciliations.',
      notesAr: 'تسوية فروقات الجرد الفعلي الميداني المعتمدة.',
    ),
    DemoVoucherItem(
      id: 'VOUCH-03',
      referenceNumber: 'JV-2026-00144',
      date: '19 Sep 2026',
      titleEn: 'Customer Credit Note Return & Sales Tax Adjustment',
      titleAr: 'إشعار دائن لمرتجع عميل وتسوية ضريبة القيمة المضافة',
      subtitleEn: 'Trade Customer Accounts • Sales Reversal',
      subtitleAr: 'حسابات العملاء التجاريين • تسوية مبيعات',
      amount: -4820.00,
      currency: 'SAR',
      status: DemoVoucherStatus.pending,
      branchEn: 'Jeddah Regional Branch',
      branchAr: 'فرع جدة الإقليمي',
      notesEn: 'Pending quality inspection confirmation before final refund.',
      notesAr: 'بانتظار تأكيد تقرير فحص الجودة قبل اعتماد الصرف.',
    ),
    DemoVoucherItem(
      id: 'VOUCH-04',
      referenceNumber: 'JV-2026-00145',
      date: '20 Sep 2026',
      titleEn: 'Foreign Currency Revaluation and Exchange Variance Settlement',
      titleAr: 'إعادة تقييم فروقات العملات الأجنبية وأسعار الصرف',
      subtitleEn: 'Treasury & FX Reserve • Month End',
      subtitleAr: 'الخزينة واحتياطي الصرف • إقفال دوري',
      amount: 67340.25,
      currency: 'USD',
      status: DemoVoucherStatus.draft,
      branchEn: 'Treasury Division',
      branchAr: 'إدارة الخزينة والاستثمار',
      notesEn: 'Preliminary calculation based on central bank fixing rate.',
      notesAr: 'احتساب أولي استناداً لمتوسط أسعار البنك المركزي.',
    ),
    DemoVoucherItem(
      id: 'VOUCH-05',
      referenceNumber: 'JV-2026-00146',
      date: '20 Sep 2026',
      titleEn: 'Cancelled Supplier Advance Prepayment Request',
      titleAr: 'طلب دفعة مقدمة لمورد تم إلغاؤه',
      subtitleEn: 'Procurement • Cancelled Contract',
      subtitleAr: 'المشتريات • عقد ملغى',
      amount: 25000.00,
      currency: 'SAR',
      status: DemoVoucherStatus.voided,
      branchEn: 'Procurement Dept',
      branchAr: 'قسم المشتريات',
      notesEn: 'Cancelled by procurement manager due to non-delivery terms.',
      notesAr: 'أُلغي بواسطة مدير المشتريات لعدم استيفاء شروط التوريد.',
    ),
  ];

  static const List<DemoJournalLine> initialLines = [
    DemoJournalLine(
      id: 'line-01',
      accountCode: '101001',
      accountNameEn: 'Main Cash Vault',
      accountNameAr: 'خزينة النقدية الرئيسية',
      descriptionEn: 'Receipt from daily cash collections',
      descriptionAr: 'متحصلات نقدية من التحصيل اليومي',
      debit: 15000.00,
      credit: 0.00,
    ),
    DemoJournalLine(
      id: 'line-02',
      accountCode: '401001',
      accountNameEn: 'Commercial Wholesale Revenue',
      accountNameAr: 'إيرادات المبيعات التجارية بالجملة',
      descriptionEn: 'Invoice INV-2026-884 sales recognized',
      descriptionAr: 'إثبات مبيعات فاتورة رقم INV-2026-884',
      debit: 0.00,
      credit: 13043.48,
    ),
    DemoJournalLine(
      id: 'line-03',
      accountCode: '202001',
      accountNameEn: 'Accrued VAT Payable (15%)',
      accountNameAr: 'ضريبة القيمة المضافة المستحقة (15%)',
      descriptionEn: '15% Standard Output Tax on Sales',
      descriptionAr: 'ضريبة المخرجات 15% على المبيعات',
      debit: 0.00,
      credit: 1956.52,
    ),
  ];
}
