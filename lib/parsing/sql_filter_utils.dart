/// SQL-like filter for in-memory rows — roadmap #633.
///
/// Compiles a SQL `WHERE`-style clause into a predicate over `Map<String,
/// Object?>` rows, so a list of records can be filtered with a familiar string
/// (`age > 18 AND country = 'US'`) instead of a hand-written closure. Distinct
/// from the general expression evaluator (#634): this is record-oriented and
/// speaks SQL operators (`=`, `<>`, `LIKE`, `IN`, `IS NULL`) against named
/// fields, not a scalar arithmetic engine.
///
/// Supported grammar: `AND` / `OR` / `NOT` / parentheses; comparisons
/// `= <> != < <= > >=`; `field LIKE 'a%_'` (`%` = any run, `_` = one char,
/// case-sensitive); `field IN (v, …)`; `field IS [NOT] NULL`; literals number,
/// `'string'`, `true`, `false`, `null`. Lexing reuses the `tokenize` pipeline
/// (#434). Malformed input throws a [FormatException].
library;

import 'package:saropa_dart_utils/string/tokenizer_pipeline_utils.dart';

/// A compiled filter: returns whether a row satisfies the clause.
typedef RowPredicate = bool Function(Map<String, Object?> row);

final List<TokenRule> _rules = <TokenRule>[
  TokenRule('ws', RegExp(r'\s+'), shouldSkip: true),
  TokenRule('num', RegExp(r'\d+(?:\.\d+)?')),
  TokenRule('str', RegExp("'[^']*'")),
  TokenRule('id', RegExp(r'[A-Za-z_][A-Za-z0-9_]*')),
  TokenRule('op', RegExp(r'<>|!=|<=|>=|=|<|>')),
  TokenRule('lparen', RegExp(r'\(')),
  TokenRule('rparen', RegExp(r'\)')),
  TokenRule('comma', RegExp(r',')),
];

/// Filters [rows] by [whereClause], returning the matching rows in order.
///
/// Example:
/// ```dart
/// filterRows(users, "age >= 18 AND city LIKE 'New%'");
/// ```
List<Map<String, Object?>> filterRows(
  Iterable<Map<String, Object?>> rows,
  String whereClause,
) {
  final RowPredicate predicate = compileFilter(whereClause);
  return rows.where(predicate).toList();
}

/// Compiles [whereClause] into a reusable [RowPredicate] (parse once, apply to
/// many rows). Throws [FormatException] on a malformed clause.
RowPredicate compileFilter(String whereClause) {
  final List<Token> tokens = tokenize(whereClause, _rules);
  return _FilterParser(tokens).parse();
}

/// Recursive-descent parser building a closure tree of [RowPredicate]s.
class _FilterParser {
  _FilterParser(this._tokens);

  final List<Token> _tokens;
  int _pos = 0;

  RowPredicate parse() {
    final RowPredicate predicate = _or();
    final Token? extra = _peek();
    if (extra != null) {
      throw FormatException('unexpected token "${extra.value}" at ${extra.start}');
    }
    return predicate;
  }

  RowPredicate _or() {
    RowPredicate left = _and();
    while (_matchKeyword('OR')) {
      final RowPredicate right = _and();
      final RowPredicate previous = left;
      left = (Map<String, Object?> row) => previous(row) || right(row);
    }
    return left;
  }

  RowPredicate _and() {
    RowPredicate left = _not();
    while (_matchKeyword('AND')) {
      final RowPredicate right = _not();
      final RowPredicate previous = left;
      left = (Map<String, Object?> row) => previous(row) && right(row);
    }
    return left;
  }

  RowPredicate _not() {
    if (_matchKeyword('NOT')) {
      final RowPredicate inner = _not();
      return (Map<String, Object?> row) => !inner(row);
    }
    if (_match('lparen')) {
      final RowPredicate group = _or();
      _expect('rparen');
      return group;
    }
    return _comparison();
  }

  RowPredicate _comparison() {
    final String field = _expectField();
    if (_matchKeyword('IS')) {
      final bool negated = _matchKeyword('NOT');
      _expectKeyword('NULL');
      return (Map<String, Object?> row) => (row[field] == null) != negated;
    }
    if (_matchKeyword('LIKE')) {
      final RegExp regex = _likeToRegExp(_expectString());
      return (Map<String, Object?> row) {
        final Object? value = row[field];
        return value is String && regex.hasMatch(value);
      };
    }
    if (_matchKeyword('IN')) {
      final List<Object?> values = _valueList();
      return (Map<String, Object?> row) => values.contains(row[field]);
    }
    final String op = _expectOp();
    final Object? literal = _value();
    return (Map<String, Object?> row) => _applyOperator(op, row[field], literal);
  }

  List<Object?> _valueList() {
    _expect('lparen');
    final List<Object?> values = <Object?>[_value()];
    while (_match('comma')) {
      values.add(_value());
    }
    _expect('rparen');
    return values;
  }

  Object? _value() {
    final Token? token = _peek();
    if (token == null) {
      throw const FormatException('expected a value but reached end of input');
    }
    _pos++;
    switch (token.type) {
      case 'num':
        return num.tryParse(token.value) ?? (throw FormatException('bad number "${token.value}"'));
      case 'str':
        return _unquote(token.value);
      case 'id':
        return _keywordLiteral(token.value);
      default:
        throw FormatException('expected a value, got "${token.value}"');
    }
  }

  Object? _keywordLiteral(String word) {
    switch (word.toUpperCase()) {
      case 'TRUE':
        return true;
      case 'FALSE':
        return false;
      case 'NULL':
        return null;
      default:
        throw FormatException('expected a literal value, got "$word"');
    }
  }

  Token? _peek() => _pos < _tokens.length ? _tokens[_pos] : null;

  bool _match(String type) {
    if (_peek()?.type == type) {
      _pos++;
      return true;
    }
    return false;
  }

  bool _matchKeyword(String keyword) {
    final Token? token = _peek();
    if (token != null && token.type == 'id' && token.value.toUpperCase() == keyword) {
      _pos++;
      return true;
    }
    return false;
  }

  String _expectField() {
    final Token? token = _peek();
    if (token == null || token.type != 'id') {
      throw FormatException('expected a field name but found "${token?.value ?? 'end of input'}"');
    }
    _pos++;
    return token.value;
  }

  String _expectOp() {
    final Token? token = _peek();
    if (token == null || token.type != 'op') {
      throw FormatException('expected a comparison operator but found "${token?.value ?? 'end'}"');
    }
    _pos++;
    return token.value;
  }

  String _expectString() {
    final Token? token = _peek();
    if (token == null || token.type != 'str') {
      throw FormatException('expected a quoted string but found "${token?.value ?? 'end'}"');
    }
    _pos++;
    return _unquote(token.value);
  }

  void _expect(String type) {
    if (!_match(type)) {
      throw FormatException('expected $type but found "${_peek()?.value ?? 'end of input'}"');
    }
  }

  void _expectKeyword(String keyword) {
    if (!_matchKeyword(keyword)) {
      throw FormatException('expected $keyword but found "${_peek()?.value ?? 'end of input'}"');
    }
  }
}

/// Applies a comparison [op] between a row's [fieldValue] and a [literal].
/// Equality uses `==`/`!=`; ordering operators compare two nums or two strings
/// and treat any other (or null) pairing as not-matching (SQL's unknown → false).
bool _applyOperator(String op, Object? fieldValue, Object? literal) {
  switch (op) {
    case '=':
      return fieldValue == literal;
    case '!=':
    case '<>':
      return fieldValue != literal;
    default:
      final int? order = _orderCompare(fieldValue, literal);
      if (order == null) {
        return false;
      }
      return _applyOrder(op, order);
  }
}

bool _applyOrder(String op, int order) {
  switch (op) {
    case '<':
      return order < 0;
    case '<=':
      return order <= 0;
    case '>':
      return order > 0;
    default:
      return order >= 0; // '>='
  }
}

/// Comparable ordering for two nums or two strings, else null (incomparable).
int? _orderCompare(Object? a, Object? b) {
  if (a is num && b is num) {
    return a.compareTo(b);
  }
  if (a is String && b is String) {
    return a.compareTo(b);
  }
  return null;
}

/// Converts a SQL LIKE pattern (`%` = any run, `_` = one char) to an anchored,
/// case-sensitive [RegExp], escaping all other characters.
RegExp _likeToRegExp(String pattern) {
  final StringBuffer buffer = StringBuffer('^');
  for (final String ch in pattern.split('')) {
    if (ch == '%') {
      buffer.write('.*');
    } else if (ch == '_') {
      buffer.write('.');
    } else {
      buffer.write(RegExp.escape(ch));
    }
  }
  buffer.write(r'$');
  return RegExp(buffer.toString());
}

/// Strips the single quotes from a lexed string literal (length ≥ 2 guaranteed
/// by the str token regex).
String _unquote(String literal) =>
    // ignore: avoid_string_substring -- the str token regex guarantees surrounding quotes (length >= 2)
    literal.substring(1, literal.length - 1);
