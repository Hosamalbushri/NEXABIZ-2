# NexaBiz implementation rules

These mandatory working rules apply to models and developers. Read `AGENTS.md` first, then the relevant rules below and their linked architecture contracts before changing code. The contracts in `docs/architecture/` remain authoritative; these files do not create exceptions or replace them.

| Task | Rule | Authoritative contract |
| :--- | :--- | :--- |
| Any change | [00 Model workflow](00_MODEL_WORKFLOW_RULES.md) | [Constitution](../architecture/00_PROJECT_CONSTITUTION.md), [testing and change](../architecture/05_TESTING_AND_CHANGE_CONTRACT.md) |
| Capability or module | [01 Capability creation](01_CAPABILITY_CREATION_RULES.md) | [Constitution](../architecture/00_PROJECT_CONSTITUTION.md), [package contract](../architecture/01_PACKAGE_CONTRACT.md) |
| Route or back behavior | [02 Navigation](02_NAVIGATION_RULES.md) | [Navigation contract](../architecture/02_NAVIGATION_CONTRACT.md) |
| User-facing text | [03 Localization](03_LOCALIZATION_RULES.md) | [Localization contract](../architecture/04_LOCALIZATION_CONTRACT.md) |
| Page or component | [04 UI usage](04_UI_USAGE_RULES.md) | [UI design system contract](../architecture/03_UI_DESIGN_SYSTEM_CONTRACT.md) |
| Basic or business module scope | [05 Module boundaries](05_BASIC_MODULE_BOUNDARIES.md) | [Constitution](../architecture/00_PROJECT_CONSTITUTION.md), [package contract](../architecture/01_PACKAGE_CONTRACT.md) |

If a rule appears to conflict with a contract, follow the precedence in `AGENTS.md` and stop with `ARCHITECTURE DECISION REQUIRED` when implementation would violate that contract. `docs/architecture/08_TESTING_CONTRACT.md` is deprecated; use `05_TESTING_AND_CHANGE_CONTRACT.md`.
