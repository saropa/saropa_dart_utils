import 'dart:convert' as dc;

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/map/map_extensions.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Utility class for JSON parsing and validation.
/// For type conversions (lists, strings, numbers, dates), see [JsonTypeUtils].
abstract final class JsonUtils {
  /// Returns a decoded `Map` from the given [jsonString], or `null` if
  /// decoding fails.
  @useResult
  static Map<String, dynamic>? jsonDecodeToMap(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;

    final dynamic decoded = jsonDecodeSafe(jsonString);
    if (decoded == null) return null;

    return MapUtils.toMapStringDynamic(decoded);
  }

  /// Safely decodes a JSON string, returning null on error.
  @useResult
  static dynamic jsonDecodeSafe(String? jsonString) {
    final String? trimmed = jsonString?.trim();
    if (trimmed == null || trimmed.isEmpty || trimmed == 'null') return null;
    if (!isJson(trimmed)) return null;

    try {
      return dc.jsonDecode(trimmed);
    } on FormatException catch (e, stackTrace) {
      // debugPrint is appropriate for utility packages (stripped in release builds, no external dependencies)
      // ignore: saropa_lints/avoid_print_error
      debugPrint('JsonUtils.jsonDecodeSafe failed: $e\n$stackTrace');

      return null;
    }
  }

  /// Checks if the JSON structural content is valid (empty objects/arrays).
  static bool _hasValidJsonContent(
    String trimmed, {
    required bool isObject,
    required bool shouldAllowEmpty,
  }) {
    // JSON objects must contain at least one key-value pair with a colon
    if (isObject && !trimmed.contains(':')) {
      return shouldAllowEmpty && trimmed == '{}';
    }

    if (trimmed == '[]') return shouldAllowEmpty;

    return true;
  }

  /// Returns `true` if [value] appears to be valid JSON.
  ///
  /// If [shouldTestDecode] is `true`, actually attempts to decode to verify.
  /// If [shouldAllowEmpty] is `true`, treats `'{}'` and `'[]'` as valid JSON
  /// (defaults to `false` for backwards compatibility).
  @useResult
  static bool isJson(
    String? value, {
    bool shouldTestDecode = false,
    bool shouldAllowEmpty = false,
  }) {
    if (value == null || value.length < 2) return false;

    final String trimmed = value.trim();
    final bool isObject = trimmed.startsWith('{') && trimmed.endsWith('}');
    final bool isArray = trimmed.startsWith('[') && trimmed.endsWith(']');

    if (!isObject && !isArray) return false;

    if (!_hasValidJsonContent(
      trimmed,
      isObject: isObject,
      shouldAllowEmpty: shouldAllowEmpty,
    )) {
      return false;
    }

    if (!shouldTestDecode) return true;

    try {
      return dc.jsonDecode(value) != null;
    } on FormatException catch (e, stackTrace) {
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
  @useResult
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
  /// cleaning the input first when [shouldCleanInput] is `true`, or `null`
  /// if decoding fails.
  @useResult
  static Map<String, dynamic>? tryJsonDecode(
    String? value, {
    bool shouldCleanInput = false,
  }) {
    if (value == null || value.isEmpty) return null;

    if (shouldCleanInput) {
      final String? cleaned = cleanJsonResponse(value);
      if (cleaned == null || cleaned.isEmpty) return null;

      return jsonDecodeToMap(cleaned);
    }

    return jsonDecodeToMap(value);
  }

  /// Returns a list of maps decoded from the JSON string [value], or `null`
  /// if decoding fails.
  @useResult
  static List<Map<String, dynamic>>? tryJsonDecodeListMap(String? value) {
    if (value == null || !isJson(value)) return null;

    try {
      final Object? data = dc.json.decode(value);
      // Guarded by isEmpty check above
      // ignore: prefer_list_first
      if (data is! List || data.isEmpty || data[0] is! Map<String, dynamic>) {
        return null;
      }

      if (!data.every((Object? e) => e is Map<String, dynamic>)) {
        return null;
      }

      return data.cast<Map<String, dynamic>>().toList();
    } on FormatException catch (e, stackTrace) {
      // debugPrint is appropriate for utility packages (stripped in release builds, no external dependencies)
      // ignore: saropa_lints/avoid_print_error
      debugPrint('JsonUtils.tryJsonDecodeListMap failed: $e\n$stackTrace');

      return null;
    }
  }

  /// Returns a list of strings decoded from the JSON string [value], or
  /// `null` if decoding fails.
  @useResult
  static List<String>? tryJsonDecodeList(String? value) {
    if (value == null || !isJson(value)) return null;

    try {
      final Object? data = dc.json.decode(value);
      if (data is! List || data.isEmpty) return null;
      if (!data.every((Object? e) => e is String)) return null;

      return data.cast<String>().toList();
    } on FormatException catch (e, stackTrace) {
      // debugPrint is appropriate for utility packages (stripped in release builds, no external dependencies)
      // ignore: saropa_lints/avoid_print_error
      debugPrint('JsonUtils.tryJsonDecodeList failed: $e\n$stackTrace');

      return null;
    }
  }
}
