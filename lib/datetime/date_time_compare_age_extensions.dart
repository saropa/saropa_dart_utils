import 'package:meta/meta.dart';

/// A nulls-LAST nullable [DateTime] comparator with a direction flag.
///
/// Distinct from `compareDateTimeNullable` (in
/// `date_time_nullable_extensions.dart`), which places `null` FIRST and has no
/// direction option. Use this when missing dates should sink to the bottom of a
/// list regardless of sort direction — e.g. "entries with no date last."
///
/// Ordering:
/// - Two `null`s are equal (`0`).
/// - Exactly one `null` sorts LAST: a `null` [a] returns `1`, a `null` [b]
///   returns `-1`. This happens BEFORE the [ascending] multiplier is applied,
///   so flipping direction never floats a `null` to the top.
/// - Two non-null values compare by absolute instant ([DateTime.compareTo]),
///   then the sign is flipped when [ascending] is `false`.
///
/// "Age" is only the originating call site's name; there is no birthday or
/// calendar-day logic here. Comparison is instant-based, so two values that
/// represent the same moment in different time zones (UTC vs local) compare
/// equal, and a DST transition does not affect ordering — only the underlying
/// instant matters. A one-microsecond difference yields a non-zero result; no
/// truncation to seconds or days occurs.
///
/// Example:
/// ```dart
/// final DateTime older = DateTime.utc(1990, 1, 1);
/// final DateTime newer = DateTime.utc(2020, 6, 15);
///
/// compareAges(older, newer);                   // < 0 (older first)
/// compareAges(older, newer, ascending: false); // > 0 (newer first)
/// compareAges(null, newer);                     //  1 (null last)
/// compareAges(older, null, ascending: false);  // -1 (null still last)
/// compareAges(null, null);                      //  0
/// ```
@useResult
int compareAges(DateTime? a, DateTime? b, {bool ascending = true}) {
  // Null handling runs before the direction multiplier so nulls stay LAST in
  // both directions — applying `* -1` to these returns would float a null to
  // the top in descending order, which is the opposite of "nulls last".
  if (a == null) {
    if (b == null) {
      return 0;
    }
    return 1; // a is null -> a sorts last
  }
  if (b == null) {
    return -1; // b is null -> b sorts last
  }

  // Both non-null: instant comparison, flipped for descending order.
  return a.compareTo(b) * (ascending ? 1 : -1);
}
