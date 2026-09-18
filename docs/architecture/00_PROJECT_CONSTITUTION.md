# 00 — NEXABIZ PROJECT CONSTITUTION

## 1. PURPOSE & AUTHORITY

This document establishes the **CONSTITUTIONAL ARCHITECTURE LAW** for the NexaBiz codebase.
These rules are **MANDATORY** for all human developers, AI coding agents, and automated transformation tools.

The single source of truth for repository architecture is:
```text
THE CURRENT REPOSITORY CODE & REPOSITORY-OWNED CONTRACTS IN docs/architecture/
```

Chat prompts, AI memory, external Clean Architecture templates, or historical ERP assumptions **DO NOT OVERRIDE** this Constitution.

If a task prompt requests a change that conflicts with this Constitution:
```text
STOP. Return: ARCHITECTURE DECISION REQUIRED
```

---

## 2. UNIVERSAL GOVERNANCE RULES

### Rule 1: Repository Source is Authoritative
Before writing or modifying ANY code:
1. Inspect the existing repository implementation.
2. Read the relevant contracts in `docs/architecture/`.
3. Do not invent non-existent abstractions, frameworks, or architectural layers.

### Rule 2: Pre-Change Discovery Workflow
Every non-trivial modification MUST follow this sequence:
```text
READ → DISCOVER → TRACE → CLASSIFY → PLAN → CHANGE → TEST → AUDIT DIFF → REPORT
```
Guessing implementation details or writing code without tracing callers and dependencies is prohibited.

### Rule 3: Search Before Create
Before creating ANY page, widget, layout, route, token, utility, service, validator, or package:
1. Search the existing codebase for a matching or extendable abstraction.
2. Classify the proposal:
   - `REUSE_EXISTING`
   - `EXTEND_EXISTING`
   - `NEW_REQUIRED`
3. Creating a new abstraction requires explicit justification in the Pre-Execution Change Manifest. Duplication ("AppDialog" vs "NewDialog") is strictly prohibited.

### Rule 4: Package Boundary Integrity
- `packages/nexabiz_ui` is the sole UI design system package.
- External code MUST import `nexabiz_ui` strictly through its public barrel (`package:nexabiz_ui/nexabiz_ui.dart`).
- Cross-package imports into `lib/src/` are prohibited.

### Rule 5: Navigation Authority & Stack Sacredness
- The application router (`NexaBizGoRouterAdapter`) is the single navigation authority.
- Hierarchical page navigation MUST preserve state and route history using stack-preserving push (`context.push()`).
- Stack reset / replacement (`context.go()`) is restricted to primary platform shell branch switching.
- System Back and App-Bar Back MUST yield identical navigation behavior.
- Application termination is strictly owned by `AppExitPopScope` (`SystemNavigator.pop()`). Direct calls to `exit(0)` are forbidden.

### Rule 6: UI Design System Authority
- Feature and application code MUST consume components, layout primitives, and design tokens from `nexabiz_ui`.
- Direct imports of `package:shadcn_flutter` inside feature code are prohibited. Missing capabilities must be reported as a UI Component Gap.

### Rule 7: Mandatory Multilingual Localization
- All user-visible strings MUST use the canonical localization system (`AppLocalizations`).
- Hardcoded user-visible string literals (in English, Arabic, or any language) are prohibited in presentation code.
- Every new localization key MUST be added to ALL supported locales (`en`, `ar`) simultaneously.
- Sentence concatenation is prohibited; localized strings must use parameterized templates.

### Rule 8: Directional & Responsive Layouts
- Layouts must support LTR and RTL seamlessly using directional primitives (`EdgeInsetsDirectional`, `AlignmentDirectional`).
- Breakpoints and viewports must be governed by `AppBreakpoints`. Custom width checks or ad-hoc media query comparisons are prohibited.

### Rule 9: Test Integrity & Guardrail Protection
- Failing tests are evidence of defect or regression. Deleting tests, skipping tests (`@Skip()`), or weakening assertions to pass builds is prohibited.
- Executable architecture guardrails in `test/architecture/` are part of the governance contract. Bypassing or weakening exception registries without explicit approval is an architecture violation.

### Rule 10: Diff Audit & Minimal Compliance
- Modifications MUST be minimal and directly scoped to the requested change.
- Unrelated refactoring, code formatting re-writes, or arbitrary re-namings are prohibited.
- Before declaring a task complete, every change MUST pass `flutter analyze`, `flutter test`, and `git diff --check`.

---

## 3. CONSTITUTIONAL PRECEDENCE

If a conflict arises between files, resolve using this mandatory precedence hierarchy:

```text
00_PROJECT_CONSTITUTION.md
        ↓
Subsystem Contracts (01_PACKAGE_CONTRACT ... 05_TESTING_AND_CHANGE_CONTRACT)
        ↓
Public Package APIs (package:nexabiz_ui/nexabiz_ui.dart, etc.)
        ↓
Current Production Implementation
```
