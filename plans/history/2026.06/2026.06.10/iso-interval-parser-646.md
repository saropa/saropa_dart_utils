# ISO 8601 time-interval parser (roadmap #646)

Item 8 of the "next 10" roadmap-utilities batch. Parses the three ISO 8601 interval forms into a `DateTimeRange`, complementing the existing `parseDuration` (which reads `1.5h`-style, not ISO durations).

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/datetime/iso_interval_parse_utils.dart` (`parseIsoInterval`), new test, barrel export, CHANGELOG entry.

**Design:** `parseIsoInterval` splits on `/`, classifies each half by a leading `P` (duration marker), and dispatches: `start/end` parses both timestamps; `start/duration` applies the duration forward from start; `duration/end` applies it backward from end. Timestamps go through `DateTime.tryParse` (not `DateTime.parse`, which the analyzer flags as unvalidated). The duration is parsed by a structural regex into an `_IsoDuration` whose `applyTo(base, sign)` shifts calendar fields (years/months/days) via the `DateTime` constructor — so Jan 31 + P1M normalizes the way Dart's calendar math does — then adds the sub-day `time` portion as a fixed `Duration`. Weeks fold into days; time components may be fractional.

**Return type:** reuses Flutter's `DateTimeRange` (the package already depends on flutter and ships `DateTimeRangeExtensions`) rather than inventing a parallel pair type. `_range` rejects an inverted interval with a clear `FormatException` before `DateTimeRange`'s own assertion would.

**Distinction from `parseDuration`:** that helper reads informal `2d 3h 30m` strings into a `Duration`; this reads formal ISO 8601 durations *and* the full interval grammar (two endpoints), applying calendar units a flat `Duration` can't represent. No overlap.

**Tests:** 14 cases — start/end, start/duration with calendar-month normalization (Jan 31 + P1M = Mar 3), duration/end, combined date+time (P1DT12H), weeks folding (P2W), fractional time (PT1.5H), local-timestamp preservation, duration/end with years+months; 6 error cases (no separator, two durations, malformed timestamp, empty `P`, malformed duration `P1X`, inverted interval). All pass; `flutter analyze` clean.

**Reviewer notes:** the regex-captured numeric groups are parsed with `tryParse` + an unreachable `?? 0` fallback to satisfy the Error-level `prefer_try_parse_for_dynamic_data` lint (the `\d+` capture guarantees parseability; the fallback is dead but required). Two initial test failures were wrong expected `start` values in the test (asserted Jan 1 where inputs were Jan 31 / yielded Jan 15) — the parser was correct; tests fixed. Functions ≤20 lines aside from the two parallel UTC/local `DateTime` constructor arms in `applyTo`.

No bug archive — task did not close a bugs/*.md file.
