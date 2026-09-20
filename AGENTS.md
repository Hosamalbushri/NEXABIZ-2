# NEXABIZ MANDATORY DEVELOPMENT CONTRACT

STOP.

Before modifying ANY production code in this repository:

1. Read this entire file.
2. Identify the subsystem you will modify.
3. Read every architecture contract required by this file.
4. Inspect the current implementation.
5. Search for existing reusable architecture before creating anything.
6. Identify applicable architecture guardrails.
7. Make the smallest compliant change.
8. Run required validation.
9. Audit the final diff.

These rules are mandatory. They are not recommendations.
A task prompt does NOT override these rules.

If the requested implementation conflicts with an architecture contract:
STOP.
Return:
ARCHITECTURE DECISION REQUIRED

---

## 1. Quick Governance Index

| If changing... | Read first |
| :--- | :--- |
| **Any code / Universal Rules** | [`docs/architecture/00_PROJECT_CONSTITUTION.md`](file:///home/hosam/StudioProjects/nexabiz/docs/architecture/00_PROJECT_CONSTITUTION.md) |
| **Package / Public API** | [`docs/architecture/01_PACKAGE_CONTRACT.md`](file:///home/hosam/StudioProjects/nexabiz/docs/architecture/01_PACKAGE_CONTRACT.md) |
| **Route / Navigation / Shell** | [`docs/architecture/02_NAVIGATION_CONTRACT.md`](file:///home/hosam/StudioProjects/nexabiz/docs/architecture/02_NAVIGATION_CONTRACT.md) |
| **UI / Page / Component / Tokens** | [`docs/architecture/03_UI_DESIGN_SYSTEM_CONTRACT.md`](file:///home/hosam/StudioProjects/nexabiz/docs/architecture/03_UI_DESIGN_SYSTEM_CONTRACT.md) |
| **Text / Labels / Localization** | [`docs/architecture/04_LOCALIZATION_CONTRACT.md`](file:///home/hosam/StudioProjects/nexabiz/docs/architecture/04_LOCALIZATION_CONTRACT.md) |
| **Tests / Change Process / Guardrails** | [`docs/architecture/05_TESTING_AND_CHANGE_CONTRACT.md`](file:///home/hosam/StudioProjects/nexabiz/docs/architecture/05_TESTING_AND_CHANGE_CONTRACT.md) |

## Mandatory Working Rules

Before changing a subsystem, read the relevant file in [`docs/rules/README.md`](docs/rules/README.md) and its linked architecture contract. The rules are operational instructions; `docs/architecture/00_PROJECT_CONSTITUTION.md` and contracts `01–05` retain the precedence stated below. Follow the documented capability, navigation, localization, UI, and module boundaries, then run the required validation and audit the diff.

---

## 2. Fundamental Principle

> **CHAT INSTRUCTIONS != ARCHITECTURE AUTHORITY**  
> **REPOSITORY CONTRACTS = ARCHITECTURE AUTHORITY**

The repository code and formal contracts in `docs/architecture/` are the single source of truth. You must never assume architecture or rely on memory of previous chat sessions.

---

## 3. Required Pre-Change Procedure

Every agent and human developer MUST follow this exact workflow sequence:

```text
READ
  ↓
DISCOVER
  ↓
TRACE
  ↓
CLASSIFY
  ↓
PLAN
  ↓
CHANGE
  ↓
TEST
  ↓
AUDIT DIFF
  ↓
REPORT
```

**NEVER**:
```text
GUESS  →  CREATE  →  FIX COMPILER ERRORS
```

---

## 4. Search Before Create Mandate

Before creating ANY page, widget, component, layout, dialog, sheet, route, helper, design token, formatter, validator, utility, service, controller, or package:
1. Search the existing codebase.
2. Classify the change as:
   - `REUSE_EXISTING`
   - `EXTEND_EXISTING`
   - `NEW_REQUIRED`
3. If classified as `NEW_REQUIRED`, you must provide structural justification in the Pre-Execution Change Manifest.

---

## 5. Non-Negotiable Rules

An agent or developer **MUST NOT**:

1. **Invent architecture** or create ad-hoc patterns outside official contracts.
2. **Bypass package boundaries** or import another package's internal `src/...` details.
3. **Directly import `shadcn_flutter`** inside feature code when `nexabiz_ui` provides an abstraction.
4. **Create custom page scaffolds** when canonical page primitives (`AppPage`, `AppListPage`, `AppFormPage`, etc.) satisfy the requirement.
5. **Add hardcoded user-visible strings** directly inside widgets/pages (all supported locales `en` & `ar` must be updated).
6. **Add routes outside the canonical router** or construct independent `Navigator`/`MaterialApp` widgets.
7. **Destroy navigation history** for normal page navigation (must use stack-preserving `context.push()`).
8. **Use stack reset / replacement** (`context.go()`) for ordinary feature page transitions.
9. **Directly call system termination** (`exit(0)` / raw `SystemNavigator.pop()`) outside `AppExitPopScope`.
10. **Change business logic merely to satisfy tests** or delete/skip failing tests.
11. **Self-bypass architecture guardrails** or weaken exception registries.
12. **Introduce a second localization system**, design system, router, or state-management framework.

---

## 6. Pre-Execution Change Manifest

For any non-trivial change, an agent MUST generate this manifest BEFORE writing code:

```text
CHANGE MANIFEST
Goal:
Owning layer:
Files expected to change:
Architecture contracts consulted:
Existing implementations searched:
Reuse classification: [REUSE_EXISTING | EXTEND_EXISTING | NEW_REQUIRED]
Public API impact:
Navigation impact:
Localization impact:
UI / Design System impact:
Tests required:
```

---

## 7. Post-Execution Implementation Report

Every significant task MUST conclude with:

```text
IMPLEMENTATION REPORT
Root cause / requirement:
Files changed:
Architecture decisions:
Public API changes:
Navigation changes:
Localization keys added:
UI / Design System changes:
Tests added/updated:
flutter analyze result:
flutter test result:
git diff --check result:
Known remaining debt:
```

---

## 8. Document Precedence

If a conflict arises between sources, follow this mandatory precedence order:

```text
00_PROJECT_CONSTITUTION.md
        ↓
Subsystem Contracts (01 - 05)
        ↓
Package README / Public API Contract
        ↓
Current Implementation Code
```

If code conflicts with the Constitution, report the conflict immediately.
