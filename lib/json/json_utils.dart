import 'dart:convert' as dc;

import 'package:flutter/foundation.dart';
import 'package:saropa_dart_utils/map/map_extensions.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Scale for epoch timestamp parsing.
enum JsonEpochScale {
  /// Seconds since Unix epoch.
  seconds,

  /// Milliseconds since Unix epoch.
  milliseconds,

  /// Microseconds since Unix epoch.
  microseconds,
}

/// Utility class for JSON encoding of iterables.
class JsonIterablesUtils<T> {
  /// Returns the JSON-encoded string representation of [iterable].
  ///
  /// The elements of [iterable] (type [T]) must be directly encodable by
  /// `dart:convert.jsonEncode` (e.g., `num`, `String`, `bool`, `null`,
  /// `List`, or `Map` with encodable keys and values).
  static String jsonEncode<T>(Iterable<T> iterable) => dc.jsonEncode(iterable.toList());
}

/// Utility class for JSON parsing and type conversion.
class JsonUtils {
  const JsonUtils._();

  /// Returns a decoded `Map` from the given [jsonString], or `null` if
  /// decoding fails.
  static Map<String, dynamic>? jsonDecodeToMap(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    final dynamic decoded = jsonDecodeSafe(jsonString);
    if (decoded == null) return null;
    return MapUtils.toMapStringDynamic(decoded);
  }

  /// Safely decodes a JSON string, returning null on error.
  static dynamic jsonDecodeSafe(String? jsonString) {
    jsonString = jsonString?.trim();
    if (jsonString == null || jsonString.isEmpty || jsonString == 'null') return null;
    if (!isJson(jsonString)) return null;
    try {
      return dc.jsonDecode(jsonString);
    } on Object catch (e, stackTrace) {
      // debugPrint is appropriate for utility packages (stripped in release builds, no external dependencies)
      // ignore: saropa_lints/avoid_print_error
      debugPrint('JsonUtils.jsonDecodeSafe failed: $e\n$stackTrace');
      return null;
    }
  }

  /// Returns `true` if [value] appears to be valid JSON.
  ///
  /// If [testDecode] is `true`, actually attempts to decode to verify.
  /// If [allowEmpty] is `true`, treats `'{}'` and `'[]'` as valid JSON
  /// (defaults to `false` for backwards compatibility).
  static bool isJson(String? value, {bool testDecode = false, bool allowEmpty = false}) {
    if (value == null || value.length < 2) return false;
    final String trimmed = value.trim();
    final bool isObject = trimmed.startsWith('{') && trimmed.endsWith('}');
    final bool isArray = trimmed.startsWith('[') && trimmed.endsWith(']');
    if (!isObject && !isArray) return false;
    if (isObject && !trimmed.contains(':')) {
      // Empty object '{}' is valid JSON only if allowEmpty is true
      if (!allowEmpty || trimmed != '{}') return false;
    }
    if (isArray && trimmed == '[]') {
      // Empty array '[]' is valid JSON only if allowEmpty is true
      if (!allowEmpty) return false;
    }
    if (!testDecode) return true;
    try {
      return dc.jsonDecode(value) != null;
    } on Object catch (e, stackTrace) {
      // debugPrint is appropriate for utility packages (stripped in release builds, no external dependencies)
      // ignore: saropa_lints/avoid_print_error
      debugPrint('JsonUtils.isJson testDecode failed: $e\n$stackTrace');
      return false;
    }
  }

  /// Returns a cleaned version of the JSON response [value] by stripping
  /// outer double-quotes and unescaping any inner escaped quotes (`\"`),
  /// or `null` if the result is empty.
  ///
  /// Correctly handles strings that contain escaped inner quotes, e.g.:
  /// `'"hello \"world\""'` → `'hello "world"'`.
  static String? cleanJsonResponse(String? value) {
    if (value == null || value.isEmpty) return null;
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    // Detect outer quotes BEFORE unescaping inner ones.
    if (trimmed.startsWith('"') && trimmed.endsWith('"') && trimmed.length >= 2) {
      final String inner = trimmed.substringSafe(1, trimmed.length - 1);
      return inner.replaceAll(r'\"', '"').nullIfEmpty();
    }

    // No outer quotes — just unescape any escaped quotes present.
    return trimmed.replaceAll(r'\"', '"').nullIfEmpty();
  }

  /// Returns a decoded `Map` from the JSON string [value], optionally
  /// cleaning the input first when [cleanInput] is `true`, or `null` if
  /// decoding fails.
  static Map<String, dynamic>? tryJsonDecode(String? value, {bool cleanInput = false}) {
    if (value == null || value.isEmpty) return null;
    if (cleanInput) {
      final String? cleaned = cleanJsonResponse(value);
      if (cleaned == null || cleaned.isEmpty) return null;
      return jsonDecodeToMap(cleaned);
    }
    return jsonDecodeToMap(value);
  }

  /// Returns a list of maps decoded from the JSON string [value], or `null`
  /// if decoding fails.
  static List<Map<String, dynamic>>? tryJsonDecodeListMap(String? value) {
    if (value == null || !isJson(value)) return null;
    try {
      final dynamic data = dc.json.decode(value);
      if (data is! List || data.isEmpty || data[0] is! Map<String, dynamic>) return null;
      if (!data.every((dynamic e) => e is Map<String, dynamic>)) return null;
      return data.cast<Map<String, dynamic>>().toList();
    } on Object catch (e, stackTrace) {
      // debugPrint is appropriate for utility packages (stripped in release builds, no external dependencies)
      // ignore: saropa_lints/avoid_print_error
      debugPrint('JsonUtils.tryJsonDecodeListMap failed: $e\n$stackTrace');
      return null;
    }
  }

  /// Returns a list of strings decoded from the JSON string [value], or
  /// `null` if decoding fails.
  static List<String>? tryJsonDecodeList(String? value) {
    if (value == null || !isJson(value)) return null;
    try {
      final dynamic data = dc.json.decode(value);
      if (data is! List || data.isEmpty) return null;
      if (!data.every((dynamic e) => e is String)) return null;
      return data.cast<String>().toList();
    } on Object catch (e, stackTrace) {
      // debugPrint is appropriate for utility packages (stripped in release builds, no external dependencies)
      // ignore: saropa_lints/avoid_print_error
      debugPrint('JsonUtils.tryJsonDecodeList failed: $e\n$stackTrace');
      return null;
    }
  }

  /// Returns a list of maps extracted from [valueList], or `null` if empty
  /// or `null`.
  static List<Map<String, dynamic>>? toListMap(List<dynamic>? valueList) {
    if (valueList == null) return null;
    final List<Map<String, dynamic>> result = valueList.whereType<Map<String, dynamic>>().toList();
    return result.isEmpty ? null : result;
  }

  /// Returns the item count from [json], which may be an iterable or a
  /// [separator]-delimited string.
  static int countIterableJson(dynamic json, {String separator = ','}) {
    if (json == null) return 0;
    if (json is Iterable) return json.length;
    if (json is String) {
      return json.split(separator).where((String s) => s.trim().isNotEmpty).length;
    }
    return 0;
  }

  /// Returns a list of strings parsed from [json], splitting on [separator]
  /// if the value is a string, or `null` if conversion is not possible.
  static List<String>? toStringListJson(dynamic json, {String separator = ','}) {
    if (json == null) return null;
    if (json is List<String>) return json;
    if (json is List && json.every((dynamic e) => e is String)) return json.cast<String>().toList();
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
  static List<int>? toIntListJson(dynamic json) {
    if (json == null) return null;
    if (json is List<int>) return json;
    if (json is List<dynamic>) return json.map(toIntJson).whereType<int>().toList();
    if (json is String) {
      return json.split(',').map((String s) => int.tryParse(s.trim())).whereType<int>().toList();
    }
    return null;
  }

  /// Returns an integer parsed from [json], or `null` if conversion is not
  /// possible.
  static int? toIntJson(dynamic json) {
    if (json == null) return null;
    if (json is int) return json;
    if (json is double) return json.toInt();
    if (json is String) return int.tryParse(json);
    return null;
  }

  /// Returns a boolean parsed from [json], using [isCaseSensitive] to control
  /// string comparison, or `null` if conversion is not possible.
  static bool? toBoolJson(dynamic json, {bool isCaseSensitive = true}) {
    if (json == null) return null;
    if (json is bool) return json;
    if (json is int) return json == 1;
    final String str = json.toString();
    return str == '1' || (isCaseSensitive ? str == 'true' : str.toLowerCase() == 'true');
  }

  /// Returns a double parsed from [json], or `null` if conversion is not
  /// possible.
  static double? toDoubleJson(dynamic json) {
    if (json == null) return null;
    return double.tryParse(json.toString());
  }

  /// Returns a list of doubles parsed from [json], or `null` if conversion
  /// is not possible.
  static List<double>? toDoubleListJson(dynamic json) {
    if (json == null) return null;
    if (json is List<double>) return json;
    if (json is List<dynamic>) return json.map(toDoubleJson).whereType<double>().toList();
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
  /// by [trim], [makeUppercase], [makeLowercase], and [makeCapitalized],
  /// or `null` if the result is empty.
  static String? toStringJson(
    dynamic json, {
    bool trim = true,
    bool makeUppercase = false,
    bool makeLowercase = false,
    bool makeCapitalized = false,
  }) {
    if (json == null) return null;
    String? result = json is String ? json : json.toString();
    if (trim) result = result.trim();
    if (makeUppercase) {
      result = result.toUpperCase();
    } else if (makeLowercase) {
      result = result.toLowerCase();
    } else if (makeCapitalized) {
      result = result
          .split(' ')
          .map((String w) {
            if (w.isEmpty) return w;
            return w[0].toUpperCase() + w.substringSafe(1).toLowerCase();
          })
          .join(' ');
    }
    return result.isEmpty ? null : result;
  }

  /// Returns a [DateTime] parsed from [json], or `null` if conversion is not
  /// possible.
  static DateTime? toDateTimeJson(dynamic json) {
    if (json == null) return null;
    if (json is DateTime) return json;
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    final String? str = toStringJson(json);
    if (str == null || str.isEmpty) return null;
    return DateTime.tryParse(str);
  }

  /// Returns a [DateTime] from the epoch timestamp [json] interpreted at the
  /// given [scale], or `null` if [json] is not a valid integer.
  static DateTime? toDateTimeEpochJson(dynamic json, JsonEpochScale scale) {
    if (json == null) return null;
    final int? since = json is int ? json : null;
    if (since == null) return null;
    return switch (scale) {
      JsonEpochScale.seconds => DateTime.fromMillisecondsSinceEpoch(since * 1000),
      JsonEpochScale.milliseconds => DateTime.fromMillisecondsSinceEpoch(since),
      JsonEpochScale.microseconds => DateTime.fromMicrosecondsSinceEpoch(since),
    };
  }

  /// Returns [value] as a dynamic list if it is one, or `null` otherwise.
  static List<dynamic>? toListDynamic(dynamic value) => value is List<dynamic> ? value : null;
}
