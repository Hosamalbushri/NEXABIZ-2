# 00 — Mandatory model and developer workflow

Authority: [Project Constitution](../architecture/00_PROJECT_CONSTITUTION.md) and [Testing and Change Contract](../architecture/05_TESTING_AND_CHANGE_CONTRACT.md).

1. Read `AGENTS.md`, this index, and every architecture contract relevant to the change before editing.
2. Inspect the current implementation, its callers, tests, and existing reusable architecture. Follow `READ → DISCOVER → TRACE → CLASSIFY → PLAN → CHANGE → TEST → AUDIT DIFF → REPORT`.
3. Classify reuse as `REUSE_EXISTING`, `EXTEND_EXISTING`, or `NEW_REQUIRED`. Use the required Change Manifest before a non-trivial change. Justify every new file, abstraction, package, or dependency; package creation also requires the analysis in contract 01.
4. Touch only the requested subsystem. Do not build or refactor unrelated modules.
5. Fix production defects in their owning layer. Do not delete, skip, weaken, or change tests merely to make a build pass; do not self-authorize guardrail exceptions.
6. For an implementation, run `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze lib test`, `flutter test --no-pub --reporter expanded`, and `git diff --check`. Also satisfy any broader validation required by contract 05 and report environmental or pre-existing failures accurately. Audit the final diff and report changes and remaining limits.

Do not guess an architecture from the old project or a chat prompt. If the requested implementation conflicts with a higher contract, stop and report `ARCHITECTURE DECISION REQUIRED`.
