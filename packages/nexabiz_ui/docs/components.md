# Component inventory and usage policy

`nexabiz_ui` is the application-facing design-system boundary. Application features import its production barrel and do not directly instantiate `shadcn_flutter` visual controls.

| Requirement | Canonical API |
| --- | --- |
| Buttons | `AppButton`, `AppIconButton` |
| Form composition | `AppForm`, `AppFormSection`, `AppFormRow`, `AppFormActions` |
| Text and numeric input | `AppTextField`, `AppMultilineField`, `AppNumberField`, `AppAmountField`, `AppPhoneField` |
| Selection | `AppSelectField`, `AppSelectOption`, `AppSearchableSelect`, `AppMultiSelectField` |
| Date input | `AppDateField`, `AppDateRangeField` |
| Page layout | the eight canonical `App*Page` types |
| Dialogs and sheets | `AppDialog`, `AppFormDialog`, canonical `App*Sheet` types |
| Data display | `AppDataTable`, `AppPaginationBar`, `AppStatusBadge`, state components |
| Navigation | `AppResponsiveScaffold`, `AppSidebar`, `AppCustomBottomNav`, `AppNavigationItem` |

The gallery and playground are preserved behind `nexabiz_ui_dev.dart`; they are not production API. Compatibility aliases, legacy page wrappers, and `AppDropdown` have been removed. See [public_api.md](public_api.md) for every exported symbol.

## Constraint-aware form composition

`AppFormRow` owns ordinary multi-field composition. It derives its column count
from the width granted by its immediate parent, `formColumnMinWidth`, spacing,
the configured maximum column count, and accessibility text scaling. It does
not consult device tiers. Use `fullWidthChildren` for descriptions, notes, or
other fields that remain full width. Feature pages must not rebuild the same
policy with `Row`, `Expanded`, or page-specific width checks.

Control height and field height are different contracts. Controls keep a
minimum interactive height; labels, descriptions, helpers, and validation
messages grow the total field height naturally.
