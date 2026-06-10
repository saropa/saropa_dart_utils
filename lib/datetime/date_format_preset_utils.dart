/// Dashboard date-format presets (short / medium / long) — roadmap #615.
///
/// This package deliberately avoids the heavyweight `intl` dependency, so
/// localization is supplied by the caller through [DateFormatNames] rather than
/// loaded from a locale database. The English names are the default; pass a
/// localized [DateFormatNames] to render month and weekday names in any
/// language while keeping the preset layout fixed.
library;

import 'package:meta/meta.dart';

/// Month and weekday names used by the medium/long presets, injectable so the
/// presets can render in any language without a locale database.
///
/// [months] and [monthsShort] are indexed by `DateTime.month - 1` (Jan = 0).
/// [weekdays] is indexed by `DateTime.weekday - 1` (Monday = 0), matching
/// Dart's `DateTime.weekday` range of 1 (Mon) .. 7 (Sun).
@immutable
class DateFormatNames {
  /// Creates a name set. [months] and [monthsShort] must each have 12 entries
  /// and [weekdays] 7, so every month/weekday index is in range — a `List`
  /// length cannot be asserted in a const constructor, so this is a documented
  /// contract; a shorter list throws `RangeError` from the presets.
  const DateFormatNames({required this.months, required this.monthsShort, required this.weekdays});

  /// Full month names, January..December (index = month - 1).
  final List<String> months;

  /// Abbreviated month names, Jan..Dec (index = month - 1).
  final List<String> monthsShort;

  /// Full weekday names, Monday..Sunday (index = weekday - 1).
  final List<String> weekdays;

  /// English default used when no localized names are supplied.
  static const DateFormatNames english = DateFormatNames(
    months: <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ],
    monthsShort: <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ],
    weekdays: <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ],
  );
}

String _pad2(int n) => n.toString().padLeft(2, '0');

// intl is intentionally excluded from this package (see pubspec); these presets
// format manually by design, taking localization through DateFormatNames.
// ignore_for_file: avoid_manual_date_formatting -- intl excluded by design (#615)

/// Short preset: unambiguous ISO-8601 calendar date `yyyy-MM-dd`
/// (e.g. `2026-06-10`). No names, so it is locale-independent and sorts
/// lexically — ideal for compact dashboard columns.
String formatDateShort(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${_pad2(date.month)}-${_pad2(date.day)}';

/// Medium preset: abbreviated month, day, year (e.g. `Jun 10, 2026`). Month
/// name comes from [names], defaulting to English.
String formatDateMedium(DateTime date, {DateFormatNames names = DateFormatNames.english}) =>
    '${names.monthsShort[date.month - 1]} ${date.day}, ${date.year}';

/// Long preset: weekday, full month, day, year
/// (e.g. `Wednesday, June 10, 2026`). Weekday and month names come from
/// [names], defaulting to English.
String formatDateLong(DateTime date, {DateFormatNames names = DateFormatNames.english}) =>
    '${names.weekdays[date.weekday - 1]}, ${names.months[date.month - 1]} '
    '${date.day}, ${date.year}';
