# Localized date-format presets (roadmap #615)

Item 7 of 10 in the "build the top 10 obvious roadmap utilities, run /finish after each" batch. Adds short/medium/long dashboard date presets without pulling in the heavyweight `intl` dependency (intentionally excluded from this package), with localization supplied by the caller.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/datetime/date_format_preset_utils.dart` (`DateFormatNames`, `formatDateShort/Medium/Long`), new test, barrel export, CODE_INDEX row, CHANGELOG entry.

**Design:** Because `intl` is excluded (pubspec comment documents the bloated dependency tree), localization is injected via an immutable `DateFormatNames` holding full/short month names (indexed by `month - 1`) and weekday names (indexed by `weekday - 1`, matching Dart's Mon=1..Sun=7). English is the default. `formatDateShort` is ISO `yyyy-MM-dd` (no names, locale-independent, lexically sortable); `formatDateMedium` is `Jun 10, 2026`; `formatDateLong` is `Wednesday, June 10, 2026`.

**Tests:** 6 cases — short ISO padding (incl. year < 1000 → `0999`), medium English, medium with French names, long English, weekday-index alignment (8th = Monday, 14th = Sunday). All pass; `flutter analyze` clean.

**Reviewer notes:** `DateFormatNames` length contract (12/12/7) is documented rather than asserted — a `List.length` cannot be evaluated in a const constructor's assert, and the constructor must stay const for the `english` default. A short custom list throws `RangeError` from the preset (documented). One file-level ignore `avoid_manual_date_formatting` with rationale (intl excluded by design — the manual formatting is the entire point of the utility).

No bug archive — task did not close a bugs/*.md file.
