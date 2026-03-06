import 'dart:developer' as dev;

import 'package:saropa_dart_utils/string/string_extensions.dart';

const String _kLogParseListJsonFailed = 'parseListFromString: JSON decode failed';

/// Parse list from string (e.g. "a,b,c" or JSON array string). Roadmap #154.
List<String> parseListFromString(String input, {String delimiter = ','}) {
  final String s = input.trim();
  if (s.isEmpty) return <String>[];
  if (s.startsWith('[') && s.endsWith(']')) {
    try {
      final Object? decoded = _jsonDecode(s);
      if (decoded is List<dynamic>) {
        return decoded.map((dynamic e) => e?.toString() ?? '').toList();
      }
    } on Object catch (e, st) {
      dev.log(_kLogParseListJsonFailed, error: e, stackTrace: st);
    }
  }
  return s.split(delimiter).map((String x) => x.trim()).where((String x) => x.isNotEmpty).toList();
}

Object? _jsonDecode(String s) {
  if (s == '[]') return <dynamic>[];
  if (s.length < 2) return null;
  final List<dynamic> out = <dynamic>[];
  final String inner = s.substringSafe(1, s.length - 1);
  int i = 0;
  while (i < inner.length) {
    final int start = i;
    if (inner[i] == '"') {
      final (String parsed, int next) = _parseQuotedElement(inner, start);
      out.add(parsed);
      i = next;
    } else {
      final (String chunk, int next) = _parseUnquotedElement(inner, start);
      if (chunk.isNotEmpty) out.add(chunk);
      i = next;
    }
    i = _skipCommaAndSpace(inner, i);
  }
  return out;
}

(String, int) _parseQuotedElement(String inner, int start) {
  final StringBuffer sb = StringBuffer();
  int i = start + 1;
  while (i < inner.length && inner[i] != '"') {
    if (inner[i] == '\\') {
      i++;
      if (i < inner.length) sb.write(inner[i++]);
    } else {
      sb.write(inner[i++]);
    }
  }
  final int next = i < inner.length ? i + 1 : i;
  return (sb.toString(), next);
}

(String, int) _parseUnquotedElement(String inner, int start) {
  int end = start;
  while (end < inner.length && inner[end] != ',') end++;
  return (inner.substringSafe(start, end).trim(), end);
}

int _skipCommaAndSpace(String inner, int i) {
  while (i < inner.length && (inner[i] == ',' || inner[i] == ' ')) i++;
  return i;
}
