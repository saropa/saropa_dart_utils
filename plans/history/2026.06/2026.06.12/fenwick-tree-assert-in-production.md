# FenwickTree — assert-based bounds checks promoted to release-mode throws

`FenwickTree` guarded the index and range arguments of `update`, `prefixSum`, and
`rangeSum` with `assert`, which the Dart compiler strips from release builds. The
`avoid_assert_in_production` lint flagged all four call sites. In release mode the
stripped guards changed correctness, not just diagnostics: a negative `index`
passed to `update` makes the lowest-set-bit step `i & -i` evaluate to `0`, so the
walk loop `for (i = index + 1; i <= _size; i += i & -i)` never advances — an
infinite loop (a production hang), not a silent no-op. An out-of-range index to
`prefixSum` or `rangeSum` would walk the wrong nodes and return a silently wrong
sum. The bounds checks now run in every build.

## Finish Report (2026-06-12)

### Scope

(A) Dart library code — `lib/collections/`, `test/collections/`. No Flutter UI,
no VS Code extension, no l10n catalog in this package.

### Changes

- [fenwick_tree_utils.dart](lib/collections/fenwick_tree_utils.dart):
  - `update` — `assert(index >= 0 && index < _size, …)` replaced with an
    `if (index < 0 || index >= _size) throw RangeError(…)`. A comment records the
    specific release-mode failure mode (the `i & -i == 0` infinite loop on a
    negative index), since that is the reason the check must survive into release.
  - `prefixSum` — same assert-to-`RangeError` conversion; comment notes that an
    out-of-range index otherwise returns a silently wrong total.
  - `rangeSum` — the two asserts (`low` ordering, `high` upper bound) become two
    `if`/`throw RangeError` guards.
  - `valueAt` — its bounds assert is removed entirely rather than converted: the
    method delegates to `rangeSum(index, index)`, which now validates the same
    bounds, so a second check would duplicate the guard. A comment states the
    delegation enforces the bounds.
  - The initializer-list assert in the `FenwickTree(int size)` constructor
    (`assert(size >= 0, …)`) is unchanged — the lint does not flag asserts in
    constructor initializer lists, and that idiom is intentionally retained.
- [fenwick_tree_utils_test.dart](test/collections/fenwick_tree_utils_test.dart):
  the two `bounds` group tests previously expected `throwsA(isA<AssertionError>())`,
  which only held while asserts were enabled in the test VM. They now expect
  `throwsA(isA<RangeError>())`, pinning the release-mode behavior. Test names
  changed from "should assert …" to "should throw …".
- [CHANGELOG.md](CHANGELOG.md): entry added under `[Unreleased]` → Fixed.

### Verification

- `flutter analyze lib/collections/fenwick_tree_utils.dart test/collections/fenwick_tree_utils_test.dart`
  — no issues found.
- `flutter test test/collections/fenwick_tree_utils_test.dart` — 13/13 pass,
  including the two converted bounds tests.

### Outstanding

None. The behavior change is limited to invalid-argument paths (previously
unchecked in release, now throwing `RangeError`); all valid-input behavior is
unchanged and covered by the existing oracle test.
