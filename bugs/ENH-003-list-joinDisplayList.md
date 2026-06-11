# ENH-003: `Iterable<String>.joinDisplayList(...)` — human-readable Oxford-comma join

**File (target):** `lib/list/list_string_extensions.dart`
**Type:** Enhancement / Missing Utility
**Severity:** 🟡 Medium
**Status:** Open

---

## Summary

`join()` produces `a, b, c`; there is no helper for the natural-language form
`a, b, and c` (or `a and b` for two items) with de-duplication and empty-trimming.
This is a common UI/display need ("shared with Alice, Bob, and Carol").

---

## Absence Evidence

```bash
grep -rn "joinDisplayList" ../saropa_dart_utils/lib/
# (no matches in 1.3.0)
```

## Use Case (consumer's local implementation)

Saropa Contacts (`lib/utils/primitive/string/string_list_utils.dart`) — note it is
already built **on top of** library primitives (`toUnique`, `takeSafe`, `nullIfEmpty`),
so it is a natural fit to absorb upstream:

```dart
String? joinDisplayList({
  String joiner = ', ',
  String doubleJoiner = ' and ',
  String lastJoiner = ', and ',   // Oxford comma
  bool isUnique = true,
}) {
  final List<String>? list = isUnique ? removeTrimmedEmpty()?.toUnique() : removeTrimmedEmpty();
  if (list == null || list.isEmpty) return null;
  if (list.length == 1) return list.firstOrNull;
  if (list.length == 2) return '${list.first}$doubleJoiner${list.last}';
  return list.takeSafe(list.length - 1).join(joiner) + lastJoiner + list.last;
}
```

## Suggested API

Add to the existing `List<String>` / `Iterable<String>` extension, with the joiners
as named params (defaults as above) so locale/style is caller-controlled. Reuse the
existing `toUnique` / `nullIfEmpty` internally. Returns `null` for an effectively-empty
input (distinct from `''`).

## Missing Tests

- 0 / 1 / 2 / 3+ items; duplicates with `isUnique` true/false; entries that are empty or
  whitespace-only (trimmed out); custom joiners; null-vs-empty return contract.

## Environment

- saropa_dart_utils: 1.3.0
- Triggering consumer: Saropa Contacts `string_list_utils.dart`
