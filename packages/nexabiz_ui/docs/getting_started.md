# Getting started with NexaBiz UI

## 1. How do I import NexaBiz UI?

Application features and production code import only the canonical production entrypoint:

```dart
import 'package:nexabiz_ui/nexabiz_ui.dart';
```

Development-only tools, scenarios, the Component Gallery, and the Mobile UI Playground are strictly segregated behind the development entrypoint:

```dart
import 'package:nexabiz_ui/nexabiz_ui_dev.dart';
```

> [!WARNING]
> Feature code **MUST NOT** import `package:nexabiz_ui/src/...` or `package:shadcn_flutter/...`. All design tokens, canonical primitives, layout systems, overlays, and navigation surfaces are exported by `nexabiz_ui.dart`.

---

## 2. How do I create a page?

Use canonical `AppPage` or one of the specialized page layout containers (`AppListPage`, `AppFormPage`, `AppDetailsPage`, `AppTablePage`, `AppDashboardPage`, `AppSettingsPage`, `AppMasterDetailPage`). Never construct raw scaffolds or ad-hoc column scroll views.

```dart
class CustomerListPage extends StatelessWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppListPage(
      header: AppPageHeader(
        title: l10n.customersTitle,
        subtitle: l10n.customersSubtitle,
        actions: [
          AppButton(
            variant: AppButtonVariant.primary,
            label: l10n.newCustomer,
            onPressed: () => context.push('/customers/new'),
          ),
        ],
      ),
      body: const CustomerTableView(),
    );
  }
}
```

---

## 3. How do I create a form?

Compose forms using `AppForm`, `AppFormSection`, `AppFormRow`, and `AppFormActions`.

```dart
AppForm(
  children: [
    AppFormSection(
      title: l10n.personalDetails,
      children: [
        AppFormRow(
          children: [
            AppTextField(
              label: l10n.firstName,
              isRequired: true,
            ),
            AppTextField(
              label: l10n.lastName,
              isRequired: true,
            ),
          ],
        ),
        AppTextField(
          label: l10n.email,
          isRequired: true,
        ),
      ],
    ),
    AppFormActions(
      submitLabel: l10n.save,
      onSubmit: () => handleSave(),
      onCancel: () => Navigator.of(context).maybePop(),
    ),
  ],
)
```

---

## 4. How do I create a field?

Use canonical `App*Field` primitives (`AppTextField`, `AppNumberField`, `AppAmountField`, `AppDateField`, `AppPhoneField`, `AppMultilineField`). All fields share the authoritative `AppFieldShell` for unified labels, validation banners, required asterisks, and focus rings.

```dart
AppTextField(
  label: l10n.invoiceNumber,
  placeholder: 'INV-2026-001',
  isRequired: true,
  helperText: l10n.invoiceHelper,
  errorText: invoiceError,
  onChanged: (value) => handleInvoiceChange(value),
)
```

---

## 5. How do I create a select?

Use `AppSelectField<T>` with typed `AppSelectOption<T>` models. For multi-selection or searchable filters, use `AppMultiSelectField<T>` or `AppSearchableSelect<T>`.

```dart
AppSelectField<String>(
  label: l10n.status,
  value: currentStatus,
  options: [
    AppSelectOption(value: 'draft', label: l10n.draft),
    AppSelectOption(value: 'approved', label: l10n.approved),
    AppSelectOption(value: 'archived', label: l10n.archived),
  ],
  onChanged: (value) => setState(() => currentStatus = value),
)
```

---

## 6. How do I create a dialog?

Use `AppDialog` for custom modal content, `AppConfirmationDialog` for user confirmations, or `AppFormDialog` for compact modal editing:

```dart
final confirmed = await AppConfirmationDialog.show(
  context: context,
  title: l10n.deleteAccountTitle,
  message: l10n.deleteAccountWarning,
  isDestructive: true,
);
if (confirmed == true) {
  await executeDeletion();
}
```

---

## 7. How do I create a sheet?

Use `AppBottomSheet`, `AppDrawerSheet`, `AppFormSheet`, or `AppSwiperSheet`:

```dart
await AppBottomSheet.show<void>(
  context: context,
  builder: (context) => AppDrawerSheet(
    title: l10n.filterDrawerTitle,
    onClose: () => Navigator.of(context).pop(),
    child: const FilterOptionsView(),
  ),
);
```

---

## 8. How do I create application navigation?

The application owns routing, session state, and permissions. The UI package renders the surfaces via `AppResponsiveScaffold`, which automatically selects `AppSidebar` + `AppTopHeader` on expanded viewports (>=1000px) and `AppCustomBottomNav` on compact viewports (<1000px). Destinations use `AppNavigationItem`:

```dart
AppResponsiveScaffold(
  sidebar: AppSidebar(
    header: AppCompanySwitcher(companyName: activeCompany.name),
    groups: [
      AppSidebarGroup(title: l10n.navigationGeneral, items: navItems),
    ],
    selectedId: activeRouteId,
    onSelected: (id) => handleNavigation(id),
  ),
  topHeader: AppTopHeader(
    actions: [
      AppIconButton(
        variant: AppIconButtonVariant.chip,
        icon: AppIcons.bell,
        tooltip: l10n.notifications,
        onPressed: () => openNotifications(),
      ),
    ],
  ),
  mobileBottomBar: AppCustomBottomNav(
    selectedId: activeRouteId,
    items: navItems,
    onSelected: (id) => handleNavigation(id),
    fabTooltip: l10n.quickActions,
    onFabTap: () => AppQuickActionsPanel.show(context: context, items: quickActions),
  ),
  body: currentScreen,
)
```

---

## 9. How do I localize generic UI?

- Feature modules use generated `AppLocalizations.of(context)!`.
- Reusable UI primitives and design system components consume `NexaBizUiLocalizations.of(context)`:

```dart
final loc = NexaBizUiLocalizations.of(context);
// Canonical getters decoupled from text directionality:
// loc.save, loc.cancel, loc.close, loc.search, loc.back, loc.delete, etc.
```

> [!IMPORTANT]
> Never write `isRtl ? 'حفظ' : 'Save'`. Directionality (`TextDirection.rtl` / `TextDirection.ltr`) is strictly separated from language selection (`locale.languageCode`).

---

## 10. How do I make a component responsive?

Use `AppResponsive.builder` or `AppBreakpoints` responding to available layout width constraints rather than arbitrary device categories:

```dart
AppResponsive.builder(
  builder: (context, tier, constraints) {
    if (tier == AppBreakpointTier.compact) {
      return const MobileCardsView();
    }
    return const DesktopDataTableView();
  },
)
```

Canonical breakpoint boundaries:

- `compact`: `< 600 px`
- `medium`: `600 .. 999 px`
- `expanded`: `1000 .. 1439 px`
- `wide`: `>= 1440 px`

---

## Public API Matrix & Architectural Contracts

For the complete catalog of all 169 exported production symbols, classifications, and consumer ledgers, consult [`public_api.md`](public_api.md).
