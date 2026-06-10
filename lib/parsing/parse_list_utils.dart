import 'dart:developer' as dev;

import 'package:saropa_dart_utils/string/string_extensions.dart';

const String _kLogParseListJsonFailed = 'parseListFromString: JSON decode failed';

/// Parse list from string (e.g. "a,b,c" or JSON array string). Roadmap #154.
List<String> parseListFromString(String input, {String delimiter = ','}) {
  final String s = input.trim();
  if (s.isEmpty) return <String>[];
  // Bracketed input is parsed as a JSON-style array first so quoted commas are
  // respected; a failed parse falls through to delimiter splitting rather than
  // throwing, so malformed brackets still yield a best-effort list.
  if (s.startsWith('[') && s.endsWith(']')) {
    try {
      final Object? decoded = _jsonDecode(s);
      if (decoded is List<dynamic>) {
        return decoded.map((dynamic e) => e?.toString() ?? '').toList();
      }
    } on Object catch (e) {
      dev.log(_kLogParseListJsonFailed, error: e);
    }
  }
  // Plain mode: split on the delimiter, trimming and dropping empty pieces.
  return s.split(delimiter).map((String x) => x.trim()).where((String x) => x.isNotEmpty).toList();
}

Object? _jsonDecode(String s) {
  // Hand-rolled scanner instead of dart:convert so quoted commas (e.g.
  // ["a,b","c"]) are not mistaken for element separators by a naive split.
  if (s == '[]') return <dynamic>[];
  if (s.length < 2) return null;
  final List<dynamic> out = <dynamic>[];
  // Strip the surrounding [ ] and scan the contents element by element.
  final String inner = s.substringSafe(1, s.length - 1);
  int i = 0;
  while (i < inner.length) {
    final int start = i;
    // A leading quote means a string element whose closing quote (and any
    // backslash escapes) must be honored; anything else is a bare token.
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

// Reads a double-quoted element starting at the opening quote ([start]) and
// returns (unquoted value, index just past the closing quote). A backslash
// escapes the next character, so an embedded quote or comma is taken literally
// rather than ending the element.
(String, int) _parseQuotedElement(String inner, int start) {
  final StringBuffer sb = StringBuffer();
  int i = start + 1;
  while (i < inner.length && inner[i] != '"') {
    if (inner[i] == '\\') {
      // Escape: skip the backslash and take the following char verbatim.
      i++;
      if (i < inner.length) sb.write(inner[i++]);
    } else {
      sb.write(inner[i++]);
    }
  }
  // Step past the closing quote when present (clamped if the string was unterminated).
  final int next = i < inner.length ? i + 1 : i;
  return (sb.toString(), next);
}

(String, int) _parseUnquotedElement(String inner, int start) {
  int end = start;
  while (end < inner.length && inner[end] != ',') {
    end++;
  }
  return (inner.substringSafe(start, end).trim(), end);
}

int _skipCommaAndSpace(String inner, int i) {
  int pos = i;
  while (pos < inner.length && (inner[pos] == ',' || inner[pos] == ' ')) {
    pos++;
  }
  return pos;
}
