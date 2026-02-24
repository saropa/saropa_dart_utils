import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/json/json_epoch_scale.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Milliseconds per second, used for epoch timestamp conversion.
const int _millisecondsPerSecond = 1000;

/// Utility class for converting JSON-decoded values to specific Dart types.
abstract final class JsonTypeUtils {
  /// Returns a list of maps extracted from [valueList], or `null` if empty
  /// or `null`.
  @useResult
  static List<Map<String, dynamic>>? toListMap(List<Object?>? valueList) {
    if (valueList == null) return null;

    final List<Map<String, dynamic>> result = valueList.whereType<Map<String, dynamic>>().toList();

    return result.isEmpty ? null : result;
  }

  /// Returns the item count from [json], which may be an iterable or a
  /// [separator]-delimited string.
  @useResult
  static int countIterableJson(Object? json, {String separator = ','}) {
    if (json == null) return 0;
    if (json is Iterable) return json.length;
    if (json is String) {
      return json.split(separator).where((String s) => s.trim().isNotEmpty).length;
    }

    return 0;
  }

  /// Returns a list of strings parsed from [json], splitting on [separator]
  /// if the value is a string, or `null` if conversion is not possible.
  @useResult
  static List<String>? toStringListJson(
    Object? json, {
    String separator = ',',
  }) {
    if (json == null) return null;
    if (json is List<String>) return json;
    if (json is List && json.every((Object? e) => e is String)) {
      return json.cast<String>().toList();
    }

    if (json is Iterable<String>) return json.toList();
    if (json is String) {
      return json
          .split(separator)
          .map((String s) => s.trim())
          .where((String s) => s.isNotEmpty)
          .toList();
    }

    return null;
  }

  /// Returns a list of integers parsed from [json], or `null` if conversion
  /// is not possible.
  @useResult
  static List<int>? toIntListJson(Object? json) {
    if (json == null) return null;
    if (json is List<int>) return json;
    if (json is List) return json.map(toIntJson).whereType<int>().toList();
    if (json is String) {
      return json.split(',').map((String s) => int.tryParse(s.trim())).whereType<int>().toList();
    }

    return null;
  }

  /// Returns an integer parsed from [json], or `null` if conversion is not
  /// possible.
  @useResult
  static int? toIntJson(Object? json) {
    if (json == null) return null;
    if (json is int) return json;
    if (json is double) return json.toInt();
    if (json is String) return int.tryParse(json);

    return null;
  }

  /// Returns a boolean parsed from [json], using [isCaseSensitive] to control
  /// string comparison, or `null` if conversion is not possible.
  @useResult
  static bool? toBoolJson(Object? json, {bool isCaseSensitive = true}) {
    if (json == null) return null;
    if (json is bool) return json;
    if (json is int) return json == 1;
    final String str = json.toString();

    return str == '1' || (isCaseSensitive ? str == 'true' : str.toLowerCase() == 'true');
  }

  /// Returns a double parsed from [json], or `null` if conversion is not
  /// possible.
  @useResult
  static double? toDoubleJson(Object? json) {
    if (json == null) return null;

    return double.tryParse(json.toString());
  }

  /// Returns a list of doubles parsed from [json], or `null` if conversion
  /// is not possible.
  @useResult
  static List<double>? toDoubleListJson(Object? json) {
    if (json == null) return null;
    if (json is List<double>) return json;
    if (json is List) {
      return json.map(toDoubleJson).whereType<double>().toList();
    }

    if (json is String) {
      return json
          .split(',')
          .map((String s) => double.tryParse(s.trim()))
          .whereType<double>()
          .toList();
    }

    return null;
  }

  /// Returns a string from [json] with optional transformations controlled
  /// by [shouldTrim], [shouldUppercase], [shouldLowercase], and
  /// [shouldCapitalize], or `null` if the result is empty.
  @useResult
  static String? toStringJson(
    Object? json, {
    bool shouldTrim = true,
    bool shouldUppercase = false,
    bool shouldLowercase = false,
    bool shouldCapitalize = false,
  }) {
    if (json == null) return null;

    String result = json is String ? json : json.toString();
    if (shouldTrim) result = result.trim();
    if (shouldUppercase) {
      result = result.toUpperCase();
    } else if (shouldLowercase) {
      result = result.toLowerCase();
    } else if (shouldCapitalize) {
      result = _capitalizeWords(result);
    }

    return result.isEmpty ? null : result;
  }

  /// Capitalizes the first letter of each word in [input].
  static String _capitalizeWords(String input) => input
      .split(' ')
      .map(
        (String w) {
          if (w.isEmpty) return w;

          // Uses subscript because .first is not available on String
          // ignore: prefer_list_first
          return '${w[0].toUpperCase()}${w.substringSafe(1).toLowerCase()}';
        },
      )
      .join(' ');

  /// Returns a [DateTime] parsed from [json], or `null` if conversion is not
  /// possible.
  @useResult
  static DateTime? toDateTimeJson(Object? json) {
    if (json == null) return null;
    if (json is DateTime) return json;
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);

    final String? str = toStringJson(json);
    if (str == null || str.isEmpty) return null;

    return DateTime.tryParse(str);
  }

  /// Returns a [DateTime] from the epoch timestamp [json] interpreted at the
  /// given [scale], or `null` if [json] is not a valid integer.
  @useResult
  static DateTime? toDateTimeEpochJson(Object? json, JsonEpochScale scale) {
    if (json is! int) return null;

    return switch (scale) {
      JsonEpochScale.seconds => DateTime.fromMillisecondsSinceEpoch(
        json * _millisecondsPerSecond,
      ),
      JsonEpochScale.milliseconds => DateTime.fromMillisecondsSinceEpoch(json),
      JsonEpochScale.microseconds => DateTime.fromMicrosecondsSinceEpoch(json),
    };
  }

  /// Returns [value] as a list if it is one, or `null` otherwise.
  @useResult
  static List<Object?>? toListDynamic(Object? value) => value is List ? value : null;
}
