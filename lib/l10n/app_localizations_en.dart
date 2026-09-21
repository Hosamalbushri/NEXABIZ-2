// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'NexaBiz ERP';

  @override
  String get splashTitle => 'NexaBiz ERP';

  @override
  String get splashSubtitle => 'Initializing secure business platform...';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navServices => 'Services';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get quickActionsTitle => 'Quick Actions';

  @override
  String get quickActionsSubtitle =>
      'Execute common business operations & developer tools';

  @override
  String get quickActionMobilePlayground => 'Mobile UI Playground';

  @override
  String get quickActionMobilePlaygroundDesc =>
      'Audit patterns & mobile ERP scenarios';

  @override
  String get dashboardMobilePlaygroundCta => 'Explore';

  @override
  String get dashboardMobilePlaygroundBadge => 'UI-01';

  @override
  String get quickActionComponentGallery => 'Component Gallery';

  @override
  String get quickActionComponentGalleryDesc =>
      'UI gallery & component playground';

  @override
  String get quickActionNewInvoice => 'New Invoice';

  @override
  String get quickActionNewInvoiceDesc => 'Create sales invoice';

  @override
  String get quickActionNewCustomer => 'New Customer';

  @override
  String get quickActionNewCustomerDesc => 'Register customer account';

  @override
  String get quickActionAddProduct => 'Add Product';

  @override
  String get quickActionAddProductDesc => 'Inventory item entry';

  @override
  String get exitDialogTitle => 'Exit Application';

  @override
  String get exitDialogMessage => 'Are you sure you want to exit NexaBiz ERP?';

  @override
  String get actionExit => 'Exit';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionOk => 'OK';

  @override
  String get actionClose => 'Close';

  @override
  String get actionClearLog => 'Clear Log';

  @override
  String get actionSystemReady => 'System Ready';

  @override
  String get actionDocumentation => 'Documentation';

  @override
  String get dashboardTitle => 'NexaBiz Dashboard';

  @override
  String get dashboardSubtitle => 'Welcome back to NexaBiz ERP';

  @override
  String get dashboardEnterpriseHighlights => 'Enterprise Highlights';

  @override
  String get dashboardHighlight1Title => 'Q3 Financial Revenue Peak';

  @override
  String get dashboardHighlight1Subtitle =>
      'Sales target exceeded by +14.2% with \$124,500.00 total volume.';

  @override
  String get dashboardHighlight1Badge => 'Financial Highlight';

  @override
  String get dashboardHighlight2Title => 'Inventory Reorder Alert';

  @override
  String get dashboardHighlight2Subtitle =>
      '18 active purchase orders in transit across main warehouses.';

  @override
  String get dashboardHighlight2Badge => 'Supply Chain';

  @override
  String get dashboardHighlight3Title => 'Automated Voucher Sync';

  @override
  String get dashboardHighlight3Subtitle =>
      'All real-time receipt & payment voucher ledgers fully synchronized.';

  @override
  String get dashboardHighlight3Badge => 'Real-time Ledger';

  @override
  String get dashboardArchitectureActive => 'Modular Clean Architecture Active';

  @override
  String get dashboardArchitectureSubtitle =>
      'System operational • Real-time capability synchronization enabled';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusStandby => 'Standby';

  @override
  String get statusSynced => 'Synced';

  @override
  String get statusPrimary => 'Primary';

  @override
  String get kpiTotalSales => 'Total Sales';

  @override
  String get kpiTotalSalesSubtitle => '+12.5% this month';

  @override
  String get kpiPurchases => 'Purchases';

  @override
  String get kpiPurchasesSubtitle => '18 active POs';

  @override
  String get kpiReceivables => 'Receivables';

  @override
  String get kpiReceivablesSubtitle => '4 pending invoices';

  @override
  String get kpiStockValuation => 'Stock Valuation';

  @override
  String get kpiStockValuationSubtitle => '1,240 inventory items';

  @override
  String get recentActivityTitle => 'Recent Activity';

  @override
  String get recentActivityItem1Title => 'Sales Invoice #INV-2026-0042';

  @override
  String get recentActivityItem1Subtitle =>
      'Customer: Acma Trading Co. • \$3,450.00';

  @override
  String get recentActivityItem1Time => '10 mins ago';

  @override
  String get recentActivityItem2Title => 'Stock Transfer #TR-902';

  @override
  String get recentActivityItem2Subtitle => 'Main Warehouse → Retail Branch B';

  @override
  String get recentActivityItem2Time => '1 hour ago';

  @override
  String get recentActivityItem3Title => 'Receipt Voucher #RCV-1021';

  @override
  String get recentActivityItem3Subtitle =>
      'Payment received for #INV-2026-0019';

  @override
  String get recentActivityItem3Time => '3 hours ago';

  @override
  String get servicesTitle => 'Services Hub';

  @override
  String get servicesSubtitle =>
      'Available Business Capabilities & Service Launchers';

  @override
  String get servicesDevSection => 'System & Developer Tools';

  @override
  String get servicesDevSectionSubtitle =>
      'UI design system and component playground';

  @override
  String get servicesComponentGallerySubtitle =>
      'Interactive shadcn_flutter playground';

  @override
  String get servicesMobilePlaygroundSubtitle =>
      'Interactive ERP mobile scenarios & design audit';

  @override
  String get servicesFinancialSection => 'Financial & Accounting';

  @override
  String get servicesFinancialSectionSubtitle =>
      'Core financial management tools';

  @override
  String get servicesGeneralLedger => 'General Ledger';

  @override
  String get servicesGeneralLedgerSubtitle => 'Journal entries & COA';

  @override
  String get servicesTreasuryCash => 'Treasury & Cash';

  @override
  String get servicesTreasuryCashSubtitle => 'Bank accounts & cash flow';

  @override
  String get servicesVoucherBooks => 'Voucher Books';

  @override
  String get servicesVoucherBooksSubtitle => 'Document numbering & books';

  @override
  String get servicesTaxVat => 'Tax & VAT';

  @override
  String get servicesTaxVatSubtitle => 'Tax rates & reporting';

  @override
  String get servicesSupplyChainSection => 'Supply Chain & Commerce';

  @override
  String get servicesSupplyChainSectionSubtitle =>
      'Inventory valuation, purchasing, & sales operations';

  @override
  String get servicesInventoryWarehouses => 'Inventory & Warehouses';

  @override
  String get servicesInventoryWarehousesSubtitle =>
      'Stock balances & transfers';

  @override
  String get servicesSalesBilling => 'Sales & Billing';

  @override
  String get servicesSalesBillingSubtitle => 'Invoices, orders & customers';

  @override
  String get servicesPurchasingPOs => 'Purchasing & POs';

  @override
  String get servicesPurchasingPOSubtitle => 'Purchase orders & suppliers';

  @override
  String get servicesLogisticsShipping => 'Logistics & Shipping';

  @override
  String get servicesLogisticsShippingSubtitle =>
      'Shipment tracking & dispatch';

  @override
  String get reportsTitle => 'Reports Hub';

  @override
  String get reportsSubtitle => 'Financial, Operational, & Analytical Reports';

  @override
  String get reportsEngineStatus => 'Engine Status';

  @override
  String get reportsEngineStatusBody =>
      'Reporting Engine Integration Standby • Clean data adapters ready';

  @override
  String get reportsFinancialReports => 'Financial Reports';

  @override
  String get reportsTrialBalance => 'Trial Balance';

  @override
  String get reportsTrialBalanceSubtitle => 'Debit/Credit summaries';

  @override
  String get reportsBalanceSheet => 'Balance Sheet';

  @override
  String get reportsBalanceSheetSubtitle => 'Assets & Liabilities';

  @override
  String get reportsProfitLoss => 'Profit & Loss';

  @override
  String get reportsProfitLossSubtitle => 'Income vs Expense';

  @override
  String get reportsGLAudit => 'General Ledger Audit';

  @override
  String get reportsGLAuditSubtitle => 'Journal verification';

  @override
  String get settingsTitle => 'Settings & Configuration';

  @override
  String get settingsSubtitle =>
      'Application preferences and enterprise profile management';

  @override
  String get settingsDevToolsSection => 'Developer & Design System Tools';

  @override
  String get settingsNavTestLab => 'Navigation Test Lab';

  @override
  String get settingsNavTestLabSubtitle =>
      'Manual deep-navigation, branch, overlay & parameter test lab';

  @override
  String get settingsGallery => 'UI Component Gallery & Playground';

  @override
  String get settingsGallerySubtitle =>
      'Interactive shadcn_flutter component showcase & test environment';

  @override
  String get settingsAppPreferencesSection => 'Application Preferences';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsDarkModeOn => 'Dark theme enabled';

  @override
  String get settingsDarkModeOff => 'Light theme enabled';

  @override
  String get settingsLanguage => 'Language & Localization';

  @override
  String get settingsLanguageSelectTitle => 'Select Application Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageEnglishSubtitle => 'English (US)';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageArabicSubtitle => 'العربية (المملكة العربية السعودية)';

  @override
  String get settingsCompanyProfileSection => 'Company & Currency Profile';

  @override
  String get settingsCompanyProfile => 'Company Profile';

  @override
  String get settingsCompanyProfileSubtitle => 'NexaBiz Enterprise Corp.';

  @override
  String get settingsFunctionalCurrency => 'Functional Currency';

  @override
  String get settingsFunctionalCurrencySubtitle => 'USD - United States Dollar';

  @override
  String get settingsSecuritySyncSection => 'Security & Sync';

  @override
  String get settingsSecurityControls => 'Security & Access Controls';

  @override
  String get settingsSecurityControlsSubtitle =>
      'Manage user roles and capability permissions';

  @override
  String get settingsOfflineSync => 'Offline Sync & Storage';

  @override
  String get settingsOfflineSyncSubtitle => 'All local databases up to date';

  @override
  String get demoTitle => 'NexaBiz Demo Capability';

  @override
  String get demoSubtitle =>
      'Verified clean architecture capability registration & shadcn_flutter integration';

  @override
  String get demoBadge => 'Capability Architecture Verified';

  @override
  String get demoDescription =>
      'This capability exists to prove capability registration, topological sorting, navigation registry resolution, GoRouter infrastructure adaptation, and canonical NexaBiz UI design system integration.';

  @override
  String get demoArchPrinciples => 'Architecture Principles';

  @override
  String get demoArchPrinciplesSubtitle => 'Clean Modular / Ports & Adapters';

  @override
  String get demoArchPrinciple1 =>
      '• Capability is the runtime application unit.';

  @override
  String get demoArchPrinciple2 =>
      '• Package is the physical implementation boundary.';

  @override
  String get demoArchPrinciple3 => '• Navigation is declared by capabilities.';

  @override
  String get demoArchPrinciple4 => '• GoRouter is an infrastructure adapter.';

  @override
  String get demoArchPrinciple5 =>
      '• UI components come from canonical NexaBiz UI package.';

  @override
  String get navLabTitle => 'Navigation Test Lab';

  @override
  String get navLabSubtitle =>
      'Production Navigation Hardening & Manual Deep-Stack Test Environment';

  @override
  String get navLabBadge => 'Dev Lab';

  @override
  String get navLabTelemetryLabRoot => 'Lab Root';

  @override
  String get navLabTelemetryTargetRouter => 'Target Router';

  @override
  String get navLabTelemetryRootScope => 'Root Scope';

  @override
  String get navLabTelemetryStackStrategy => 'Stack Strategy';

  @override
  String get navLabBranchLaunchersSection => 'BRANCH TEST LAUNCHERS';

  @override
  String get navLabBranchATitle => 'Branch A (4-Level Linear & Sibling Test)';

  @override
  String get navLabBranchBTitle => 'Branch B (Deep Alternate Branch)';

  @override
  String get navLabBranchCTitle => 'Branch C (Independent Route Shape)';

  @override
  String get navLabBranchParamTitle => 'Parameterized Routes';

  @override
  String get navLabBranchDestructiveTitle => 'Destructive Navigation Demos';

  @override
  String get navLabManualInstructionsSection => 'MANUAL TEST INSTRUCTIONS';

  @override
  String get navLabEventLogSection => 'NAVIGATION EVENT LOG';

  @override
  String get navLabRecentTelemetryEvents => 'Recent Telemetry Events';

  @override
  String get navLabNoEventsLogged =>
      'No navigation events logged yet. Tap a branch launcher above.';

  @override
  String get navLabNodeTelemetry => 'CURRENT ROUTE TELEMETRY';

  @override
  String get navLabNodeName => 'Node Name';

  @override
  String get navLabRoutePath => 'Route Path';

  @override
  String get navLabParentRoute => 'Parent Route';

  @override
  String get navLabStackDepth => 'Stack Depth';

  @override
  String get navLabBranch => 'Branch';

  @override
  String get navLabChildNavigationPush => 'CHILD NAVIGATION (PUSH)';

  @override
  String get navLabTestControls => 'TEST CONTROLS';

  @override
  String get navLabBackPop => 'Back (POP)';

  @override
  String get navLabBackPopSubtitle => 'Pops current node off navigation stack';

  @override
  String get navLabOpenTestDialog => 'Open Test Dialog';

  @override
  String get navLabOpenTestDialogSubtitle =>
      'Opens modal overlay dialog (System Back must close dialog)';

  @override
  String get navLabTestOverlayDialogTitle => 'Test Overlay Dialog';

  @override
  String get navLabTestOverlayDialogMessage =>
      'Press Android Back or tap Close. Current route must remain active.';

  @override
  String get navLabOpenTestSheet => 'Open Test Sheet';

  @override
  String get navLabOpenTestSheetSubtitle =>
      'Opens Quick Actions slide-over sheet';

  @override
  String get navLabTestSheetTitle => 'Test Quick Actions Sheet';

  @override
  String get navLabTestSheetSubtitle =>
      'Press Android Back or swipe down to close sheet';

  @override
  String get navLabSampleAction => 'Sample Action';

  @override
  String navLabParamTitle(String itemId) {
    return 'Parameter Test (Item #$itemId)';
  }

  @override
  String get navLabParamSubtitle =>
      'Navigation Test Lab — Parameterized Route Verification';

  @override
  String get navLabParamTelemetry => 'PARAMETER TELEMETRY';

  @override
  String get navLabParamId => 'Parameter ID';

  @override
  String get navLabParamActions => 'PARAMETER NAVIGATION ACTIONS';

  @override
  String get navLabNavigateToItem100 => 'Navigate to Item 100';

  @override
  String get navLabNavigateToItem200 => 'Navigate to Item 200';

  @override
  String get navLabDestructiveTitle => 'Destructive Navigation Demos';

  @override
  String get navLabDestructiveSubtitle =>
      'DEMO ONLY — Demonstrates stack replacement (context.go) vs stack preservation (context.push)';

  @override
  String get navLabDestructiveWarning =>
      'WARNING: Operations in this section perform intentional stack resets or branch replacements. Normal business feature navigation MUST NOT use these actions.';

  @override
  String get navLabStackReplacementDemos => 'STACK REPLACEMENT DEMOS';

  @override
  String get navLabReplaceA11 =>
      'REPLACE: context.go(\"/dev/navigation/a/a1/a1-1\")';

  @override
  String get navLabReplaceA11Subtitle =>
      'Replaces current stack directly with Node A1.1 (Destructive)';

  @override
  String get navLabResetLab => 'RESET: context.go(\"/dev/navigation\")';

  @override
  String get navLabResetLabSubtitle =>
      'Resets stack to Test Lab Dashboard root (Destructive)';

  @override
  String get navLabPreserveA11 =>
      'PRESERVE: context.push(\"/dev/navigation/a/a1/a1-1\")';

  @override
  String get navLabPreserveA11Subtitle =>
      'Pushes Node A1.1 onto existing stack (Stack Preserving)';

  @override
  String navLabNodeSubtitle(String branch, String depth) {
    return 'Navigation Test Lab — Branch $branch (Depth $depth)';
  }

  @override
  String navLabBranchBadge(String branch) {
    return 'Branch $branch';
  }

  @override
  String navLabPushPath(String path) {
    return 'PUSH $path';
  }

  @override
  String get navLabPushBadge => 'PUSH';

  @override
  String get navLabParamRouteBadge => 'Param Route';

  @override
  String get navLabDestructiveBadge => 'Destructive Demos';

  @override
  String get navLabReplaceBadge => 'REPLACE';

  @override
  String get navLabResetBadge => 'RESET';

  @override
  String navLabNodeTitle(String code) {
    return 'Node $code';
  }

  @override
  String navLabNodeSiblingTitle(String code) {
    return 'Node $code (Sibling)';
  }

  @override
  String navLabNodeDeepestTitle(String code) {
    return 'Node $code (Deepest)';
  }

  @override
  String navLabBranchRootTitle(String branch) {
    return 'Branch $branch Root';
  }

  @override
  String get navLabTargetRouterValue => 'Production GoRouter';

  @override
  String get navLabRootScopeValue => 'AppExitPopScope';

  @override
  String get navLabStackStrategyValue => 'PUSH (Stack Preserving)';

  @override
  String get navLabBranchAPath =>
      'Path: /dev/navigation/a -> A1 -> A1.1 -> A1.1.1';

  @override
  String get navLabBranchBPath =>
      'Path: /dev/navigation/b -> B1 -> B1.2 / B2.1';

  @override
  String get navLabBranchCPath =>
      'Path: /dev/navigation/c -> C1 -> C1.1 -> C1.1.1';

  @override
  String get navLabParamPath => 'Path: /dev/navigation/param/100 & 200';

  @override
  String get navLabDestructiveComparison =>
      'Explicit REPLACE (context.go) vs PUSH comparison';

  @override
  String get navLabFourLevels => '4 Levels';

  @override
  String get navLabThreeLevels => '3 Levels';

  @override
  String get navLabParamTestBadge => 'Param Test';

  @override
  String get navLabDemoOnlyBadge => 'Demo Only';

  @override
  String navLabEventPushPath(String path) {
    return 'PUSH -> $path';
  }

  @override
  String get navLabInstructionDeepPush =>
      '1. Deep Push: Open Branch A -> A1 -> A1.1 -> A1.1.1. Press Android Back 4 times. Verify each parent node restores without exit dialog.';

  @override
  String get navLabInstructionSiblings =>
      '2. Siblings: Open A1 -> A1.1 -> Back -> A1.2 -> Back. Verify Node A1 is perfectly restored.';

  @override
  String get navLabInstructionOverlay =>
      '3. Overlay: On any node, tap \"Open Test Dialog\" or \"Open Test Sheet\". Press Android Back. Verify overlay closes and current route remains active.';

  @override
  String get navLabInstructionRootExit =>
      '4. Root Exit: Pop back to true app root (/dashboard). Press Android Back. Verify \"Exit Application\" dialog appears.';

  @override
  String get navLabNestedRootTitle => 'Nested Navigation Test';

  @override
  String get navLabNestedDetailsTitle => 'Nested Details';

  @override
  String get navLabNestedAuditTitle => 'Nested Audit';

  @override
  String get navLabNestedSettingsTitle => 'Nested Settings';

  @override
  String get navLabNestedAdvancedTitle => 'Advanced Nested Settings';

  @override
  String get navLabNestedSubtitle =>
      'Verify nested routes, direct links, Back, and language switching';

  @override
  String get navLabNestedActionsTitle => 'Navigation test actions';

  @override
  String get navLabNestedOpenDetails => 'Open details';

  @override
  String get navLabNestedOpenAudit => 'Open audit';

  @override
  String get navLabNestedOpenSettings => 'Open settings';

  @override
  String get navLabNestedOpenAdvanced => 'Open advanced settings';

  @override
  String get navLabNestedToggleLanguage => 'Switch language';

  @override
  String get systemSetupTitle => 'System Setup';

  @override
  String get systemSetupSubtitle =>
      'Foundation page for configuring the system. Setup actions are not available yet.';

  @override
  String get systemSetupStatusFoundationOnly => 'Setup requirements planned';

  @override
  String get systemSetupRequirementCompany => 'Company';

  @override
  String get systemSetupRequirementAdminUser => 'Administrator user';

  @override
  String get identityTitle => 'Identity';

  @override
  String get identitySubtitle =>
      'Foundation page for local identity and sessions. Sign-in and user management are not available yet.';

  @override
  String get identityStatusFoundationOnly =>
      'Identity responsibilities planned';

  @override
  String get identityResponsibilityLocalSession => 'Local session';

  @override
  String get identityResponsibilityAdminUser => 'Administrator user';

  @override
  String get identityResponsibilityCompanyMembership => 'Company membership';

  @override
  String get identityResponsibilityCompanySwitchEndsSession =>
      'A company switch ends the current session';

  @override
  String get companyTitle => 'Company';

  @override
  String get companySubtitle =>
      'Foundation page for active company, membership, and tenant scope. Company management is not available yet.';

  @override
  String get companyStatusFoundationOnly => 'Company responsibilities planned';

  @override
  String get companyResponsibilityActiveCompany => 'Active company context';

  @override
  String get companyResponsibilityMembership => 'Company membership';

  @override
  String get companyResponsibilityTenantScope => 'Tenant scope';

  @override
  String get companyResponsibilitySwitchEndsSession =>
      'A future company switch must end the current session';

  @override
  String get permissionsTitle => 'Permissions';

  @override
  String get permissionsSubtitle =>
      'Foundation page for a permission catalog and authorization intent. Policy enforcement is not available yet.';

  @override
  String get permissionsStatusFoundationOnly => 'Permission definitions only';

  @override
  String get permissionsResponsibilityCatalog => 'Permission catalog';

  @override
  String get permissionsResponsibilityRouteIntent => 'Route access intent';

  @override
  String get permissionsResponsibilityOperationIntent =>
      'Operation permission intent';

  @override
  String get permissionsResponsibilityNoRuntimeGrants =>
      'No runtime roles or grants yet';

  @override
  String get setupCompanyCode => 'Company code';

  @override
  String get setupCompanyName => 'Company name';

  @override
  String get setupAdminName => 'Administrator name';

  @override
  String get setupAdminEmail => 'Administrator email';

  @override
  String get setupPassword => 'Password';

  @override
  String get setupConfirmPassword => 'Confirm password';

  @override
  String get setupCreate => 'Create company and administrator';

  @override
  String get setupValidation =>
      'Enter a company code, company name, administrator name, valid email, and a password of at least 12 characters.';

  @override
  String get setupPasswordMismatch => 'Passwords do not match.';

  @override
  String get setupAlreadyInitialized =>
      'This installation is already initialized.';

  @override
  String get setupRecoveryRequired =>
      'Existing incomplete Core data needs recovery before setup can continue.';

  @override
  String get setupStorageFailure => 'Could not save setup. Try again.';

  @override
  String get setupCredentialFailure =>
      'Could not prepare the password. Try again.';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginSubtitle =>
      'Enter your credentials to access your NexaBiz workspace';

  @override
  String get loginIdentifier => 'Email or Username';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSubmit => 'Sign In';

  @override
  String get loginValidation =>
      'Please enter your email/username and password.';

  @override
  String get loginInvalidCredentials => 'Invalid email/username or password.';

  @override
  String get loginUserInactive =>
      'User account is deactivated. Contact system administrator.';

  @override
  String get loginNoCompanies => 'User has no active company memberships.';

  @override
  String get loginLockedOut =>
      'Too many failed login attempts. Account is temporarily locked. Please try again later.';

  @override
  String loginLockedOutMinutes(int minutes) {
    return 'Too many failed login attempts. Account is temporarily locked. Please try again in $minutes minute(s).';
  }

  @override
  String loginLockedOutSeconds(int seconds) {
    return 'Too many failed login attempts. Account is temporarily locked. Please try again in $seconds second(s).';
  }

  @override
  String get loginStorageFailure =>
      'Unable to sign in at this time. Please try again later.';

  @override
  String get loginRetry => 'Try Again';

  @override
  String get companySelectionTitle => 'Select Company';

  @override
  String get companySelectionSubtitle =>
      'Choose an active company workspace to continue';

  @override
  String companySelectionCurrentRole(String role) {
    return 'Role: $role';
  }

  @override
  String get actionLogout => 'Sign Out';

  @override
  String get unauthorizedTitle => 'Access Denied';

  @override
  String get unauthorizedMessage =>
      'You do not have permission to access this page.';

  @override
  String get actionBackToDashboard => 'Back to Dashboard';
}
