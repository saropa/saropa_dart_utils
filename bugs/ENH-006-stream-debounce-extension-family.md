# ENH-006: Stream debounce as an EXTENSION + `debounceDistinct` / `debounceAfterFirst`

**File (target):** `lib/async/stream_debounce_utils.dart`
**Type:** Enhancement / API-shape + Missing Variants
**Severity:** 🟡 Medium
**Status:** Open

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
