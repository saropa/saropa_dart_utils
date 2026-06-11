# ENH-006: Stream debounce as an EXTENSION + `debounceDistinct` / `debounceAfterFirst`

**File (target):** `lib/async/stream_debounce_utils.dart`
**Type:** Enhancement / API-shape + Missing Variants
**Severity:** 🟡 Medium
**Status:** Fixed

---

## Summary

`debounceStream(stream, duration)` exists as a top-level **function**. Reactive code
reads far better as a `Stream<T>` **extension** (`stream.debounce(d)`), chainable with
`.distinct()` / `.map()`. Two debounce variants are also missing and are exactly what
a database-watch UI needs:

1. `debounce` as an extension method (call-site ergonomics).
2. `debounceDistinct(duration, {equals})` — debounce **and** suppress unchanged values.
3. `debounceAfterFirst(duration)` — emit the **first** value immediately, then debounce
   the tail. This is the correct shape for a `.watch()` stream that emits current state
   on subscribe (Drift, and Isar's `fireImmediately: true`): you want the initial render
   instant, but bulk writes coalesced.

---

## Absence Evidence

```bash
grep -rnE "extension .*on Stream|debounceDistinct|debounceAfterFirst" ../saropa_dart_utils/lib/async/
# 1.3.0 has only the top-level function debounceStream<T>(...); no extension, no variants
```

## Use Case (consumer's local implementation)

Saropa Contacts (`lib/utils/stream/stream_debounce_extensions.dart`) carries all three
**and a documented production bug-fix** the upstream function must preserve if the app
is to adopt it: the controller defers the upstream `listen()` until a consumer
subscribes (`onListen`), using a **single-subscription** controller. An earlier
broadcast-controller version that subscribed eagerly dropped the first emission when the
consumer subscribed late (a `StreamBuilder` inside a visibility-gated panel), leaving the
UI stuck in `ConnectionState.waiting` forever (perpetual spinner on empty-set panels).

```dart
extension StreamDebounceExtensions<T> on Stream<T> {
  Stream<T> debounce(Duration duration) { /* deferred-listen single-subscription */ }
  Stream<T> debounceDistinct(Duration d, {bool Function(T, T)? equals}) =>
      debounce(d).distinct(equals);
  Stream<T> debounceAfterFirst(Duration duration) { /* emit first now, debounce rest */ }
}
```

## Suggested API

Keep `debounceStream` (back-compat) and add a `StreamDebounceExtensions<T> on Stream<T>`
delegating to it, plus `debounceDistinct` and `debounceAfterFirst`. Verify/port the
deferred-listen + single-subscription semantics and add a regression test for the
"late subscriber must still get the first value" case.

## Missing Tests

- Late subscriber receives the first emission (the bug-fix above).
- `debounceAfterFirst`: first event immediate, subsequent burst coalesced to last.
- `debounceDistinct`: equal consecutive values suppressed; custom `equals`.
- Error forwarding and `onCancel` cleanup (timer + subscription cancelled).

## Environment

- saropa_dart_utils: 1.3.0
- Triggering consumer: Saropa Contacts `stream_debounce_extensions.dart`

---

## Finish Report (2026-06-11)

**Scope:** (A) Dart library code — `lib/` + `test/`. No Flutter UI, no l10n, no extension.

**What shipped:** Added `extension StreamDebounceExtensions<T> on Stream<T>` to the existing `stream_debounce_utils.dart` with `debounce(d)`, `debounceDistinct(d, {equals})`, and `debounceAfterFirst(d)`. `debounceStream` (the free function) is preserved unchanged for back-compat.

**Implementation notes — the production bug-fix is preserved by refactor, not re-derivation:**
- The existing `debounceStream` ALREADY had the load-bearing deferred-listen + single-subscription semantics (its `onListen` defers `source.listen`, the controller is single-subscription). That is exactly the fix the bug says must be preserved (a late subscriber to a visibility-gated `StreamBuilder` must still get the first emission, else perpetual `ConnectionState.waiting`).
- Rather than duplicate that machinery, I extracted the shared core into a private `_debounce<T>(source, duration, {required bool emitFirstImmediately})`. `debounceStream` now delegates with `emitFirstImmediately: false` (byte-for-byte same behavior — the 4 pre-existing tests still pass), and `debounceAfterFirst` delegates with `true`. Single source of truth for the controller/timer/cleanup logic; the deferred-listen comment now lives on the shared engine and explicitly says "do not switch to a broadcast controller."
- `debounce` delegates to `debounceStream`; `debounceDistinct` = `debounceStream(...).distinct(equals)`.

**Tests (Section 4):**
- Audit: the 4 existing `debounceStream` tests (burst-latest, gap-separated, trailing-flush-on-close, error-forwarding) are unchanged and still pass — confirming the refactor is behavior-preserving.
- Added a `StreamDebounceExtensions` group (6 cases): `debounce()` parity; the **late-subscriber-gets-first-value regression test** (value added to source before the debounced stream is listened to); `debounceAfterFirst` immediate-first-then-coalesce + trailing-flush-on-close; `debounceDistinct` equal-value suppression + custom `equals`.
- Ran `flutter test test/async/stream_debounce_utils_test.dart` → **All 10 tests passed**.
- Ran `dart analyze` → **No issues found**.

**Maintenance:** CHANGELOG 1.4.1 Added section updated. `stream_debounce_utils.dart` already exported. README verified — no updates needed.

**Dependency note:** Same `saropa_lints ^13.12.5` situation; committed pubspec keeps `^13.12.5`, local runs use `^13.12.3`.

**Outstanding:** None for ENH-006.
