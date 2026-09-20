# 02 — NAVIGATION ARCHITECTURE CONTRACT

## 1. NAVIGATION AUTHORITY INVENTORY

The current production navigation system is built on `go_router` (v14.8.1) encapsulated by NexaBiz core navigation abstractions:

| Navigation Component | Physical Location | Responsibility |
| :--- | :--- | :--- |
| `NexaBizGoRouterAdapter` | `lib/app/router/nexabiz_router_adapter.dart` | Translates capability navigation registrations into `GoRouter` configuration with stateful shell branches. |
| `NexaBizNavigationRegistry` | `lib/core/navigation/nexabiz_navigation_registry.dart` | Collects, validates, and locks contributed route definitions across capability manifests. |
| `ApplicationShell` | `lib/app/shell/application_shell.dart` | Provides responsive navigation UI across Mobile (`AppCustomBottomNav`), Tablet, and Desktop platforms. |
| `AppExitPopScope` | `lib/app/shell/app_exit_scope.dart` | Controls double-back exit confirmation and owns system termination (`SystemNavigator.pop()`). |

---

## 2. CANONICAL PRIMARY BRANCHES

The platform defines 4 primary stateful shell branches:

```text
/dashboard   -> Dashboard Capability
/services    -> Services Capability
/reports     -> Reports Capability
/settings    -> Settings Capability
```

All primary branches are rendered within `StatefulShellRoute.indexedStack` wrapped in `ApplicationShell` and `AppExitPopScope`.

Secondary feature route roots (such as `/gallery`, `/demo`, `/dev/navigation`, and `/navigation-test-lab`) register outside the primary shell. Nested children of those roots are registered beneath their parent `GoRoute`.

### Nested route definitions

`NexaBizRouteDefinition.parentRouteId` is optional. A route without it remains a root route; a route with it is a direct child of a route in the same capability contribution. The registry rejects missing or cross-capability parents, hierarchy cycles, and paths that are not one segment below the parent. Its `path` remains an absolute canonical URI for lookup and navigation. The router adapter derives a relative GoRouter child segment and builds the tree from registry metadata. It never registers feature paths by hand. The four primary shell branches remain unchanged; secondary route trees remain outside the shell when all four branches are present.

---

## 3. STACK SACREDNESS & NAVIGATION APIS

### Rule 2.1: Ordinary Hierarchical Navigation (`context.push`)
When navigating from a parent screen to a child/detail screen (e.g. `A -> B -> C`):
- You **MUST** use stack-preserving push: `context.push('/path')`.
- This maintains the complete navigation stack: `[A, B, C]`.
- System Back or App-Bar Back pops the stack cleanly: `C -> B -> A`.

### Rule 2.2: Destructive Navigation Restriction (`context.go`)
- `context.go('/path')` resets/replaces the navigation stack branch.
- `context.go()` is **RESTRICTED** to primary branch switching in `ApplicationShell` or root redirects.
- Feature pages **MUST NOT** use `context.go()` for ordinary detail page navigation.

```dart
// ALLOWED: Detail navigation
context.push('/gallery');

// FORBIDDEN: Stack reset for ordinary detail page
context.go('/gallery'); // VIOLATION
```

---

## 4. SYSTEM BACK & APP-BAR BACK SEMANTICS

- An App-Bar Back button and System Back gesture **MUST** produce identical navigation results.
- Back processing hierarchy:
  1. Active Overlay / Quick Actions Sheet open -> Close overlay.
  2. Immediate child route active -> `context.pop()`.
  3. Parent route available -> Pop navigation stack.
  4. True application root active -> Trigger double-back exit confirmation in `AppExitPopScope`.

---

## 5. SYSTEM EXIT OWNERSHIP

- Feature pages and presentation components **MUST NOT** call `SystemNavigator.pop()` or raw `exit(0)` / `exit(1)`.
- `SystemNavigator.pop()` is strictly owned by `lib/app/shell/app_exit_scope.dart`.
- An architecture guardrail (`test/app/architecture/navigation_architecture_guardrails_test.dart`) actively scans `lib/` for unauthorized system exit calls.

---

## 6. NAVIGATION TEST LAB STATUS

The Navigation Test Lab (`lib/packages/development/navigation_test_lab/`) is explicitly classified as:
```text
DEVELOPMENT / NAVIGATION VERIFICATION SURFACE
```
It exists solely to verify navigation stack behavior, parameter passing, and route history unwinding during development. It is **NOT** a business feature and must not be used as justification for production architecture exceptions.

---

## 7. NEW ROUTE CHECKLIST

```text
NEW ROUTE CHECKLIST

[ ] Search existing registered routes in capability manifests.
[ ] Define route using canonical NexaBizFlutterRouteDefinition.
[ ] Specify unique NexaBizRouteId (namespace + routeName).
[ ] Specify unique URI path string.
[ ] Register route inside owning capability's NexaBizNavigationContribution.
[ ] For a nested route, set parentRouteId to a registered direct parent and keep the full absolute path canonical.
[ ] For detail/sub-pages, use context.push() to preserve stack.
[ ] Ensure App-Bar Back button uses context.pop().
[ ] Verify System Back unwinds stack without terminating application.
[ ] Verify locale/RTL state is preserved across navigation transitions.
[ ] Add widget test verifying navigation route push and pop.
```
