# 04 — UI usage

Authority: [UI Design System Contract](../architecture/03_UI_DESIGN_SYSTEM_CONTRACT.md) and [Package Contract](../architecture/01_PACKAGE_CONTRACT.md).

1. Application and feature presentation imports `nexabiz_ui` only through `package:nexabiz_ui/nexabiz_ui.dart`. Never import its `src/` implementation.
2. Reuse its public components and design tokens. Do not import `shadcn_flutter` directly in feature code, or use raw Material UI in place of an available `nexabiz_ui` abstraction.
3. Build screens with the appropriate canonical page primitive (`AppPage`, `AppListPage`, `AppFormPage`, `AppDetailsPage`, `AppTablePage`, `AppDashboardPage`, `AppSettingsPage`, or `AppMasterDetailPage`). Do not use deprecated page wrappers for new screens.
4. Do not alter the theme or tokens to satisfy one page. Search public components first; if a needed capability is missing, use the UI Component Gap procedure in contract 03 before extending the shared package.
5. Use `AppBreakpoints` and directional layout primitives; check responsive behavior and LTR/RTL presentation. Keep all user-visible text under [Localization Rules](03_LOCALIZATION_RULES.md).
