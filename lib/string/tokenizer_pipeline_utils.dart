/// Customizable tokenizer pipeline: ordered regex rules with keep/skip —
/// roadmap #434.
///
/// A reusable lexer core: give it an ordered list of [TokenRule]s and it walks
/// the input, at each position taking the FIRST rule that matches as a prefix.
/// Rules marked `skip` (whitespace, comments) advance the cursor without
/// emitting a token. Unlike a one-off hand-rolled `split`/`RegExp.allMatches`,
/// rule order resolves ambiguity deterministically and an unmatched position is
/// a hard error rather than silently dropped text.
library;

import 'package:meta/meta.dart';

/// One tokenizer rule: a [type] label, the [pattern] to match at the cursor,
/// and whether matches are dropped ([skip]) instead of emitted.
@immutable
class TokenRule {
  /// Creates a rule labelled [type] matching [pattern]. Set [shouldSkip] for
  /// tokens to consume but not emit (whitespace, comments).
  /// Audited: 2026-06-12 11:26 EDT
  const TokenRule(this.type, this.pattern, {this.shouldSkip = false});

  /// The label attached to tokens this rule produces (e.g. `'number'`).
  final String type;

  /// The pattern matched as a prefix at the current cursor position.
  final RegExp pattern;

  /// When true, matches advance the cursor but emit no token.
  final bool shouldSkip;
}

/// A produced token: its rule [type], the matched [value], and the [start]
/// offset into the original input.
@immutable
class Token {
  /// Creates a token of [type] holding [value], found at [start].
  /// Audited: 2026-06-12 11:26 EDT
  const Token(this.type, this.value, this.start);

  /// The label from the [TokenRule] that produced this token.
  final String type;

  /// The exact matched substring.
  final String value;

  /// The 0-based offset of [value] in the original input.
  final int start;

  @override
  bool operator ==(Object other) =>
      other is Token && other.type == type && other.value == value && other.start == start;

  @override
  int get hashCode => Object.hash(type, value, start);

  @override
  String toString() => 'Token($type, "$value"@$start)';
}

/// Tokenizes [input] by trying [rules] in order at each cursor position; the
/// first rule whose pattern matches as a prefix wins. Skipped rules advance
/// without emitting. Throws [FormatException] (with the offset) at any position
/// no rule matches, and treats a zero-length match as a non-match so a rule like
/// `\d*` can never spin the cursor in place.
///
/// Example:
/// ```dart
/// tokenize('ab = 12', [
///   TokenRule('ws', RegExp(r'\s+'), shouldSkip: true),
///   TokenRule('id', RegExp(r'[a-z]+')),
///   TokenRule('op', RegExp(r'=')),
///   TokenRule('num', RegExp(r'\d+')),
/// ]); // id "ab", op "=", num "12"
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<Token> tokenize(String input, List<TokenRule> rules) {
  final List<Token> tokens = <Token>[];
  int pos = 0;
  while (pos < input.length) {
    final _Hit? hit = _firstMatch(input, pos, rules);
    if (hit == null) {
      throw FormatException('No token rule matched', input, pos);
    }
    if (!hit.rule.shouldSkip) tokens.add(Token(hit.rule.type, hit.text, pos));
    pos += hit.text.length;
  }
  return tokens;
}

class _Hit {
  const _Hit(this.rule, this.text);

  final TokenRule rule;
  final String text;
}

_Hit? _firstMatch(String input, int pos, List<TokenRule> rules) {
  for (final TokenRule rule in rules) {
    final Match? match = rule.pattern.matchAsPrefix(input, pos);
    // Require forward progress (match.end > pos): a zero-width match would
    // otherwise emit empty tokens forever without advancing the cursor.
    if (match != null && match.end > pos) {
      // pos and match.end are valid in-bounds indices into input.
      // ignore: avoid_string_substring -- bounded by matchAsPrefix at pos
      return _Hit(rule, input.substring(pos, match.end));
    }
  }
  return null;
}
