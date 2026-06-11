# SPEC: timezone_utils (TimezoneUtils + extensions) — for inclusion

**Status:** Rejected as proprietary / concept already in library (from Saropa Contacts)
**Proposed location:** n/a — nothing net-new to add
**Portability:** Flutter + Saropa app data. The source pulls in `package:timezone`, `package:collection`, and a chain of Saropa app types (`CountryEnum`, `TimezoneModel`, `staticDataTimezones`, `CountryTimezoneDSTModel`, `TimezoneSortOption`, `SortDirectionOptional`) plus `debug()`/`debugException()` from `utils/_dev/debug.dart`. It is NOT pure Dart and NOT general-purpose.

## Purpose — assessment

`d:/src/contacts/lib/utils/primitive/timezone/timezone_utils.dart` is a domain helper for the Saropa Contacts world-clock / country-timezone feature. It maps a Saropa `CountryEnum` to its IANA timezone names, looks up Saropa's hand-maintained `TimezoneModel` records out of `staticDataTimezones`, computes daylight-saving-time rollovers against Saropa's `CountryTimezoneDSTModel` data, and sorts `List<TimezoneModel>` by Saropa's `TimezoneSortOption` / `SortDirectionOptional` enums.

Every public member is bound to app-specific types or app-specific static data. There is no member that operates on a plain `DateTime`, `Duration`, or `String` in a way the library could reuse. Therefore nothing here qualifies for `saropa_dart_utils`.

### Excluded members (all of them) + why

| Member | Why excluded |
|---|---|
| `TimezoneUtils.initTimeZones()` | Thin wrapper over `package:timezone`'s `tz.initializeTimeZones()` + `debugException`. App glue, no logic to test. |
| `TimezoneUtils.getCountryTimezones({CountryEnum country})` | Returns `List<TimezoneModel>?`; depends on Saropa `CountryEnum`, `countryTimezoneNames`, `staticDataTimezones`. Proprietary data lookup. |
| `TimezoneUtils.getTimezoneByName({String? name})` | Searches Saropa's `staticDataTimezones` for a `TimezoneModel`. Proprietary. |
| `TimezoneModelSortExtensions.getTimezoneByCode({String? code})` | Extension on `List<TimezoneModel>` (Saropa type). Proprietary. |
| `TimezoneModelSortExtensions.sortByTimezone(TimezoneSortOption)` | Sorts Saropa `TimezoneModel` by Saropa `TimezoneSortOption`. Proprietary. |
| `TimezoneModelSortExtensions.toSortedUTC({SortDirectionOptional})` | Same, keyed on Saropa `SortDirectionOptional`. Proprietary. |
| `TimezoneExtensions.countryDstTime({CountryEnum country, DateTime? now})` | Extension on Saropa `TimezoneModel`; uses Saropa DST data + `CountryTimezonesDSTUtils`. Proprietary. |

## Overlap with installed library (saropa_dart_utils 1.4.1)

The library's `datetime/` category is already large (35 files) and includes a timezone helper:

- `lib/datetime/date_time_timezone_extensions.dart` — `DateTimeTimezoneOffsetExtensions.timeZoneOffsetString` already formats a local UTC offset as a `±HH:MM` string (e.g. `+01:00`, `-05:30`) from a plain `DateTime.timeZoneOffset`.

The only transferable idea inside `timezone_utils.dart` is offset formatting, and a cleaner, pure-`DateTime` version of that already ships in the library. The Saropa `TimezoneModel.utcOffsetDisplay` / `utcOffsetMins` logic (the part the existing test below exercises) lives on the Saropa `TimezoneModel` class itself, not in this util file, and is bound to Saropa's decimal-notation offset convention (e.g. `10.3` means 10h30m) — not a general convention worth lifting.

**Conclusion: already-in-library (for the only general concept) + proprietary (for the rest). No net-new util proposed.**

## Source (from Saropa Contacts) — debug logging stripped

Included only for the record. None of this is proposed for inclusion; every member is bound to Saropa app types or static data.

```dart
abstract final class TimezoneUtils {
  /// Kept async so callers can uniformly `await` timezone init; body is synchronous today.
  static Future<void> initTimeZones() async {
    try {
      // ref: https://pub.dev/packages/timezone
      tz.initializeTimeZones();
    } on Object catch (error, stack) {
      // (debug logging stripped)
    }
  }

  static List<TimezoneModel>? getCountryTimezones({required CountryEnum country}) {
    try {
      final List<String>? timezoneNames = countryTimezoneNames(country: country);
      if (timezoneNames == null || timezoneNames.isEmpty) {
        // country has no time zones
        return null;
      }

      final List<TimezoneModel> found = timezoneNames
          .map((String name) => getTimezoneByName(name: name))
          .nonNulls
          .toList();
      if (found.isEmpty) {
        return null;
      }

      return found;
    } on Object catch (error, stack) {
      // (debug logging stripped)
      return null;
    }
  }

  static TimezoneModel? getTimezoneByName({required String? name}) {
    try {
      if (name.isNullOrEmpty) {
        return null;
      }

      final TimezoneModel? tz = staticDataTimezones.firstWhereOrNull(
        (TimezoneModel t) => t.name == name || t.nameAlternate == name,
      );

      if (tz == null) {
        // (debug logging stripped)
        return null;
      }

      return tz;
    } on Object catch (error, stack) {
      // (debug logging stripped)
      return null;
    }
  }
}

extension TimezoneModelSortExtensions on List<TimezoneModel> {
  /// NOTE: cannot get on ALL timezones because timezones are reused!
  TimezoneModel? getTimezoneByCode({required String? code}) {
    try {
      if (code.isNullOrEmpty) {
        return null;
      }

      final TimezoneModel? tz = firstWhereOrNull(
        (TimezoneModel t) => t.code == code || t.codeAlternate == code,
      );

      if (tz == null) {
        // (debug logging stripped)
        return null;
      }

      return tz;
    } on Object catch (error, stack) {
      // (debug logging stripped)
      return null;
    }
  }

  /// Sorts the list of timezones based on the specified option.
  /// The primary sort is by time/offset, and the secondary sort is by name.
  void sortByTimezone(TimezoneSortOption option) {
    if (option == TimezoneSortOption.None) {
      return;
    }

    sort((TimezoneModel a, TimezoneModel b) {
      switch (option) {
        case TimezoneSortOption.Ascending:
          final int compAsc = a.utcOffset.compareTo(b.utcOffset);
          return compAsc == 0 ? a.name.compareTo(b.name) : compAsc;

        case TimezoneSortOption.Descending:
          final int compDesc = b.utcOffset.compareTo(a.utcOffset);
          return compDesc == 0 ? a.name.compareTo(b.name) : compDesc;

        case TimezoneSortOption.AscendingTimeOnly:
          final int compTimeAsc = a.utcTime().compareTo(b.utcTime());
          return compTimeAsc == 0 ? a.name.compareTo(b.name) : compTimeAsc;

        case TimezoneSortOption.DescendingTimeOnly:
          final int compTimeDesc = b.utcTime().compareTo(a.utcTime());
          return compTimeDesc == 0 ? a.name.compareTo(b.name) : compTimeDesc;

        case TimezoneSortOption.None:
          return 0;
      }
    });
  }

  bool toSortedUTC({SortDirectionOptional sortDirection = SortDirectionOptional.Ascending}) {
    try {
      if (sortDirection == SortDirectionOptional.None) {
        // unchanged list
        return true;
      }

      sort((TimezoneModel a, TimezoneModel b) {
        return switch (sortDirection) {
          SortDirectionOptional.None => 0,
          SortDirectionOptional.Ascending => a.utcOffset.compareTo(b.utcOffset),
          SortDirectionOptional.Descending => b.utcOffset.compareTo(a.utcOffset),
        };
      });

      return true;
    } on Object catch (error, stack) {
      // (debug logging stripped)
      return false;
    }
  }
}

extension TimezoneExtensions on TimezoneModel {
  // returns null if the country is NOT in DST time
  DateTime? countryDstTime({required CountryEnum country, DateTime? now}) {
    try {
      now ??= DateTime.now();

      final bool inDaylightSavingTime = timezoneDSTRange?.inRange(now) ?? false;
      if (!inDaylightSavingTime) {
        return null;
      }

      final String? dstCode = inDaylightSavingTime ? timezoneDSTCode : null;
      if (dstCode == null) {
        return null;
      }

      final CountryTimezoneDSTModel? dstTimezone = CountryTimezonesDSTUtils.findCountryTimezonesDST(
        country: country,
        dstCode: dstCode,
      );
      if (dstTimezone == null) {
        // (debug logging stripped)
        return null;
      }

      return dstTimezone.timezoneDSTTime(now: now);
    } on Object catch (error, stack) {
      // (debug logging stripped)
      return null;
    }
  }
}
```

## Test cases — existing tests (verbatim)

The only timezone test in the repo is `test/lib/models/timezone/timezone_model_logic_test.dart`, and it exercises the Saropa `TimezoneModel` class (its `utcOffsetMins` / `utcOffsetDisplay` / `displayCode` / `utcOffsetDuration` / `utcOffsetHoursDiff` getters) — NOT `timezone_utils.dart`. There are no tests for `TimezoneUtils` or its extensions. Included here only to show what coverage exists, and to underline that it targets a proprietary type:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa/models/timezone/timezone_model.dart';

void main() {
  group('TimezoneModel Logic Tests', () {
    test('utcOffsetMins calculates minutes from decimal notation', () {
      // 10.30 => 10 hours + 30 minutes => 630 minutes
      final TimezoneModel tz = TimezoneModel(name: 'Test Zone', utcOffset: 10.3, code: 'TZ');
      expect(tz.utcOffsetMins, equals(630));
    });

    test('utcOffsetMins handles no minutes component', () {
      final TimezoneModel tz = TimezoneModel(name: 'UTC Zone', utcOffset: 5, code: 'UTC5');
      // 5.00 => 5 hours => 300 minutes
      expect(tz.utcOffsetMins, equals(300));
    });

    test('utcOffsetDisplay formats positive offsets with plus prefix', () {
      final TimezoneModel tz = TimezoneModel(name: 'UTC+5', utcOffset: 5, code: 'UTC5');
      expect(tz.utcOffsetDisplay, equals('+5'));
    });

    test('utcOffsetDisplay formats minutes correctly', () {
      final TimezoneModel tz = TimezoneModel(name: 'UTC+5:30', utcOffset: 5.3, code: 'UTC530');
      expect(tz.utcOffsetDisplay, equals('+5:30'));
    });

    test('displayCode uses formatPrecision for UTC label', () {
      final TimezoneModel tz = TimezoneModel(name: 'UTC+5:30', utcOffset: 5.3, code: 'UTC530');
      // formatPrecision(2) keeps trailing minutes => 5.30
      expect(tz.displayCode, equals('UTC530 (UTC 5.30)'));
    });

    test('utcOffsetDuration matches utcOffsetMins', () {
      final TimezoneModel tz = TimezoneModel(
        name: 'Test Zone',
        utcOffset: 4.45, // 4 hours 45 minutes => 285 mins
        code: 'TZ445',
      );
      expect(tz.utcOffsetMins, equals(285));
      expect(tz.utcOffsetDuration.inMinutes, equals(285));
    });

    test('utcOffsetHoursDiff returns zero when identical to system offset', () {
      final DateTime now = DateTime.now();
      // Construct utcOffset equal to local offset
      final int localOffsetMinutes = now.timeZoneOffset.inMinutes; // e.g., -480 for PST
      final int hours = localOffsetMinutes ~/ 60;
      final int minutes = localOffsetMinutes % 60;
      final double utcOffset = double.tryParse('$hours.${minutes.toString().padLeft(2, '0')}') ?? 0;
      final TimezoneModel tz = TimezoneModel(
        name: 'Local Mirror',
        utcOffset: utcOffset,
        code: 'LOCAL',
      );
      expect(tz.utcOffsetHoursDiff(now: now), equals(0));
    });
  });
}
```

## Bulletproofing gaps — n/a (nothing proposed)

No new util is proposed, so there is no library-side coverage to harden.

If the library team later wants a general-purpose **UTC-offset string formatter** beyond the existing `DateTimeTimezoneOffsetExtensions.timeZoneOffsetString`, the edge cases that the existing single-line implementation should be stress-tested against are recorded here for convenience (these belong on the existing extension, not on a new lift of `timezone_utils.dart`):

- Zero offset (`Duration.zero`) → must render `+00:00`, never `-00:00`.
- Negative sub-hour offset (e.g. `-Duration(minutes: 30)`) → sign and minutes derived independently so the result is `-00:30`, not `+00:30` or `-0:-30`.
- Half-hour and 45-minute zones (`+05:30`, `+05:45`, `-09:30`) → minutes padded to two digits.
- Whole-hour double-digit zones (`+14:00` Line Islands max, `-12:00` min) → boundary extremes that are still valid IANA offsets.
- Out-of-range / synthetic durations (`+25:00`, `-13:00`) → define behavior (clamp vs. pass-through) explicitly.
- Hour padding for single-digit hours (`+01:00` not `+1:00`).
- DST transition instants → `DateTime.timeZoneOffset` is read at a single instant; document that the formatter reflects the offset of THAT instant, not a zone's year-round average.

These are notes for the existing `datetime/date_time_timezone_extensions.dart`, not a request to import the proprietary Saropa file.
