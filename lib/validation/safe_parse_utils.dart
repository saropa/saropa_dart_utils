/// Safe parsing wrappers (no-throw, rich error) — roadmap #695.
library;

import 'dart:developer' show log;

import 'package:flutter/foundation.dart' show kDebugMode;

typedef ParseFn<T extends Object> = T Function(String source);
const String _kLogSafeParseFailed = 'safeParse failed';

/// Result of a safe parse.
sealed class ParseResult<T extends Object> {
  /// The parsed value if successful, or null if failed.
  T? get valueOrNull;
}

/// Successful parse result holding the parsed [value].
final class ParseOk<T extends Object> extends ParseResult<T> {
  ParseOk(T value) : _value = value;
  final T _value;

  /// The parsed value.
  T get value => _value;

  @override
  T? get valueOrNull => _value;

  @override
  String toString() => 'ParseOk(value: $_value)';
}

/// Failed parse result with [message] and optional [details].
final class ParseErr<T extends Object> extends ParseResult<T> {
  ParseErr(String message, [StackTrace? details]) : _message = message, _details = details;
  final String _message;

  /// Human-readable error message.
  String get message => _message;
  final StackTrace? _details;

  /// Optional stack trace from the parse exception.
  StackTrace? get details => _details;

  @override
  T? get valueOrNull => null;

  @override
  String toString() => 'ParseErr(message: $_message)';
}

/// Parses [source] with [parse]; returns ParseOk or ParseErr.
ParseResult<T> safeParse<T extends Object>(ParseFn<T> parse, String source) {
  try {
    return ParseOk<T>(parse(source));
  } on Object catch (e, st) {
    if (kDebugMode) log(_kLogSafeParseFailed, error: e, stackTrace: st);
    return ParseErr<T>(e.toString(), st);
  }
}
