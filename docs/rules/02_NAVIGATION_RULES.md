# 02 — Navigation

Authority: [Navigation Contract](../architecture/02_NAVIGATION_CONTRACT.md) and the current `lib/core/navigation/` and `lib/app/router/` implementation.

1. Declare every feature route in its owning capability's `NexaBizNavigationContribution`. Do not add feature paths manually to `NexaBizGoRouterAdapter` or create a second router.
2. Use a unique `NexaBizRouteId` whose namespace equals the owning `capabilityId`. Supply a unique canonical absolute path: no duplicate case-insensitive path, empty or dot segment, backslash, whitespace, query, fragment, or trailing slash except `/`.
   For a nested route, set `parentRouteId` to an existing direct parent in the same capability; the registry rejects missing parents, cycles, and non-direct child paths. Keep the route's public path absolute; the adapter computes the relative GoRouter segment.
3. The navigation registry validates and locks route metadata; the router adapter only translates that metadata to `GoRouter`. New primary shell branches require an explicit architecture decision because the current adapter defines four canonical branches.
4. Use `context.push()` for ordinary child/detail navigation and `context.pop()` for back. Restrict `context.go()` to primary branch switching or root redirects as defined by contract 02. Preserve system-back and app-bar-back equivalence; only `AppExitPopScope` owns system termination.
5. Future authentication, setup, and permission gates must enforce access at the route or owning application boundary as well as any UI visibility. A hidden UI control alone is not a route guard. Design the actual guard against the canonical router when that module is authorized; this rule does not add one now.
6. Keep `lib/packages/development/navigation_test_lab/` as a development verification surface. It is not a business feature or a precedent for production navigation exceptions.
