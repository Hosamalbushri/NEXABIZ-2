# 01 — Capability creation

Authority: [Project Constitution](../architecture/00_PROJECT_CONSTITUTION.md), [Package Contract](../architecture/01_PACKAGE_CONTRACT.md), and the current `lib/core/capabilities/` implementation.

1. Every new runtime module is represented by one `NexaBizCapability`; module size alone does not justify a new Flutter package.
2. Register the capability in `lib/app/bootstrap/nexabiz_capability_manifest.dart`. Do not create a parallel registry or register it directly in the router.
3. Use a unique canonical lower_snake_case `capabilityId`. Declare `dependsOn` explicitly using registered capability IDs; duplicate, missing, self, and circular dependencies are invalid. The registry validates and locks the graph.
4. `metadata.nameKey` is a localization identity, never a display string. Resolve user-facing labels through `AppLocalizations`; do not render the key itself.
5. A capability with a route must supply a `NexaBizNavigationContribution` containing that route and its root route ID. A capability with no screen may have no navigation contribution.
6. Keep core capability contracts framework-neutral. Search for a reusable capability and use the Change Manifest before introducing a new one.
7. Runtime setup and permission declarations are optional. A capability that needs them implements `NexaBizCapabilityWithRuntimeContributions`; existing capabilities need no new members. `NexaBizSetupContribution` declares provided and required setup IDs in canonical `capability.requirement` form. `NexaBizPermissionContribution` declares permission IDs and required permission intents in canonical `module.resource.operation` form. The registry validates IDs and rejects duplicate declared permission or provided setup IDs when it locks.
8. Contributions and `NexaBizRouteDefinition.accessRequirement` are metadata only. The registry does not resolve setup readiness or decide permissions, and the router does not enforce access requirements. Runtime enforcement requires a separate architecture decision and implementation.

See [Navigation Rules](02_NAVIGATION_RULES.md) for route ownership and [Localization Rules](03_LOCALIZATION_RULES.md) for display text.
