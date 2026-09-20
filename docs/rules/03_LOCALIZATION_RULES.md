# 03 — Localization

Authority: [Localization Contract](../architecture/04_LOCALIZATION_CONTRACT.md) and the current `lib/l10n/` implementation.

1. Every user-visible label, title, message, tooltip, and error in application presentation uses `AppLocalizations`. Do not add hardcoded user-visible strings or an English fallback inside widgets.
2. Add semantic, stable message keys to both `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb` before or with any new page. Their message key sets must match; include matching placeholder metadata where required. Regenerate the typed localization API.
3. Use ARB placeholders for dynamic sentences. Do not concatenate translated fragments into a sentence.
4. Keep technical identities such as `capabilityId`, `routeId`, URI paths, preference keys, and asset paths stable and untranslated. Never show a technical ID or `metadata.nameKey` directly as a user label.
5. Verify English LTR, Arabic RTL, text wrapping, and active navigation stack preservation on locale changes. Follow existing localization guardrails in `test/architecture/`.
