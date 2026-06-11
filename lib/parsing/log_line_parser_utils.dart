/// Template-driven log line parser — roadmap #631.
///
/// Compiles a log-format template with `{field}` placeholders into a regex that
/// extracts each field from a log line into a `Map<String, String>`. The literal
/// text between placeholders (spaces, brackets, quotes) delimits the fields, so
/// the common access-log shapes parse without a bespoke regex. Presets cover
/// Apache common/combined and nginx; custom formats are just a template string.
///
/// A field defaults to a lazy match bounded by the next literal; give it an
/// explicit regex with `{name:pattern}` (e.g. `{status:\d+}`) when the default
/// would over-match. Field names must be unique within a template.
library;

/// Parses log lines against a compiled format template.
class LogLineParser {
  LogLineParser._(this._regex, this._fields);

  /// Compiles [template] (with `{field}` / `{field:pattern}` placeholders).
  factory LogLineParser(String template) {
    final (RegExp regex, List<String> fields) = _compile(template);
    return LogLineParser._(regex, fields);
  }

  /// Apache/NCSA common log format: host ident user [time] "request" status size.
  factory LogLineParser.apacheCommon() => LogLineParser(_apacheCommon);

  /// Apache combined log format (common + "referer" "user-agent").
  factory LogLineParser.apacheCombined() => LogLineParser(_apacheCombined);

  /// nginx default `combined` access log (same shape as Apache combined).
  factory LogLineParser.nginxCombined() => LogLineParser(_apacheCombined);

  final RegExp _regex;
  final List<String> _fields;

  /// The field names this parser extracts, in template order.
  List<String> get fields => List<String>.unmodifiable(_fields);

  /// Parses [line] into `field → value`, or null if the line doesn't match the
  /// template. Missing optional captures come back as empty strings.
  Map<String, String>? parse(String line) {
    final RegExpMatch? match = _regex.firstMatch(line);
    if (match == null) {
      return null;
    }
    return <String, String>{
      for (final String field in _fields) field: match.namedGroup(field) ?? '',
    };
  }
}

const String _apacheCommon = '{host} {ident} {user} [{time}] "{request}" {status} {size}';
const String _apacheCombined =
    '{host} {ident} {user} [{time}] "{request}" {status} {size} "{referer}" "{userAgent}"';

final RegExp _placeholder = RegExp(r'\{(\w+)(?::([^}]+))?\}');

/// Compiles a template into an anchored regex with one named group per field,
/// plus the ordered field-name list. Literal text between placeholders is
/// escaped and matched exactly; it is what bounds each (lazy) field.
(RegExp, List<String>) _compile(String template) {
  final List<String> fields = <String>[];
  final StringBuffer buffer = StringBuffer('^');
  int last = 0;
  for (final RegExpMatch m in _placeholder.allMatches(template)) {
    // ignore: avoid_string_substring -- last <= m.start, both valid indices into template
    buffer.write(RegExp.escape(template.substring(last, m.start)));
    final String name = m.group(1) ?? '';
    fields.add(name);
    // The final placeholder (nothing after it) captures the rest greedily; an
    // earlier one matches lazily so the following literal delimits it.
    final bool isFinal = m.end == template.length;
    final String pattern = m.group(2) ?? (isFinal ? '.*' : '.*?');
    buffer.write('(?<$name>$pattern)');
    last = m.end;
  }
  // Two consecutive buffer writes kept as statements; cascading them would push
  // the substring call off the line its avoid_string_substring ignore guards.
  // ignore: avoid_string_substring, saropa_lints/prefer_cascade_over_chained -- last <= template.length, a valid index; cascade conflicts with this line-scoped ignore
  buffer.write(RegExp.escape(template.substring(last)));
  buffer.write(r'$');
  return (RegExp(buffer.toString()), fields);
}
