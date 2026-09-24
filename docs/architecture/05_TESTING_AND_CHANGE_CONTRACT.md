# 05 — TESTING AND CHANGE CONTRACT

## 1. TEST LAYER EXPECTATIONS

Every pull request or architectural change MUST provide automated tests matching its layer scope:
- **Shared Primitives & Tokens** (`packages/nexabiz_ui`): Unit and widget tests verifying token definitions, component contracts, responsive viewports, and RTL geometry (`packages/nexabiz_ui/test/`).
- **Page Layouts & Presentation**: Widget tests verifying page primitive rendering, loading states, error states, and RTL localization (`test/widgets/`, `test/packages/`).
- **Navigation Architecture**: Stack contract tests verifying `push()` history preservation, `pop()` unwinding, back interception, and exit scope behavior (`test/app/navigation_stack_contract_test.dart`).
- **Architecture Guardrails**: Executable lint/governance tests verifying package boundaries, router authority, design system encapsulation, hardcoded string detection, and governance integrity (`test/architecture/`, `test/app/architecture/`).

---

## 2. TEST INTEGRITY & NO-GAMING RULE

- **FORBIDDEN**: Deleting failing tests, skipping failing test cases (`@Skip()`), weakening assertions, or altering expected test values to match broken output.
- Failing tests are evidence of an implementation defect or architectural regression. They MUST trigger a root-cause fix inside the owning production layer.
- Changing business logic or architecture solely to satisfy a flawed test mock is prohibited.

---

## 3. EXECUTABLE ARCHITECTURE GUARDRAILS

Architecture guardrails are executable Dart tests located in `test/architecture/` and `test/app/architecture/`. They act as automated architectural enforcement:

| Guardrail ID | Test File | Responsibility |
| :--- | :--- | :--- |
| `RULE-01-PACKAGE-SRC-IMPORT` | `test/architecture/package_boundary_test.dart` | Ensures external code does not import `package:nexabiz_ui/src/...` directly. |
| `RULE-02-DEPRECATED-PAGE-WRAPPERS` | `test/architecture/canonical_page_architecture_guardrail_test.dart` | Prevents consumption or reintroduction of removed page wrappers. |
| `RULE-03-DIRECT-SHADCN` & `UI-01` | `test/app/architecture/ui_architecture_guardrails_test.dart` | Enforces design system encapsulation (no direct `shadcn_flutter` imports in features). |
| `RULE-04-HARDCODED-STRINGS` | `test/architecture/localization_hardcoded_string_guardrail_test.dart` | Scans presentation code for hardcoded string literals. |
| `RULE-05-GOVERNANCE-PROTECTION` | `test/architecture/governance_protection_guardrail_test.dart` | Protects `/AGENTS.md` and `docs/architecture/` contract files against unauthorized modification or deletion. |
| `RULE-06-HARDCODED-COLORS` | `test/architecture/token_breakpoint_rtl_guardrails_test.dart` | Prevents hardcoded `Color(0xFF...)` literals in presentation code. |
| `RULE-07-BREAKPOINT-AUTHORITY` | `test/architecture/token_breakpoint_rtl_guardrails_test.dart` | Enforces use of canonical `AppBreakpoints`. |
| `RULE-08-RTL-DIRECTIONALITY` | `test/architecture/token_breakpoint_rtl_guardrails_test.dart` | Enforces directional layout geometry (`EdgeInsetsDirectional`). |
| `NAV-01..07` | `test/app/architecture/navigation_architecture_guardrails_test.dart` | Verifies router registration, stack preservation, and exit scope restriction. |

---

## 4. MUTATION TESTING METHODOLOGY

For every newly created or updated architecture guardrail, its effectiveness MUST be proven through mutation testing:
1. **Introduce temporary violation**: Add a representative forbidden pattern (e.g. `Text('MUTATION_VIOLATION')` or `import 'package:nexabiz_ui/src/...'`).
2. **Execute guardrail test**: Run `flutter test <path_to_guardrail>`.
3. **Verify expected failure**: Ensure the test fails with the specific expected architectural error message.
4. **Revert mutation**: Remove the temporary violation.
5. **Verify pass**: Re-run the guardrail test and confirm a clean pass.

---

## 5. ARCHITECTURE EXCEPTION REGISTRY GOVERNANCE

Exceptions to architecture guardrails are centrally registered in `test/architecture/architecture_exception_registry.dart`.

Rules for exceptions:
- **NO SELF-AUTHORIZED EXCEPTIONS**: AI agents or developers MUST NOT add entries to `ArchitectureExceptionRegistry` to bypass failing guardrails for new code.
- **EXPLICIT SCOPE ONLY**: Exceptions require `ruleId`, exact `filePath`, `reason`, and `targetPhase`. Broad directory wildcard ignores are prohibited.
- **FAIL ON STALE EXCEPTIONS**: If a registered file is refactored and no longer violates the rule, the exception test fails until the stale entry is removed from the registry.

---

## 6. MANDATORY VALIDATION COMMANDS

Before committing code or submitting an implementation report, the developer or AI agent MUST execute:

```bash
flutter analyze
flutter test
git diff --check
```

All 3 commands MUST complete cleanly with **0 static analysis errors**, **0 test failures**, and **0 diff formatting issues**.

---

## 7. PRE-EXECUTION MANIFEST & POST-EXECUTION REPORT TEMPLATES

### Pre-Execution Change Manifest
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

### Post-Execution Implementation Report
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
