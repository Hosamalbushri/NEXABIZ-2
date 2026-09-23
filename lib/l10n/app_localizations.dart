import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'NexaBiz ERP'**
  String get appName;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'NexaBiz ERP'**
  String get splashTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Initializing secure business platform...'**
  String get splashSubtitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get navServices;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @quickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActionsTitle;

  /// No description provided for @quickActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Execute common business operations & developer tools'**
  String get quickActionsSubtitle;

  /// No description provided for @quickActionMobilePlayground.
  ///
  /// In en, this message translates to:
  /// **'Mobile UI Playground'**
  String get quickActionMobilePlayground;

  /// No description provided for @quickActionMobilePlaygroundDesc.
  ///
  /// In en, this message translates to:
  /// **'Audit patterns & mobile ERP scenarios'**
  String get quickActionMobilePlaygroundDesc;

  /// No description provided for @dashboardMobilePlaygroundCta.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get dashboardMobilePlaygroundCta;

  /// No description provided for @dashboardMobilePlaygroundBadge.
  ///
  /// In en, this message translates to:
  /// **'UI-01'**
  String get dashboardMobilePlaygroundBadge;

  /// No description provided for @quickActionComponentGallery.
  ///
  /// In en, this message translates to:
  /// **'Component Gallery'**
  String get quickActionComponentGallery;

  /// No description provided for @quickActionComponentGalleryDesc.
  ///
  /// In en, this message translates to:
  /// **'UI gallery & component playground'**
  String get quickActionComponentGalleryDesc;

  /// No description provided for @quickActionNewInvoice.
  ///
  /// In en, this message translates to:
  /// **'New Invoice'**
  String get quickActionNewInvoice;

  /// No description provided for @quickActionNewInvoiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Create sales invoice'**
  String get quickActionNewInvoiceDesc;

  /// No description provided for @quickActionNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get quickActionNewCustomer;

  /// No description provided for @quickActionNewCustomerDesc.
  ///
  /// In en, this message translates to:
  /// **'Register customer account'**
  String get quickActionNewCustomerDesc;

  /// No description provided for @quickActionAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get quickActionAddProduct;

  /// No description provided for @quickActionAddProductDesc.
  ///
  /// In en, this message translates to:
  /// **'Inventory item entry'**
  String get quickActionAddProductDesc;

  /// No description provided for @exitDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Application'**
  String get exitDialogTitle;

  /// No description provided for @exitDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit NexaBiz ERP?'**
  String get exitDialogMessage;

  /// No description provided for @actionExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get actionExit;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionClearLog.
  ///
  /// In en, this message translates to:
  /// **'Clear Log'**
  String get actionClearLog;

  /// No description provided for @actionSystemReady.
  ///
  /// In en, this message translates to:
  /// **'System Ready'**
  String get actionSystemReady;

  /// No description provided for @actionDocumentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get actionDocumentation;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'NexaBiz Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to NexaBiz ERP'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardEnterpriseHighlights.
  ///
  /// In en, this message translates to:
  /// **'Enterprise Highlights'**
  String get dashboardEnterpriseHighlights;

  /// No description provided for @dashboardHighlight1Title.
  ///
  /// In en, this message translates to:
  /// **'Q3 Financial Revenue Peak'**
  String get dashboardHighlight1Title;

  /// No description provided for @dashboardHighlight1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sales target exceeded by +14.2% with \$124,500.00 total volume.'**
  String get dashboardHighlight1Subtitle;

  /// No description provided for @dashboardHighlight1Badge.
  ///
  /// In en, this message translates to:
  /// **'Financial Highlight'**
  String get dashboardHighlight1Badge;

  /// No description provided for @dashboardHighlight2Title.
  ///
  /// In en, this message translates to:
  /// **'Inventory Reorder Alert'**
  String get dashboardHighlight2Title;

  /// No description provided for @dashboardHighlight2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'18 active purchase orders in transit across main warehouses.'**
  String get dashboardHighlight2Subtitle;

  /// No description provided for @dashboardHighlight2Badge.
  ///
  /// In en, this message translates to:
  /// **'Supply Chain'**
  String get dashboardHighlight2Badge;

  /// No description provided for @dashboardHighlight3Title.
  ///
  /// In en, this message translates to:
  /// **'Automated Voucher Sync'**
  String get dashboardHighlight3Title;

  /// No description provided for @dashboardHighlight3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'All real-time receipt & payment voucher ledgers fully synchronized.'**
  String get dashboardHighlight3Subtitle;

  /// No description provided for @dashboardHighlight3Badge.
  ///
  /// In en, this message translates to:
  /// **'Real-time Ledger'**
  String get dashboardHighlight3Badge;

  /// No description provided for @dashboardArchitectureActive.
  ///
  /// In en, this message translates to:
  /// **'Modular Clean Architecture Active'**
  String get dashboardArchitectureActive;

  /// No description provided for @dashboardArchitectureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'System operational • Real-time capability synchronization enabled'**
  String get dashboardArchitectureSubtitle;

  /// No description provided for @statusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get statusOnline;

  /// No description provided for @statusStandby.
  ///
  /// In en, this message translates to:
  /// **'Standby'**
  String get statusStandby;

  /// No description provided for @statusSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get statusSynced;

  /// No description provided for @statusPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get statusPrimary;

  /// No description provided for @kpiTotalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get kpiTotalSales;

  /// No description provided for @kpiTotalSalesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'+12.5% this month'**
  String get kpiTotalSalesSubtitle;

  /// No description provided for @kpiPurchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get kpiPurchases;

  /// No description provided for @kpiPurchasesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'18 active POs'**
  String get kpiPurchasesSubtitle;

  /// No description provided for @kpiReceivables.
  ///
  /// In en, this message translates to:
  /// **'Receivables'**
  String get kpiReceivables;

  /// No description provided for @kpiReceivablesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'4 pending invoices'**
  String get kpiReceivablesSubtitle;

  /// No description provided for @kpiStockValuation.
  ///
  /// In en, this message translates to:
  /// **'Stock Valuation'**
  String get kpiStockValuation;

  /// No description provided for @kpiStockValuationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'1,240 inventory items'**
  String get kpiStockValuationSubtitle;

  /// No description provided for @recentActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivityTitle;

  /// No description provided for @recentActivityItem1Title.
  ///
  /// In en, this message translates to:
  /// **'Sales Invoice #INV-2026-0042'**
  String get recentActivityItem1Title;

  /// No description provided for @recentActivityItem1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Customer: Acma Trading Co. • \$3,450.00'**
  String get recentActivityItem1Subtitle;

  /// No description provided for @recentActivityItem1Time.
  ///
  /// In en, this message translates to:
  /// **'10 mins ago'**
  String get recentActivityItem1Time;

  /// No description provided for @recentActivityItem2Title.
  ///
  /// In en, this message translates to:
  /// **'Stock Transfer #TR-902'**
  String get recentActivityItem2Title;

  /// No description provided for @recentActivityItem2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Main Warehouse → Retail Branch B'**
  String get recentActivityItem2Subtitle;

  /// No description provided for @recentActivityItem2Time.
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get recentActivityItem2Time;

  /// No description provided for @recentActivityItem3Title.
  ///
  /// In en, this message translates to:
  /// **'Receipt Voucher #RCV-1021'**
  String get recentActivityItem3Title;

  /// No description provided for @recentActivityItem3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Payment received for #INV-2026-0019'**
  String get recentActivityItem3Subtitle;

  /// No description provided for @recentActivityItem3Time.
  ///
  /// In en, this message translates to:
  /// **'3 hours ago'**
  String get recentActivityItem3Time;

  /// No description provided for @servicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Services Hub'**
  String get servicesTitle;

  /// No description provided for @servicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Available Business Capabilities & Service Launchers'**
  String get servicesSubtitle;

  /// No description provided for @servicesDevSection.
  ///
  /// In en, this message translates to:
  /// **'System & Developer Tools'**
  String get servicesDevSection;

  /// No description provided for @servicesDevSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'UI design system and component playground'**
  String get servicesDevSectionSubtitle;

  /// No description provided for @servicesComponentGallerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Interactive shadcn_flutter playground'**
  String get servicesComponentGallerySubtitle;

  /// No description provided for @servicesMobilePlaygroundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Interactive ERP mobile scenarios & design audit'**
  String get servicesMobilePlaygroundSubtitle;

  /// No description provided for @servicesFinancialSection.
  ///
  /// In en, this message translates to:
  /// **'Financial & Accounting'**
  String get servicesFinancialSection;

  /// No description provided for @servicesFinancialSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Core financial management tools'**
  String get servicesFinancialSectionSubtitle;

  /// No description provided for @servicesGeneralLedger.
  ///
  /// In en, this message translates to:
  /// **'General Ledger'**
  String get servicesGeneralLedger;

  /// No description provided for @servicesGeneralLedgerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Journal entries & COA'**
  String get servicesGeneralLedgerSubtitle;

  /// No description provided for @servicesTreasuryCash.
  ///
  /// In en, this message translates to:
  /// **'Treasury & Cash'**
  String get servicesTreasuryCash;

  /// No description provided for @servicesTreasuryCashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bank accounts & cash flow'**
  String get servicesTreasuryCashSubtitle;

  /// No description provided for @servicesVoucherBooks.
  ///
  /// In en, this message translates to:
  /// **'Voucher Books'**
  String get servicesVoucherBooks;

  /// No description provided for @servicesVoucherBooksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Document numbering & books'**
  String get servicesVoucherBooksSubtitle;

  /// No description provided for @servicesTaxVat.
  ///
  /// In en, this message translates to:
  /// **'Tax & VAT'**
  String get servicesTaxVat;

  /// No description provided for @servicesTaxVatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tax rates & reporting'**
  String get servicesTaxVatSubtitle;

  /// No description provided for @servicesSupplyChainSection.
  ///
  /// In en, this message translates to:
  /// **'Supply Chain & Commerce'**
  String get servicesSupplyChainSection;

  /// No description provided for @servicesSupplyChainSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory valuation, purchasing, & sales operations'**
  String get servicesSupplyChainSectionSubtitle;

  /// No description provided for @servicesInventoryWarehouses.
  ///
  /// In en, this message translates to:
  /// **'Inventory & Warehouses'**
  String get servicesInventoryWarehouses;

  /// No description provided for @servicesInventoryWarehousesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stock balances & transfers'**
  String get servicesInventoryWarehousesSubtitle;

  /// No description provided for @servicesSalesBilling.
  ///
  /// In en, this message translates to:
  /// **'Sales & Billing'**
  String get servicesSalesBilling;

  /// No description provided for @servicesSalesBillingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invoices, orders & customers'**
  String get servicesSalesBillingSubtitle;

  /// No description provided for @servicesPurchasingPOs.
  ///
  /// In en, this message translates to:
  /// **'Purchasing & POs'**
  String get servicesPurchasingPOs;

  /// No description provided for @servicesPurchasingPOSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase orders & suppliers'**
  String get servicesPurchasingPOSubtitle;

  /// No description provided for @servicesLogisticsShipping.
  ///
  /// In en, this message translates to:
  /// **'Logistics & Shipping'**
  String get servicesLogisticsShipping;

  /// No description provided for @servicesLogisticsShippingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment tracking & dispatch'**
  String get servicesLogisticsShippingSubtitle;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports Hub'**
  String get reportsTitle;

  /// No description provided for @reportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Financial, Operational, & Analytical Reports'**
  String get reportsSubtitle;

  /// No description provided for @reportsEngineStatus.
  ///
  /// In en, this message translates to:
  /// **'Engine Status'**
  String get reportsEngineStatus;

  /// No description provided for @reportsEngineStatusBody.
  ///
  /// In en, this message translates to:
  /// **'Reporting Engine Integration Standby • Clean data adapters ready'**
  String get reportsEngineStatusBody;

  /// No description provided for @reportsFinancialReports.
  ///
  /// In en, this message translates to:
  /// **'Financial Reports'**
  String get reportsFinancialReports;

  /// No description provided for @reportsTrialBalance.
  ///
  /// In en, this message translates to:
  /// **'Trial Balance'**
  String get reportsTrialBalance;

  /// No description provided for @reportsTrialBalanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Debit/Credit summaries'**
  String get reportsTrialBalanceSubtitle;

  /// No description provided for @reportsBalanceSheet.
  ///
  /// In en, this message translates to:
  /// **'Balance Sheet'**
  String get reportsBalanceSheet;

  /// No description provided for @reportsBalanceSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assets & Liabilities'**
  String get reportsBalanceSheetSubtitle;

  /// No description provided for @reportsProfitLoss.
  ///
  /// In en, this message translates to:
  /// **'Profit & Loss'**
  String get reportsProfitLoss;

  /// No description provided for @reportsProfitLossSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expense'**
  String get reportsProfitLossSubtitle;

  /// No description provided for @reportsGLAudit.
  ///
  /// In en, this message translates to:
  /// **'General Ledger Audit'**
  String get reportsGLAudit;

  /// No description provided for @reportsGLAuditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Journal verification'**
  String get reportsGLAuditSubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & Configuration'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Application preferences and enterprise profile management'**
  String get settingsSubtitle;

  /// No description provided for @settingsDevToolsSection.
  ///
  /// In en, this message translates to:
  /// **'Developer & Design System Tools'**
  String get settingsDevToolsSection;

  /// No description provided for @settingsNavTestLab.
  ///
  /// In en, this message translates to:
  /// **'Navigation Test Lab'**
  String get settingsNavTestLab;

  /// No description provided for @settingsNavTestLabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manual deep-navigation, branch, overlay & parameter test lab'**
  String get settingsNavTestLabSubtitle;

  /// No description provided for @settingsGallery.
  ///
  /// In en, this message translates to:
  /// **'UI Component Gallery & Playground'**
  String get settingsGallery;

  /// No description provided for @settingsGallerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Interactive shadcn_flutter component showcase & test environment'**
  String get settingsGallerySubtitle;

  /// No description provided for @settingsAppPreferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Application Preferences'**
  String get settingsAppPreferencesSection;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeOn.
  ///
  /// In en, this message translates to:
  /// **'Dark theme enabled'**
  String get settingsDarkModeOn;

  /// No description provided for @settingsDarkModeOff.
  ///
  /// In en, this message translates to:
  /// **'Light theme enabled'**
  String get settingsDarkModeOff;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language & Localization'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Application Language'**
  String get settingsLanguageSelectTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageEnglishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get languageEnglishSubtitle;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageArabicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'العربية (المملكة العربية السعودية)'**
  String get languageArabicSubtitle;

  /// No description provided for @settingsCompanyProfileSection.
  ///
  /// In en, this message translates to:
  /// **'Company & Currency Profile'**
  String get settingsCompanyProfileSection;

  /// No description provided for @settingsCompanyProfile.
  ///
  /// In en, this message translates to:
  /// **'Company Profile'**
  String get settingsCompanyProfile;

  /// No description provided for @settingsCompanyProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'NexaBiz Enterprise Corp.'**
  String get settingsCompanyProfileSubtitle;

  /// No description provided for @settingsFunctionalCurrency.
  ///
  /// In en, this message translates to:
  /// **'Functional Currency'**
  String get settingsFunctionalCurrency;

  /// No description provided for @settingsFunctionalCurrencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'USD - United States Dollar'**
  String get settingsFunctionalCurrencySubtitle;

  /// No description provided for @settingsSecuritySyncSection.
  ///
  /// In en, this message translates to:
  /// **'Security & Sync'**
  String get settingsSecuritySyncSection;

  /// No description provided for @settingsSecurityControls.
  ///
  /// In en, this message translates to:
  /// **'Security & Access Controls'**
  String get settingsSecurityControls;

  /// No description provided for @settingsSecurityControlsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage user roles and capability permissions'**
  String get settingsSecurityControlsSubtitle;

  /// No description provided for @settingsOfflineSync.
  ///
  /// In en, this message translates to:
  /// **'Offline Sync & Storage'**
  String get settingsOfflineSync;

  /// No description provided for @settingsOfflineSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All local databases up to date'**
  String get settingsOfflineSyncSubtitle;

  /// No description provided for @demoTitle.
  ///
  /// In en, this message translates to:
  /// **'NexaBiz Demo Capability'**
  String get demoTitle;

  /// No description provided for @demoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verified clean architecture capability registration & shadcn_flutter integration'**
  String get demoSubtitle;

  /// No description provided for @demoBadge.
  ///
  /// In en, this message translates to:
  /// **'Capability Architecture Verified'**
  String get demoBadge;

  /// No description provided for @demoDescription.
  ///
  /// In en, this message translates to:
  /// **'This capability exists to prove capability registration, topological sorting, navigation registry resolution, GoRouter infrastructure adaptation, and canonical NexaBiz UI design system integration.'**
  String get demoDescription;

  /// No description provided for @demoArchPrinciples.
  ///
  /// In en, this message translates to:
  /// **'Architecture Principles'**
  String get demoArchPrinciples;

  /// No description provided for @demoArchPrinciplesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clean Modular / Ports & Adapters'**
  String get demoArchPrinciplesSubtitle;

  /// No description provided for @demoArchPrinciple1.
  ///
  /// In en, this message translates to:
  /// **'• Capability is the runtime application unit.'**
  String get demoArchPrinciple1;

  /// No description provided for @demoArchPrinciple2.
  ///
  /// In en, this message translates to:
  /// **'• Package is the physical implementation boundary.'**
  String get demoArchPrinciple2;

  /// No description provided for @demoArchPrinciple3.
  ///
  /// In en, this message translates to:
  /// **'• Navigation is declared by capabilities.'**
  String get demoArchPrinciple3;

  /// No description provided for @demoArchPrinciple4.
  ///
  /// In en, this message translates to:
  /// **'• GoRouter is an infrastructure adapter.'**
  String get demoArchPrinciple4;

  /// No description provided for @demoArchPrinciple5.
  ///
  /// In en, this message translates to:
  /// **'• UI components come from canonical NexaBiz UI package.'**
  String get demoArchPrinciple5;

  /// No description provided for @navLabTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation Test Lab'**
  String get navLabTitle;

  /// No description provided for @navLabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Production Navigation Hardening & Manual Deep-Stack Test Environment'**
  String get navLabSubtitle;

  /// No description provided for @navLabBadge.
  ///
  /// In en, this message translates to:
  /// **'Dev Lab'**
  String get navLabBadge;

  /// No description provided for @navLabTelemetryLabRoot.
  ///
  /// In en, this message translates to:
  /// **'Lab Root'**
  String get navLabTelemetryLabRoot;

  /// No description provided for @navLabTelemetryTargetRouter.
  ///
  /// In en, this message translates to:
  /// **'Target Router'**
  String get navLabTelemetryTargetRouter;

  /// No description provided for @navLabTelemetryRootScope.
  ///
  /// In en, this message translates to:
  /// **'Root Scope'**
  String get navLabTelemetryRootScope;

  /// No description provided for @navLabTelemetryStackStrategy.
  ///
  /// In en, this message translates to:
  /// **'Stack Strategy'**
  String get navLabTelemetryStackStrategy;

  /// No description provided for @navLabBranchLaunchersSection.
  ///
  /// In en, this message translates to:
  /// **'BRANCH TEST LAUNCHERS'**
  String get navLabBranchLaunchersSection;

  /// No description provided for @navLabBranchATitle.
  ///
  /// In en, this message translates to:
  /// **'Branch A (4-Level Linear & Sibling Test)'**
  String get navLabBranchATitle;

  /// No description provided for @navLabBranchBTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch B (Deep Alternate Branch)'**
  String get navLabBranchBTitle;

  /// No description provided for @navLabBranchCTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch C (Independent Route Shape)'**
  String get navLabBranchCTitle;

  /// No description provided for @navLabBranchParamTitle.
  ///
  /// In en, this message translates to:
  /// **'Parameterized Routes'**
  String get navLabBranchParamTitle;

  /// No description provided for @navLabBranchDestructiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Destructive Navigation Demos'**
  String get navLabBranchDestructiveTitle;

  /// No description provided for @navLabManualInstructionsSection.
  ///
  /// In en, this message translates to:
  /// **'MANUAL TEST INSTRUCTIONS'**
  String get navLabManualInstructionsSection;

  /// No description provided for @navLabEventLogSection.
  ///
  /// In en, this message translates to:
  /// **'NAVIGATION EVENT LOG'**
  String get navLabEventLogSection;

  /// No description provided for @navLabRecentTelemetryEvents.
  ///
  /// In en, this message translates to:
  /// **'Recent Telemetry Events'**
  String get navLabRecentTelemetryEvents;

  /// No description provided for @navLabNoEventsLogged.
  ///
  /// In en, this message translates to:
  /// **'No navigation events logged yet. Tap a branch launcher above.'**
  String get navLabNoEventsLogged;

  /// No description provided for @navLabNodeTelemetry.
  ///
  /// In en, this message translates to:
  /// **'CURRENT ROUTE TELEMETRY'**
  String get navLabNodeTelemetry;

  /// No description provided for @navLabNodeName.
  ///
  /// In en, this message translates to:
  /// **'Node Name'**
  String get navLabNodeName;

  /// No description provided for @navLabRoutePath.
  ///
  /// In en, this message translates to:
  /// **'Route Path'**
  String get navLabRoutePath;

  /// No description provided for @navLabParentRoute.
  ///
  /// In en, this message translates to:
  /// **'Parent Route'**
  String get navLabParentRoute;

  /// No description provided for @navLabStackDepth.
  ///
  /// In en, this message translates to:
  /// **'Stack Depth'**
  String get navLabStackDepth;

  /// No description provided for @navLabBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get navLabBranch;

  /// No description provided for @navLabChildNavigationPush.
  ///
  /// In en, this message translates to:
  /// **'CHILD NAVIGATION (PUSH)'**
  String get navLabChildNavigationPush;

  /// No description provided for @navLabTestControls.
  ///
  /// In en, this message translates to:
  /// **'TEST CONTROLS'**
  String get navLabTestControls;

  /// No description provided for @navLabBackPop.
  ///
  /// In en, this message translates to:
  /// **'Back (POP)'**
  String get navLabBackPop;

  /// No description provided for @navLabBackPopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pops current node off navigation stack'**
  String get navLabBackPopSubtitle;

  /// No description provided for @navLabOpenTestDialog.
  ///
  /// In en, this message translates to:
  /// **'Open Test Dialog'**
  String get navLabOpenTestDialog;

  /// No description provided for @navLabOpenTestDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Opens modal overlay dialog (System Back must close dialog)'**
  String get navLabOpenTestDialogSubtitle;

  /// No description provided for @navLabTestOverlayDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Overlay Dialog'**
  String get navLabTestOverlayDialogTitle;

  /// No description provided for @navLabTestOverlayDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Press Android Back or tap Close. Current route must remain active.'**
  String get navLabTestOverlayDialogMessage;

  /// No description provided for @navLabOpenTestSheet.
  ///
  /// In en, this message translates to:
  /// **'Open Test Sheet'**
  String get navLabOpenTestSheet;

  /// No description provided for @navLabOpenTestSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Opens Quick Actions slide-over sheet'**
  String get navLabOpenTestSheetSubtitle;

  /// No description provided for @navLabTestSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Quick Actions Sheet'**
  String get navLabTestSheetTitle;

  /// No description provided for @navLabTestSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Press Android Back or swipe down to close sheet'**
  String get navLabTestSheetSubtitle;

  /// No description provided for @navLabSampleAction.
  ///
  /// In en, this message translates to:
  /// **'Sample Action'**
  String get navLabSampleAction;

  /// No description provided for @navLabParamTitle.
  ///
  /// In en, this message translates to:
  /// **'Parameter Test (Item #{itemId})'**
  String navLabParamTitle(String itemId);

  /// No description provided for @navLabParamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation Test Lab — Parameterized Route Verification'**
  String get navLabParamSubtitle;

  /// No description provided for @navLabParamTelemetry.
  ///
  /// In en, this message translates to:
  /// **'PARAMETER TELEMETRY'**
  String get navLabParamTelemetry;

  /// No description provided for @navLabParamId.
  ///
  /// In en, this message translates to:
  /// **'Parameter ID'**
  String get navLabParamId;

  /// No description provided for @navLabParamActions.
  ///
  /// In en, this message translates to:
  /// **'PARAMETER NAVIGATION ACTIONS'**
  String get navLabParamActions;

  /// No description provided for @navLabNavigateToItem100.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Item 100'**
  String get navLabNavigateToItem100;

  /// No description provided for @navLabNavigateToItem200.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Item 200'**
  String get navLabNavigateToItem200;

  /// No description provided for @navLabDestructiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Destructive Navigation Demos'**
  String get navLabDestructiveTitle;

  /// No description provided for @navLabDestructiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'DEMO ONLY — Demonstrates stack replacement (context.go) vs stack preservation (context.push)'**
  String get navLabDestructiveSubtitle;

  /// No description provided for @navLabDestructiveWarning.
  ///
  /// In en, this message translates to:
  /// **'WARNING: Operations in this section perform intentional stack resets or branch replacements. Normal business feature navigation MUST NOT use these actions.'**
  String get navLabDestructiveWarning;

  /// No description provided for @navLabStackReplacementDemos.
  ///
  /// In en, this message translates to:
  /// **'STACK REPLACEMENT DEMOS'**
  String get navLabStackReplacementDemos;

  /// No description provided for @navLabReplaceA11.
  ///
  /// In en, this message translates to:
  /// **'REPLACE: context.go(\"/dev/navigation/a/a1/a1-1\")'**
  String get navLabReplaceA11;

  /// No description provided for @navLabReplaceA11Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Replaces current stack directly with Node A1.1 (Destructive)'**
  String get navLabReplaceA11Subtitle;

  /// No description provided for @navLabResetLab.
  ///
  /// In en, this message translates to:
  /// **'RESET: context.go(\"/dev/navigation\")'**
  String get navLabResetLab;

  /// No description provided for @navLabResetLabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Resets stack to Test Lab Dashboard root (Destructive)'**
  String get navLabResetLabSubtitle;

  /// No description provided for @navLabPreserveA11.
  ///
  /// In en, this message translates to:
  /// **'PRESERVE: context.push(\"/dev/navigation/a/a1/a1-1\")'**
  String get navLabPreserveA11;

  /// No description provided for @navLabPreserveA11Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Pushes Node A1.1 onto existing stack (Stack Preserving)'**
  String get navLabPreserveA11Subtitle;

  /// No description provided for @navLabNodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation Test Lab — Branch {branch} (Depth {depth})'**
  String navLabNodeSubtitle(String branch, String depth);

  /// No description provided for @navLabBranchBadge.
  ///
  /// In en, this message translates to:
  /// **'Branch {branch}'**
  String navLabBranchBadge(String branch);

  /// No description provided for @navLabPushPath.
  ///
  /// In en, this message translates to:
  /// **'PUSH {path}'**
  String navLabPushPath(String path);

  /// No description provided for @navLabPushBadge.
  ///
  /// In en, this message translates to:
  /// **'PUSH'**
  String get navLabPushBadge;

  /// No description provided for @navLabParamRouteBadge.
  ///
  /// In en, this message translates to:
  /// **'Param Route'**
  String get navLabParamRouteBadge;

  /// No description provided for @navLabDestructiveBadge.
  ///
  /// In en, this message translates to:
  /// **'Destructive Demos'**
  String get navLabDestructiveBadge;

  /// No description provided for @navLabReplaceBadge.
  ///
  /// In en, this message translates to:
  /// **'REPLACE'**
  String get navLabReplaceBadge;

  /// No description provided for @navLabResetBadge.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get navLabResetBadge;

  /// No description provided for @navLabNodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Node {code}'**
  String navLabNodeTitle(String code);

  /// No description provided for @navLabNodeSiblingTitle.
  ///
  /// In en, this message translates to:
  /// **'Node {code} (Sibling)'**
  String navLabNodeSiblingTitle(String code);

  /// No description provided for @navLabNodeDeepestTitle.
  ///
  /// In en, this message translates to:
  /// **'Node {code} (Deepest)'**
  String navLabNodeDeepestTitle(String code);

  /// No description provided for @navLabBranchRootTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch {branch} Root'**
  String navLabBranchRootTitle(String branch);

  /// No description provided for @navLabTargetRouterValue.
  ///
  /// In en, this message translates to:
  /// **'Production GoRouter'**
  String get navLabTargetRouterValue;

  /// No description provided for @navLabRootScopeValue.
  ///
  /// In en, this message translates to:
  /// **'AppExitPopScope'**
  String get navLabRootScopeValue;

  /// No description provided for @navLabStackStrategyValue.
  ///
  /// In en, this message translates to:
  /// **'PUSH (Stack Preserving)'**
  String get navLabStackStrategyValue;

  /// No description provided for @navLabBranchAPath.
  ///
  /// In en, this message translates to:
  /// **'Path: /dev/navigation/a -> A1 -> A1.1 -> A1.1.1'**
  String get navLabBranchAPath;

  /// No description provided for @navLabBranchBPath.
  ///
  /// In en, this message translates to:
  /// **'Path: /dev/navigation/b -> B1 -> B1.2 / B2.1'**
  String get navLabBranchBPath;

  /// No description provided for @navLabBranchCPath.
  ///
  /// In en, this message translates to:
  /// **'Path: /dev/navigation/c -> C1 -> C1.1 -> C1.1.1'**
  String get navLabBranchCPath;

  /// No description provided for @navLabParamPath.
  ///
  /// In en, this message translates to:
  /// **'Path: /dev/navigation/param/100 & 200'**
  String get navLabParamPath;

  /// No description provided for @navLabDestructiveComparison.
  ///
  /// In en, this message translates to:
  /// **'Explicit REPLACE (context.go) vs PUSH comparison'**
  String get navLabDestructiveComparison;

  /// No description provided for @navLabFourLevels.
  ///
  /// In en, this message translates to:
  /// **'4 Levels'**
  String get navLabFourLevels;

  /// No description provided for @navLabThreeLevels.
  ///
  /// In en, this message translates to:
  /// **'3 Levels'**
  String get navLabThreeLevels;

  /// No description provided for @navLabParamTestBadge.
  ///
  /// In en, this message translates to:
  /// **'Param Test'**
  String get navLabParamTestBadge;

  /// No description provided for @navLabDemoOnlyBadge.
  ///
  /// In en, this message translates to:
  /// **'Demo Only'**
  String get navLabDemoOnlyBadge;

  /// No description provided for @navLabEventPushPath.
  ///
  /// In en, this message translates to:
  /// **'PUSH -> {path}'**
  String navLabEventPushPath(String path);

  /// No description provided for @navLabInstructionDeepPush.
  ///
  /// In en, this message translates to:
  /// **'1. Deep Push: Open Branch A -> A1 -> A1.1 -> A1.1.1. Press Android Back 4 times. Verify each parent node restores without exit dialog.'**
  String get navLabInstructionDeepPush;

  /// No description provided for @navLabInstructionSiblings.
  ///
  /// In en, this message translates to:
  /// **'2. Siblings: Open A1 -> A1.1 -> Back -> A1.2 -> Back. Verify Node A1 is perfectly restored.'**
  String get navLabInstructionSiblings;

  /// No description provided for @navLabInstructionOverlay.
  ///
  /// In en, this message translates to:
  /// **'3. Overlay: On any node, tap \"Open Test Dialog\" or \"Open Test Sheet\". Press Android Back. Verify overlay closes and current route remains active.'**
  String get navLabInstructionOverlay;

  /// No description provided for @navLabInstructionRootExit.
  ///
  /// In en, this message translates to:
  /// **'4. Root Exit: Pop back to true app root (/dashboard). Press Android Back. Verify \"Exit Application\" dialog appears.'**
  String get navLabInstructionRootExit;

  /// No description provided for @navLabNestedRootTitle.
  ///
  /// In en, this message translates to:
  /// **'Nested Navigation Test'**
  String get navLabNestedRootTitle;

  /// No description provided for @navLabNestedDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nested Details'**
  String get navLabNestedDetailsTitle;

  /// No description provided for @navLabNestedAuditTitle.
  ///
  /// In en, this message translates to:
  /// **'Nested Audit'**
  String get navLabNestedAuditTitle;

  /// No description provided for @navLabNestedSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nested Settings'**
  String get navLabNestedSettingsTitle;

  /// No description provided for @navLabNestedAdvancedTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Nested Settings'**
  String get navLabNestedAdvancedTitle;

  /// No description provided for @navLabNestedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify nested routes, direct links, Back, and language switching'**
  String get navLabNestedSubtitle;

  /// No description provided for @navLabNestedActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation test actions'**
  String get navLabNestedActionsTitle;

  /// No description provided for @navLabNestedOpenDetails.
  ///
  /// In en, this message translates to:
  /// **'Open details'**
  String get navLabNestedOpenDetails;

  /// No description provided for @navLabNestedOpenAudit.
  ///
  /// In en, this message translates to:
  /// **'Open audit'**
  String get navLabNestedOpenAudit;

  /// No description provided for @navLabNestedOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get navLabNestedOpenSettings;

  /// No description provided for @navLabNestedOpenAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Open advanced settings'**
  String get navLabNestedOpenAdvanced;

  /// No description provided for @navLabNestedToggleLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch language'**
  String get navLabNestedToggleLanguage;

  /// No description provided for @systemSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'System Setup'**
  String get systemSetupTitle;

  /// No description provided for @systemSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Foundation page for configuring the system. Setup actions are not available yet.'**
  String get systemSetupSubtitle;

  /// No description provided for @systemSetupStatusFoundationOnly.
  ///
  /// In en, this message translates to:
  /// **'Setup requirements planned'**
  String get systemSetupStatusFoundationOnly;

  /// No description provided for @systemSetupRequirementCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get systemSetupRequirementCompany;

  /// No description provided for @systemSetupRequirementAdminUser.
  ///
  /// In en, this message translates to:
  /// **'Administrator user'**
  String get systemSetupRequirementAdminUser;

  /// No description provided for @identityTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get identityTitle;

  /// No description provided for @identitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Foundation page for local identity and sessions. Sign-in and user management are not available yet.'**
  String get identitySubtitle;

  /// No description provided for @identityStatusFoundationOnly.
  ///
  /// In en, this message translates to:
  /// **'Identity responsibilities planned'**
  String get identityStatusFoundationOnly;

  /// No description provided for @identityResponsibilityLocalSession.
  ///
  /// In en, this message translates to:
  /// **'Local session'**
  String get identityResponsibilityLocalSession;

  /// No description provided for @identityResponsibilityAdminUser.
  ///
  /// In en, this message translates to:
  /// **'Administrator user'**
  String get identityResponsibilityAdminUser;

  /// No description provided for @identityResponsibilityCompanyMembership.
  ///
  /// In en, this message translates to:
  /// **'Company membership'**
  String get identityResponsibilityCompanyMembership;

  /// No description provided for @identityResponsibilityCompanySwitchEndsSession.
  ///
  /// In en, this message translates to:
  /// **'A company switch ends the current session'**
  String get identityResponsibilityCompanySwitchEndsSession;

  /// No description provided for @companyTitle.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get companyTitle;

  /// No description provided for @companySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Foundation page for active company, membership, and tenant scope. Company management is not available yet.'**
  String get companySubtitle;

  /// No description provided for @companyStatusFoundationOnly.
  ///
  /// In en, this message translates to:
  /// **'Company responsibilities planned'**
  String get companyStatusFoundationOnly;

  /// No description provided for @companyResponsibilityActiveCompany.
  ///
  /// In en, this message translates to:
  /// **'Active company context'**
  String get companyResponsibilityActiveCompany;

  /// No description provided for @companyResponsibilityMembership.
  ///
  /// In en, this message translates to:
  /// **'Company membership'**
  String get companyResponsibilityMembership;

  /// No description provided for @companyResponsibilityTenantScope.
  ///
  /// In en, this message translates to:
  /// **'Tenant scope'**
  String get companyResponsibilityTenantScope;

  /// No description provided for @companyResponsibilitySwitchEndsSession.
  ///
  /// In en, this message translates to:
  /// **'A future company switch must end the current session'**
  String get companyResponsibilitySwitchEndsSession;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// No description provided for @permissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Foundation page for a permission catalog and authorization intent. Policy enforcement is not available yet.'**
  String get permissionsSubtitle;

  /// No description provided for @permissionsStatusFoundationOnly.
  ///
  /// In en, this message translates to:
  /// **'Permission definitions only'**
  String get permissionsStatusFoundationOnly;

  /// No description provided for @permissionsResponsibilityCatalog.
  ///
  /// In en, this message translates to:
  /// **'Permission catalog'**
  String get permissionsResponsibilityCatalog;

  /// No description provided for @permissionsResponsibilityRouteIntent.
  ///
  /// In en, this message translates to:
  /// **'Route access intent'**
  String get permissionsResponsibilityRouteIntent;

  /// No description provided for @permissionsResponsibilityOperationIntent.
  ///
  /// In en, this message translates to:
  /// **'Operation permission intent'**
  String get permissionsResponsibilityOperationIntent;

  /// No description provided for @permissionsResponsibilityNoRuntimeGrants.
  ///
  /// In en, this message translates to:
  /// **'No runtime roles or grants yet'**
  String get permissionsResponsibilityNoRuntimeGrants;

  /// No description provided for @setupCompanyCode.
  ///
  /// In en, this message translates to:
  /// **'Company code'**
  String get setupCompanyCode;

  /// No description provided for @setupCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get setupCompanyName;

  /// No description provided for @setupAdminName.
  ///
  /// In en, this message translates to:
  /// **'Administrator name'**
  String get setupAdminName;

  /// No description provided for @setupAdminEmail.
  ///
  /// In en, this message translates to:
  /// **'Administrator email'**
  String get setupAdminEmail;

  /// No description provided for @setupPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get setupPassword;

  /// No description provided for @setupConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get setupConfirmPassword;

  /// No description provided for @setupCreate.
  ///
  /// In en, this message translates to:
  /// **'Create company and administrator'**
  String get setupCreate;

  /// No description provided for @setupValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a company code, company name, administrator name, valid email, and a password of at least 12 characters.'**
  String get setupValidation;

  /// No description provided for @setupPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get setupPasswordMismatch;

  /// No description provided for @setupAlreadyInitialized.
  ///
  /// In en, this message translates to:
  /// **'This installation is already initialized.'**
  String get setupAlreadyInitialized;

  /// No description provided for @setupRecoveryRequired.
  ///
  /// In en, this message translates to:
  /// **'Existing incomplete Core data needs recovery before setup can continue.'**
  String get setupRecoveryRequired;

  /// No description provided for @setupStorageFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not save setup. Try again.'**
  String get setupStorageFailure;

  /// No description provided for @setupCredentialFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare the password. Try again.'**
  String get setupCredentialFailure;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to access your NexaBiz workspace'**
  String get loginSubtitle;

  /// No description provided for @loginIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Email or Username'**
  String get loginIdentifier;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSubmit;

  /// No description provided for @loginValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email/username and password.'**
  String get loginValidation;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email/username or password.'**
  String get loginInvalidCredentials;

  /// No description provided for @loginUserInactive.
  ///
  /// In en, this message translates to:
  /// **'User account is deactivated. Contact system administrator.'**
  String get loginUserInactive;

  /// No description provided for @loginNoCompanies.
  ///
  /// In en, this message translates to:
  /// **'User has no active company memberships.'**
  String get loginNoCompanies;

  /// No description provided for @loginLockedOut.
  ///
  /// In en, this message translates to:
  /// **'Too many failed login attempts. Account is temporarily locked. Please try again later.'**
  String get loginLockedOut;

  /// No description provided for @loginLockedOutMinutes.
  ///
  /// In en, this message translates to:
  /// **'Too many failed login attempts. Account is temporarily locked. Please try again in {minutes} minute(s).'**
  String loginLockedOutMinutes(int minutes);

  /// No description provided for @loginLockedOutSeconds.
  ///
  /// In en, this message translates to:
  /// **'Too many failed login attempts. Account is temporarily locked. Please try again in {seconds} second(s).'**
  String loginLockedOutSeconds(int seconds);

  /// No description provided for @loginStorageFailure.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in at this time. Please try again later.'**
  String get loginStorageFailure;

  /// No description provided for @loginRetry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get loginRetry;

  /// No description provided for @companySelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Company'**
  String get companySelectionTitle;

  /// No description provided for @companySelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an active company workspace to continue'**
  String get companySelectionSubtitle;

  /// No description provided for @companySelectionCurrentRole.
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String companySelectionCurrentRole(String role);

  /// No description provided for @actionLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get actionLogout;

  /// No description provided for @unauthorizedTitle.
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get unauthorizedTitle;

  /// No description provided for @unauthorizedMessage.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this page.'**
  String get unauthorizedMessage;

  /// No description provided for @actionBackToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get actionBackToDashboard;

  /// No description provided for @authAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart ERP & Accounting System'**
  String get authAppSubtitle;

  /// No description provided for @authFooterNote.
  ///
  /// In en, this message translates to:
  /// **'NexaBiz ERP • Secured Enterprise Local Edition'**
  String get authFooterNote;

  /// No description provided for @authAdminPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Roles & Access Control'**
  String get authAdminPageTitle;

  /// No description provided for @authAdminPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure company roles, permissions, and member assignments'**
  String get authAdminPageSubtitle;

  /// No description provided for @authAdminRolesTitle.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get authAdminRolesTitle;

  /// No description provided for @authAdminRoleDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Role Details'**
  String get authAdminRoleDetailsTitle;

  /// No description provided for @authAdminCreateRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Role'**
  String get authAdminCreateRoleTitle;

  /// No description provided for @authAdminEditRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Role'**
  String get authAdminEditRoleTitle;

  /// No description provided for @authAdminDeleteRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Role'**
  String get authAdminDeleteRoleTitle;

  /// No description provided for @authAdminPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get authAdminPermissionsTitle;

  /// No description provided for @authAdminAssignedMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Assigned Members'**
  String get authAdminAssignedMembersTitle;

  /// No description provided for @authAdminAssignMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign Member'**
  String get authAdminAssignMemberTitle;

  /// No description provided for @authAdminRoleTypeBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get authAdminRoleTypeBuiltIn;

  /// No description provided for @authAdminRoleTypeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get authAdminRoleTypeCustom;

  /// No description provided for @authAdminRoleBuiltInBadge.
  ///
  /// In en, this message translates to:
  /// **'Built-in Role'**
  String get authAdminRoleBuiltInBadge;

  /// No description provided for @authAdminRoleCustomBadge.
  ///
  /// In en, this message translates to:
  /// **'Custom Role'**
  String get authAdminRoleCustomBadge;

  /// No description provided for @authAdminRoleBuiltInHelp.
  ///
  /// In en, this message translates to:
  /// **'Built-in roles are system-defined. Their identifier, permissions, and definition cannot be modified or deleted, but active members can be assigned or unassigned.'**
  String get authAdminRoleBuiltInHelp;

  /// No description provided for @authAdminRoleDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Role Name'**
  String get authAdminRoleDisplayNameLabel;

  /// No description provided for @authAdminRoleDisplayNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sales Manager'**
  String get authAdminRoleDisplayNamePlaceholder;

  /// No description provided for @authAdminRoleKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Role Identifier'**
  String get authAdminRoleKeyLabel;

  /// No description provided for @authAdminRoleKeyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. company.sales_manager'**
  String get authAdminRoleKeyPlaceholder;

  /// No description provided for @authAdminRoleKeyHelpText.
  ///
  /// In en, this message translates to:
  /// **'A unique, lowercase identifier (e.g. company.role_name). Cannot be modified after creation.'**
  String get authAdminRoleKeyHelpText;

  /// No description provided for @authAdminRoleDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get authAdminRoleDescriptionLabel;

  /// No description provided for @authAdminRoleDescriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe the purpose and responsibilities of this role'**
  String get authAdminRoleDescriptionPlaceholder;

  /// No description provided for @authAdminRoleDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get authAdminRoleDescriptionOptional;

  /// No description provided for @authAdminActionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get authAdminActionSave;

  /// No description provided for @authAdminActionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Role'**
  String get authAdminActionCreate;

  /// No description provided for @authAdminActionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get authAdminActionUpdate;

  /// No description provided for @authAdminActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Role'**
  String get authAdminActionDelete;

  /// No description provided for @authAdminActionAssign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get authAdminActionAssign;

  /// No description provided for @authAdminActionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get authAdminActionRemove;

  /// No description provided for @authAdminActionUnassign.
  ///
  /// In en, this message translates to:
  /// **'Unassign'**
  String get authAdminActionUnassign;

  /// No description provided for @authAdminSearchRolesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search roles...'**
  String get authAdminSearchRolesPlaceholder;

  /// No description provided for @authAdminSearchPermissionsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search permissions...'**
  String get authAdminSearchPermissionsPlaceholder;

  /// No description provided for @authAdminSearchMembersPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search members...'**
  String get authAdminSearchMembersPlaceholder;

  /// No description provided for @authAdminFilterAllRoles.
  ///
  /// In en, this message translates to:
  /// **'All Roles'**
  String get authAdminFilterAllRoles;

  /// No description provided for @authAdminFilterBuiltInRoles.
  ///
  /// In en, this message translates to:
  /// **'Built-in Roles'**
  String get authAdminFilterBuiltInRoles;

  /// No description provided for @authAdminFilterCustomRoles.
  ///
  /// In en, this message translates to:
  /// **'Custom Roles'**
  String get authAdminFilterCustomRoles;

  /// No description provided for @authAdminEmptyRoles.
  ///
  /// In en, this message translates to:
  /// **'No roles found.'**
  String get authAdminEmptyRoles;

  /// No description provided for @authAdminEmptyRolesSearch.
  ///
  /// In en, this message translates to:
  /// **'No roles matching your search.'**
  String get authAdminEmptyRolesSearch;

  /// No description provided for @authAdminEmptyAssignedMembers.
  ///
  /// In en, this message translates to:
  /// **'No members currently assigned to this role.'**
  String get authAdminEmptyAssignedMembers;

  /// No description provided for @authAdminEmptyAssignableMembers.
  ///
  /// In en, this message translates to:
  /// **'No assignable members available.'**
  String get authAdminEmptyAssignableMembers;

  /// No description provided for @authAdminEmptyAssignableMembersSearch.
  ///
  /// In en, this message translates to:
  /// **'No members matching your search.'**
  String get authAdminEmptyAssignableMembersSearch;

  /// No description provided for @authAdminEmptyPermissionsSearch.
  ///
  /// In en, this message translates to:
  /// **'No permissions matching your search.'**
  String get authAdminEmptyPermissionsSearch;

  /// No description provided for @authAdminMemberStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get authAdminMemberStatusActive;

  /// No description provided for @authAdminMemberStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get authAdminMemberStatusInactive;

  /// No description provided for @authAdminMemberEligible.
  ///
  /// In en, this message translates to:
  /// **'Eligible'**
  String get authAdminMemberEligible;

  /// No description provided for @authAdminMemberIneligible.
  ///
  /// In en, this message translates to:
  /// **'Ineligible'**
  String get authAdminMemberIneligible;

  /// No description provided for @authAdminAvailableMembersSection.
  ///
  /// In en, this message translates to:
  /// **'Available Members'**
  String get authAdminAvailableMembersSection;

  /// No description provided for @authAdminDeleteRoleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete role \"{roleName}\"?'**
  String authAdminDeleteRoleConfirm(String roleName);

  /// No description provided for @authAdminDeleteRoleConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone.'**
  String get authAdminDeleteRoleConfirmMessage;

  /// No description provided for @authAdminUnassignMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{memberName}\" from role \"{roleName}\"?'**
  String authAdminUnassignMemberConfirm(String memberName, String roleName);

  /// No description provided for @authAdminPermissionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No permissions} =1{1 permission} other{{count} permissions}}'**
  String authAdminPermissionCount(int count);

  /// No description provided for @authAdminMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No members} =1{1 member} other{{count} members}}'**
  String authAdminMemberCount(int count);

  /// No description provided for @authAdminGroupCompany.
  ///
  /// In en, this message translates to:
  /// **'Company Workspace'**
  String get authAdminGroupCompany;

  /// No description provided for @authAdminGroupIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity & Users'**
  String get authAdminGroupIdentity;

  /// No description provided for @authAdminGroupAuthorization.
  ///
  /// In en, this message translates to:
  /// **'Access Control & Roles'**
  String get authAdminGroupAuthorization;

  /// No description provided for @authAdminGroupOther.
  ///
  /// In en, this message translates to:
  /// **'Other Permissions'**
  String get authAdminGroupOther;

  /// No description provided for @authAdminPermCompanyProfileViewTitle.
  ///
  /// In en, this message translates to:
  /// **'View company profile'**
  String get authAdminPermCompanyProfileViewTitle;

  /// No description provided for @authAdminPermCompanyProfileViewDesc.
  ///
  /// In en, this message translates to:
  /// **'View company basic details, code, and organization profile.'**
  String get authAdminPermCompanyProfileViewDesc;

  /// No description provided for @authAdminPermCompanyProfileManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage company profile'**
  String get authAdminPermCompanyProfileManageTitle;

  /// No description provided for @authAdminPermCompanyProfileManageDesc.
  ///
  /// In en, this message translates to:
  /// **'Update company profile information, settings, and business details.'**
  String get authAdminPermCompanyProfileManageDesc;

  /// No description provided for @authAdminPermCompanyMembershipViewTitle.
  ///
  /// In en, this message translates to:
  /// **'View company memberships'**
  String get authAdminPermCompanyMembershipViewTitle;

  /// No description provided for @authAdminPermCompanyMembershipViewDesc.
  ///
  /// In en, this message translates to:
  /// **'Inspect users and members associated with this company workspace.'**
  String get authAdminPermCompanyMembershipViewDesc;

  /// No description provided for @authAdminPermIdentitySessionViewTitle.
  ///
  /// In en, this message translates to:
  /// **'View active sessions'**
  String get authAdminPermIdentitySessionViewTitle;

  /// No description provided for @authAdminPermIdentitySessionViewDesc.
  ///
  /// In en, this message translates to:
  /// **'Inspect active authentication sessions, login status, and devices.'**
  String get authAdminPermIdentitySessionViewDesc;

  /// No description provided for @authAdminPermIdentityUserManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage users'**
  String get authAdminPermIdentityUserManageTitle;

  /// No description provided for @authAdminPermIdentityUserManageDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage user credentials, account status, and authentication security.'**
  String get authAdminPermIdentityUserManageDesc;

  /// No description provided for @authAdminPermCatalogViewTitle.
  ///
  /// In en, this message translates to:
  /// **'View permission catalog'**
  String get authAdminPermCatalogViewTitle;

  /// No description provided for @authAdminPermCatalogViewDesc.
  ///
  /// In en, this message translates to:
  /// **'View all declared capabilities and system permissions available for configuration.'**
  String get authAdminPermCatalogViewDesc;

  /// No description provided for @authAdminPermPolicyReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review authorization policy'**
  String get authAdminPermPolicyReviewTitle;

  /// No description provided for @authAdminPermPolicyReviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Read roles, role permissions, and membership assignments without modification.'**
  String get authAdminPermPolicyReviewDesc;

  /// No description provided for @authAdminPermRoleManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage custom roles'**
  String get authAdminPermRoleManageTitle;

  /// No description provided for @authAdminPermRoleManageDesc.
  ///
  /// In en, this message translates to:
  /// **'Create, rename, describe, and delete custom company roles.'**
  String get authAdminPermRoleManageDesc;

  /// No description provided for @authAdminPermPolicyManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage role permissions'**
  String get authAdminPermPolicyManageTitle;

  /// No description provided for @authAdminPermPolicyManageDesc.
  ///
  /// In en, this message translates to:
  /// **'Grant and revoke specific permissions for custom company roles.'**
  String get authAdminPermPolicyManageDesc;

  /// No description provided for @authAdminPermAssignmentManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage role assignments'**
  String get authAdminPermAssignmentManageTitle;

  /// No description provided for @authAdminPermAssignmentManageDesc.
  ///
  /// In en, this message translates to:
  /// **'Assign and remove company roles for active company members.'**
  String get authAdminPermAssignmentManageDesc;

  /// No description provided for @authAdminUnknownPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'System-declared capability permission ({permissionId}).'**
  String authAdminUnknownPermissionDesc(String permissionId);

  /// No description provided for @authAdminErrorRoleNotFound.
  ///
  /// In en, this message translates to:
  /// **'Role not found in the current company.'**
  String get authAdminErrorRoleNotFound;

  /// No description provided for @authAdminErrorMembershipNotFound.
  ///
  /// In en, this message translates to:
  /// **'Company membership not found.'**
  String get authAdminErrorMembershipNotFound;

  /// No description provided for @authAdminErrorCrossCompany.
  ///
  /// In en, this message translates to:
  /// **'Security violation: tenant mismatch detected.'**
  String get authAdminErrorCrossCompany;

  /// No description provided for @authAdminErrorBuiltInCreate.
  ///
  /// In en, this message translates to:
  /// **'Cannot create a role with built-in prefix or identifier.'**
  String get authAdminErrorBuiltInCreate;

  /// No description provided for @authAdminErrorBuiltInUpdate.
  ///
  /// In en, this message translates to:
  /// **'Built-in roles cannot be renamed or modified.'**
  String get authAdminErrorBuiltInUpdate;

  /// No description provided for @authAdminErrorBuiltInDelete.
  ///
  /// In en, this message translates to:
  /// **'Built-in system roles cannot be deleted.'**
  String get authAdminErrorBuiltInDelete;

  /// No description provided for @authAdminErrorBuiltInPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions for built-in roles cannot be modified.'**
  String get authAdminErrorBuiltInPermissions;

  /// No description provided for @authAdminErrorLastOwnerProtected.
  ///
  /// In en, this message translates to:
  /// **'Cannot remove the last active company owner. Assign another active owner first.'**
  String get authAdminErrorLastOwnerProtected;

  /// No description provided for @authAdminErrorUndeclaredPermission.
  ///
  /// In en, this message translates to:
  /// **'The requested permission is not declared in the system catalog.'**
  String get authAdminErrorUndeclaredPermission;

  /// No description provided for @authAdminErrorDuplicateRoleKey.
  ///
  /// In en, this message translates to:
  /// **'A role with this identifier already exists in this company.'**
  String get authAdminErrorDuplicateRoleKey;

  /// No description provided for @authAdminErrorDuplicateRoleDisplayName.
  ///
  /// In en, this message translates to:
  /// **'A role with this name already exists in this company.'**
  String get authAdminErrorDuplicateRoleDisplayName;

  /// No description provided for @authAdminErrorRoleHasAssignments.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete role because members are currently assigned to it.'**
  String get authAdminErrorRoleHasAssignments;

  /// No description provided for @authAdminErrorMembershipInactive.
  ///
  /// In en, this message translates to:
  /// **'Cannot assign role: member is currently inactive.'**
  String get authAdminErrorMembershipInactive;

  /// No description provided for @authAdminErrorUserInactive.
  ///
  /// In en, this message translates to:
  /// **'Cannot assign role: user account is currently inactive.'**
  String get authAdminErrorUserInactive;

  /// No description provided for @authAdminErrorCompanyInactive.
  ///
  /// In en, this message translates to:
  /// **'Cannot perform operation: company workspace is inactive.'**
  String get authAdminErrorCompanyInactive;

  /// No description provided for @authAdminErrorRoleNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Role name cannot be empty.'**
  String get authAdminErrorRoleNameEmpty;

  /// No description provided for @authAdminErrorRoleNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Role name cannot exceed {max} characters.'**
  String authAdminErrorRoleNameTooLong(int max);

  /// No description provided for @authAdminErrorRoleKeyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid role identifier format. Use lowercase letters, numbers, and underscores (e.g. company.sales_rep).'**
  String get authAdminErrorRoleKeyInvalid;

  /// No description provided for @authAdminErrorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to perform this administration action.'**
  String get authAdminErrorPermissionDenied;

  /// No description provided for @authAdminErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get authAdminErrorGeneric;

  /// No description provided for @authAdminPendingApplying.
  ///
  /// In en, this message translates to:
  /// **'Applying changes...'**
  String get authAdminPendingApplying;

  /// No description provided for @authAdminCommittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully.'**
  String get authAdminCommittedSuccess;

  /// No description provided for @authAdminNoRoleSelected.
  ///
  /// In en, this message translates to:
  /// **'Select a role to view its details.'**
  String get authAdminNoRoleSelected;

  /// No description provided for @authAdminLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get authAdminLoadMore;

  /// No description provided for @authAdminRolePermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get authAdminRolePermissionGranted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
