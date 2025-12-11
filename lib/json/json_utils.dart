import 'dart:convert' as dc;

import 'package:saropa_dart_utils/map/map_extensions.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

final RegExp _jsonStringPattern = RegExp('^".*"\$');

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
  /// The elements of the iterable (type [T]) must be
  /// directly encodable by `dart:convert.jsonEncode`
  /// (e.g., `num`, `String`, `bool`, `null`, `List`, or `Map`
  /// with encodable keys and values).
  static String jsonEncode<T>(Iterable<T> iterable) => dc.jsonEncode(iterable.toList());
}

/// Utility class for JSON parsing and type conversion.
class JsonUtils {
  const JsonUtils._();

  /// Decodes a JSON string to a Map.
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
    } on FormatException {
      return null;
    }
  }

  /// Checks if a string appears to be valid JSON.
  ///
  /// **Args:**
  /// - [value]: The string to check.
  /// - [testDecode]: If true, actually attempts to decode to verify.
  /// - [allowEmpty]: If true, treats '{}' and '[]' as valid JSON.
  ///   Defaults to false for backwards compatibility.
  ///
  /// **Returns:**
  /// True if the string appears to be valid JSON.
  static bool isJson(String? value, {bool testDecode = false, bool allowEmpty = false}) {
    if (value == null || value.length < 2) return false;
    final String trimmed = value.trim();
    final bool isObject = trimmed.startsWith('{') && trimmed.endsWith('}');
    final bool isArray = trimmed.startsWith('[') && trimmed.endsWith(']');
    if (!isObject && !isArray) return false;
    if (isObject && !value.contains(':')) {
      // Empty object '{}' is valid JSON if allowEmpty is true
      if (!allowEmpty || trimmed != '{}') return false;
    }
    if (!testDecode) return true;
    try {
      return dc.jsonDecode(value) != null;
    } on FormatException {
      return false;
    }
  }

  /// Cleans a JSON response string by removing escaped quotes and outer quotes.
  static String? cleanJsonResponse(String? value) {
    if (value == null || value.isEmpty) return null;
    final String clean = value.replaceAll(r'\"', '"');
    if (clean.isEmpty) return null;
    if (_jsonStringPattern.hasMatch(clean)) {
      return clean.substringSafe(1, clean.length - 1);
    }
    return clean;
  }

  /// Attempts to decode a JSON string to a Map.
  static Map<String, dynamic>? tryJsonDecode(String? value, {bool cleanInput = false}) {
    if (value == null || value.isEmpty) return null;
    if (cleanInput) {
      final String? cleaned = cleanJsonResponse(value);
      if (cleaned == null || cleaned.isEmpty) return null;
      return jsonDecodeToMap(cleaned);
    }
    return jsonDecodeToMap(value);
  }

  /// Attempts to decode a JSON string to a list of maps.
  static List<Map<String, dynamic>>? tryJsonDecodeListMap(String? value) {
    if (value == null || !isJson(value)) return null;
    try {
      final dynamic data = dc.json.decode(value);
      if (data is! List || data.isEmpty || data[0] is! Map<String, dynamic>) return null;
      if (!data.every((dynamic e) => e is Map<String, dynamic>)) return null;
      return List<Map<String, dynamic>>.from(data);
    } on FormatException {
      return null;
    }
  }

  /// Attempts to decode a JSON string to a list of strings.
  static List<String>? tryJsonDecodeList(String? value) {
    if (value == null || !isJson(value)) return null;
    try {
      final dynamic data = dc.json.decode(value);
      if (data is! List || data.isEmpty) return null;
      if (!data.every((dynamic e) => e is String)) return null;
      return List<String>.from(data);
    } on FormatException {
      return null;
    }
  }

  /// Converts a dynamic list to a list of maps.
  static List<Map<String, dynamic>>? toListMap(List<dynamic>? valueList) {
    if (valueList == null) return null;
    final List<Map<String, dynamic>> result = valueList.whereType<Map<String, dynamic>>().toList();
    return result.isEmpty ? null : result;
  }

  /// Counts items in an iterable or comma-separated string.
  static int countIterableJson(dynamic json, {String separator = ','}) {
    if (json == null) return 0;
    if (json is Iterable) return json.length;
    if (json is String) {
      return json.split(separator).where((String s) => s.trim().isNotEmpty).length;
    }
    return 0;
  }

  /// Converts JSON to a list of strings.
  static List<String>? toStringListJson(dynamic json, {String separator = ','}) {
    if (json == null) return null;
    if (json is List<String>) return json;
    if (json is List && json.every((dynamic e) => e is String)) return List<String>.from(json);
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

  /// Converts JSON to a list of integers.
  static List<int>? toIntListJson(dynamic json) {
    if (json == null) return null;
    if (json is List<int>) return json;
    if (json is List<dynamic>) return json.map(toIntJson).whereType<int>().toList();
    if (json is String) {
      return json.split(',').map((String s) => int.tryParse(s.trim())).whereType<int>().toList();
    }
    return null;
  }

  /// Converts JSON to an integer.
  static int? toIntJson(dynamic json) {
    if (json == null) return null;
    if (json is int) return json;
    if (json is double) return json.toInt();
    if (json is String) return int.tryParse(json);
    return null;
  }

  /// Converts JSON to a boolean.
  static bool? toBoolJson(dynamic json, {bool isCaseSensitive = true}) {
    if (json == null) return null;
    if (json is bool) return json;
    if (json is int) return json == 1;
    final String str = json.toString();
    return str == '1' || (isCaseSensitive ? str == 'true' : str.toLowerCase() == 'true');
  }

  /// Converts JSON to a double.
  static double? toDoubleJson(dynamic json) {
    if (json == null) return null;
    return double.tryParse(json.toString());
  }

  /// Converts JSON to a list of doubles.
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

  /// Converts JSON to a string with optional transformations.
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

  /// Converts JSON to a DateTime.
  static DateTime? toDateTimeJson(dynamic json) {
    if (json == null) return null;
    if (json is DateTime) return json;
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    final String? str = toStringJson(json);
    if (str == null || str.isEmpty) return null;
    return DateTime.tryParse(str);
  }

  /// Converts an epoch timestamp to DateTime.
  static DateTime? toDateTimeEpochJson(dynamic json, JsonEpochScale scale) {
    if (json == null) return null;
    final int? since = json as int?;
    if (since == null) return null;
    return switch (scale) {
      JsonEpochScale.seconds => DateTime.fromMillisecondsSinceEpoch(since * 1000),
      JsonEpochScale.milliseconds => DateTime.fromMillisecondsSinceEpoch(since),
      JsonEpochScale.microseconds => DateTime.fromMicrosecondsSinceEpoch(since),
    };
  }

  /// Converts a value to a dynamic list if it is one.
  static List<dynamic>? toListDynamic(dynamic value) => value is List<dynamic> ? value : null;
}
