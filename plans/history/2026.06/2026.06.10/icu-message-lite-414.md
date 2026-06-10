# ICU message-format lite (roadmap #414)

Item 8 of 10 in the "build the top 10 obvious roadmap utilities, run /finish after each" batch. Adds the practical ICU MessageFormat subset — plural form selection and `select` (gender/category) — that apps need for i18n, distinct from the existing naive `String.pluralize`.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/string/icu_message_utils.dart` (`icuPlural`, `icuSelect`), new test, barrel export, CODE_INDEX rows, CHANGELOG entry.

**Design:** `icuPlural(count, {zero, one, other})` applies English-style cardinal rules (zero form at 0 if provided, one form at 1, else other) then replaces every `#` in the chosen form with the count. `icuSelect(value, cases, {other})` is the general ICU `select` — `cases[value] ?? other` — with gender as the common case. No parser and no `intl`: the caller supplies the forms, so any language routes through `other` or passes the exact forms that matter.

**Tests:** 9 cases — plural zero-with-form, zero-without-form falls through, one form, other with `#` substitution, multiple `#`, verbatim one-without-`#`; select match, unknown→other, empty-map→other. All pass; `flutter analyze` clean.

**Reviewer notes:** Named `icuPlural`/`icuSelect` (not bare `plural`/`select`) to namespace the ICU-lite origin and avoid collisions with generic identifiers. Pure functions, no unsafe accessors (`cases[value] ?? other` is null-safe map lookup).

No bug archive — task did not close a bugs/*.md file.
