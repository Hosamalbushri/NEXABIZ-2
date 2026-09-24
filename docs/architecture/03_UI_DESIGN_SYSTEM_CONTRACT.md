# 03 — UI DESIGN SYSTEM CONTRACT

## 1. DESIGN SYSTEM DEPENDENCY CHAIN

NexaBiz enforces a strict 3-tier presentation abstraction chain:

```text
shadcn_flutter (v0.0.53)
        ↓
   nexabiz_ui (packages/nexabiz_ui)
        ↓
Application Presentation (lib/ presentation & packages/)
```

### Rule 3.1: Design System Encapsulation
Feature and application presentation code **MUST** consume UI primitives, tokens, and page structures exclusively from `package:nexabiz_ui/nexabiz_ui.dart`.

Direct imports of `package:shadcn_flutter/...` in application presentation code are **PROHIBITED**.

```dart
// ALLOWED: Consuming NexaBiz design system abstraction
import 'package:nexabiz_ui/nexabiz_ui.dart';

// FORBIDDEN: Direct framework bypass
import 'package:shadcn_flutter/shadcn_flutter.dart'; // VIOLATION
```

---

## 2. UI COMPONENT GAP PROCEDURE

If a required visual component or styling feature is missing in `nexabiz_ui`:
1. **DO NOT** directly import `shadcn_flutter` or build ad-hoc custom widgets inside feature code.
2. Submit a UI Component Gap analysis:

```text
UI COMPONENT GAP REPORT
Required component / feature:
Existing nexabiz_ui components searched:
Why existing components cannot satisfy requirement:
Proposed extension or new component in nexabiz_ui:
Responsive impact:
RTL impact:
Public API export:
Tests required:
```

3. Extend `packages/nexabiz_ui` with the necessary abstraction before consuming it in feature code.

---

## 3. CANONICAL PAGE PRIMITIVES

All pages in NexaBiz MUST use one of the 8 canonical page primitives exported by `nexabiz_ui`:

| Canonical Page Primitive | Intended Use Case |
| :--- | :--- |
| `AppPage` | General purpose page shell with header, actions, and scrolling body. |
| `AppListPage` | Data list presentation with search, filters, actions, and pagination. |
| `AppFormPage` | Form entry page with sticky header/footer action bar. |
| `AppDetailsPage` | Record inspection layout with tabbed metadata and side panels. |
| `AppTablePage` | High-density data grid layout with sorting and multi-column actions. |
| `AppDashboardPage` | Overview layout with analytics cards, summary tiles, and quick shortcuts. |
| `AppSettingsPage` | Configuration screen layout with grouped sections and toggles. |
| `AppMasterDetailPage` | Dual-pane split view layout for tablet and desktop viewports. |

### Deprecated Page Wrappers
Legacy wrappers (`AppPageShell`, `AppListPagePattern`, `AppFormPagePattern`, `AppDetailPagePattern`, `ModuleListScaffold`, `ModuleFormScaffold`) were removed after their production-consumer count reached zero. They **MUST NOT** be reintroduced. Guardrails enforce both consumer and declaration absence.

---

## 4. DESIGN TOKENS CATALOG

Feature presentation code MUST use canonical design tokens from `nexabiz_ui` rather than arbitrary hardcoded visual values:

- **Colors**: `AppColors` (`primaryBlue`, `secondaryTeal`, `accentPurple`, `neutralDark`, `surfaceLight`, etc.)
- **Typography**: `AppTypography` (`h1`, `h2`, `h3`, `bodyLarge`, `bodyMedium`, `bodySmall`, `label`, `caption`)
- **Spacing**: `AppSpacing` (`xs: 4`, `sm: 8`, `md: 16`, `lg: 24`, `xl: 32`, `xxl: 48`)
- **Radii**: `AppRadius` (`sm: 4`, `md: 8`, `lg: 12`, `xl: 16`, `full: 9999`)
- **Dimensions**: `AppDimensions` (`minTouchTarget: 48`, `iconSm: 16`, `iconMd: 24`, `iconLg: 32`)
- **Breakpoints**: `AppBreakpoints` (`compactMax: 599.9`, `mediumMin: 600`, `mediumMax: 1023.9`, `expandedMin: 1024`)

Arbitrary `Color(0xFF...)` literals inside presentation code are prohibited (enforced by `RULE-06-HARDCODED-COLORS`).

---

## 5. RESPONSIVE & RTL CONTRACT

- Window/shell structural adaptation MUST use `AppBreakpoints` or responsive primitives (`AppResponsive`, `AppResponsiveScaffold`).
- Local component composition MUST use the `BoxConstraints` granted by its immediate parent. It MUST NOT infer local width from the global screen or device tier.
- Canonical form composition owns field columns and full-width fields. Feature pages MUST NOT introduce page-specific form breakpoints or repeated `Row`/`Expanded` field layouts.
- Content surfaces grow naturally; fixed dimensions are reserved for controls, icons, separators, and other explicitly bounded UI mechanics.
- Arbitrary `MediaQuery.of(context).size.width` checks in feature code are prohibited.
- RTL compatibility MUST be preserved using directional geometry (`EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`).

---

## 6. NEW PAGE & COMPONENT CHECKLISTS

### New Page Checklist
```text
[ ] Search 8 canonical page primitives in nexabiz_ui.
[ ] Select appropriate primitive (e.g. AppListPage, AppFormPage).
[ ] Import strictly from package:nexabiz_ui/nexabiz_ui.dart.
[ ] Use AppColors, AppTypography, AppSpacing tokens for all styling.
[ ] Use AppLocalizations for all user-visible strings.
[ ] Ensure directional geometry (EdgeInsetsDirectional) for RTL.
[ ] Register route in capability navigation contribution.
[ ] Verify responsive layout across Mobile, Tablet, Desktop.
[ ] Add widget test for page rendering.
```

### New Component Checklist
```text
[ ] Search existing components in nexabiz_ui/lib/src/components.
[ ] Classify change as REUSE_EXISTING / EXTEND_EXISTING / NEW_REQUIRED.
[ ] Place shared component in packages/nexabiz_ui/lib/src/...
[ ] Export component in packages/nexabiz_ui/lib/nexabiz_ui.dart.
[ ] Use nexabiz_ui design tokens exclusively.
[ ] Support LTR and RTL text/icon directionality.
[ ] Support minimum touch target size (48dp).
[ ] Add component contract unit/widget tests in packages/nexabiz_ui/test/.
```
