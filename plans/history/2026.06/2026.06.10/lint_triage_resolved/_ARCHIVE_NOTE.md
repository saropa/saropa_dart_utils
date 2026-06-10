# Lint Triage — Archived 2026-06-10 (all resolved)

These 64 files were a saropa_lints violation-triage worklist generated against an
earlier audit of the codebase. On 2026-06-10 a full `dart run saropa_lints scan`
(insanity tier, current config) over all 360 `lib/` files plus a `test/` sample
reproduced **zero** of the documented violations — every rule they describe is
enabled yet fires 0 times now.

The prior audit commits (`fix(audit): eliminate false-positive findings; clear
today's utils`, `rebuild declaration matcher and test discovery`) had already
resolved or obsoleted the whole set. Spot-checks confirmed the triage was stale,
not the scanner (e.g. the days-in-month array in `date_time_utils.dart` is no
longer flagged by `avoid_duplicate_number_elements`; the `JsonIterablesUtils<T>`
class that `prefer_constrained_generics` targeted no longer exists).

Archived for the record. No code action was required from these files.

The live lint debt that the same scan *did* surface — 79 violations in different
rules (`prefer_explicit_type_arguments`, `prefer_list_first`, the error-logging
rules, etc.) — was addressed separately in the same session.
