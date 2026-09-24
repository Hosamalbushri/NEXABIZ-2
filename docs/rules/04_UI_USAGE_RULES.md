# 04 — UI usage

Authority: [UI Design System Contract](../architecture/03_UI_DESIGN_SYSTEM_CONTRACT.md) and [Package Contract](../architecture/01_PACKAGE_CONTRACT.md).

1. Application and feature presentation imports `nexabiz_ui` only through `package:nexabiz_ui/nexabiz_ui.dart`. Never import its `src/` implementation.
2. Reuse its public components and design tokens. Do not import `shadcn_flutter` directly in feature code, or use raw Material UI in place of an available `nexabiz_ui` abstraction.
3. Build screens with the appropriate canonical page primitive (`AppPage`, `AppListPage`, `AppFormPage`, `AppDetailsPage`, `AppTablePage`, `AppDashboardPage`, `AppSettingsPage`, or `AppMasterDetailPage`). Removed page wrappers and compatibility aliases MUST NOT be reintroduced.
4. Do not alter the theme or tokens to satisfy one page. Search public components first; if a needed capability is missing, use the UI Component Gap procedure in contract 03 before extending the shared package.
5. Use `AppBreakpoints` and directional layout primitives; check responsive behavior and LTR/RTL presentation. Keep all user-visible text under [Localization Rules](03_LOCALIZATION_RULES.md).
6. Production code imports `nexabiz_ui.dart`; only gallery, playground, and their tests may import `nexabiz_ui_dev.dart`.
7. Application navigation uses `AppNavigationItem` and callback-driven package surfaces. Router objects and route policy remain in the application layer.

## Local constraints and content resilience

These rules govern component composition below the global/window responsive
tier. A component minimum useful width is a local layout policy, not a new
global breakpoint.

1. Use the canonical `nexabiz_ui` public API.
2. Use local constraints for local composition.
3. Do not infer component width from screen or device type.
4. Do not add page-specific breakpoints.
5. Do not hardcode form column widths in feature pages.
6. Do not hardcode content-surface heights.
7. Do not scale fonts proportionally to width.
8. Respect `TextScaler` and accessibility text scaling.
9. Prefer natural content growth.
10. Prefer `Wrap` when wrapping is semantically correct.
11. Use `Expanded` only when fill behavior is intentional.
12. Use `Flexible` only when loose flex behavior is intentional.
13. Do not use `IntrinsicWidth` or `IntrinsicHeight` as a general layout fix.
14. Do not use `FittedBox` to hide text-layout problems.
15. Do not add `ScreenUtil`, `responsive_sizer`, or `Sizer`.
16. Preserve `shadcn_flutter` as the visual component authority.
17. Do not wrap shadcn components without a NexaBiz contract.
18. Do not create new public UI APIs without consumer evidence.
