# Navigation surfaces

NexaBiz separates route policy from visual navigation. `nexabiz_ui` renders destinations and invokes callbacks; the application shell interprets each opaque `AppNavigationItem.id` and calls GoRouter.

| Layer | Canonical surface | Responsibility |
| --- | --- | --- |
| Application shell | `AppResponsiveScaffold` | Chooses desktop or compact application chrome from canonical breakpoints |
| Primary desktop navigation | `AppSidebar` | Grouped application destinations, selected state, company header, user footer |
| Primary compact navigation | `AppCustomBottomNav` | Mobile/tablet destinations and optional quick-action trigger |
| Global action chrome | `AppTopHeader` | Application-wide actions; not a route hierarchy |
| Full-route app bar | `AppCustomAppBar` | Back/menu/search/notification chrome for canonical page types |
| In-page hierarchy | `AppPageHeader` + `AppBreadcrumb` | Page title, hierarchy, filters, and contextual actions |
| Content navigation | `AppTabs` / `AppTabWorkspace` | Switches content within the active page |
| Contextual overlays | `AppDrawerSheet`, quick-action panels | Temporary contextual choices; never primary navigation |

`AppNavigationItem` is the sole shared destination model. It contains an opaque ID, localized label, icons, enabled state, and optional presentation adornments. It contains no router object, route builder, or navigation policy.

## Responsive contract

- Compact: width below 600; bottom navigation.
- Medium: 600–999; bottom navigation.
- Expanded: 1000–1439; sidebar and top header.
- Wide: 1440 and above; sidebar and top header.

The shell is validated at 320, 430, 599, 600, 800, 999, 1000, 1200, 1439, 1440, and 1920 logical pixels, plus RTL, 200% text scaling, semantics, and keyboard activation.

All labels are localized by the application before being passed to a surface. Every icon-only action must supply a specific `tooltip` or `semanticLabel`; a generic “Action” fallback is forbidden.
