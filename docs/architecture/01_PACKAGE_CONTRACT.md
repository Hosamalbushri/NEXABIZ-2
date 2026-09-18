# 01 — PACKAGE ARCHITECTURE CONTRACT

## 1. EXISTING PACKAGE INVENTORY

The current NexaBiz repository contains one authoritative shared package:

| Package Name | Physical Location | Primary Responsibility | Public Entry Point |
| :--- | :--- | :--- | :--- |
| `nexabiz_ui` | `packages/nexabiz_ui/` | Encapsulate design system tokens, canonical page primitives, UI components, layout structures, and `shadcn_flutter` integration. | `package:nexabiz_ui/nexabiz_ui.dart` |

---

## 2. PACKAGE BOUNDARY RULES

### Rule 1.1: Public Barrel Mandate
All external consumers (the main application in `lib/` and any feature capabilities) MUST import `nexabiz_ui` exclusively through its top-level public barrel file:

```dart
// ALLOWED: Public API consumption
import 'package:nexabiz_ui/nexabiz_ui.dart';
```

### Rule 1.2: Internal `src/` Import Prohibition
Direct imports into internal package implementations are strictly forbidden:

```dart
// FORBIDDEN: Package internal boundary bypass
import 'package:nexabiz_ui/src/layout/app_page.dart'; // VIOLATION
import 'package:nexabiz_ui/src/theme/app_colors.dart'; // VIOLATION
```

An architecture guardrail (`test/architecture/package_boundary_test.dart`) actively enforces this boundary across all production Dart files.

### Rule 1.3: Package Boundary Exception Procedure
If an internal component is needed by external feature code:
1. Do NOT bypass the boundary with a `src/` import.
2. Evaluate if the component should be part of the public package API.
3. If public exposure is architecturally justified, export the component in `packages/nexabiz_ui/lib/nexabiz_ui.dart`.
4. If it is internal/experimental, submit a UI Component Gap report.

---

## 3. PACKAGE CREATION ANALYSIS WORKFLOW

A new Flutter package MUST NOT be created simply because a feature or module is large.

Before creating ANY new package in `packages/`, an agent or developer MUST perform a Package Creation Analysis and include it in the Change Manifest:

```text
PACKAGE CREATION ANALYSIS
Requested capability / domain:
Existing packages searched:
Why existing package(s) cannot own this capability:
Proposed package location: packages/<package_name>
Expected responsibility:
Expected public API exports:
Dependencies required:
Target consumers:
Architecture justification:
```

Creation of a new package is invalid without prior architectural authorization.
