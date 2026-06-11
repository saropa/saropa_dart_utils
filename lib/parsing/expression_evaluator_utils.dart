/// Safe expression evaluator (arithmetic + boolean) — roadmap #634.
///
/// Evaluates a string expression over a supplied variable map, with NO access to
/// the host program — no function calls, no property access, no `eval`. Only
/// numbers, strings, booleans, the named variables you pass in, and a fixed set
/// of operators are understood, so untrusted formula input (a rule, a computed
/// column, a feature flag condition) can be evaluated without executing
/// arbitrary code.
///
/// Grammar (precedence low→high): `||`, `&&`, `== !=`, `< <= > >=`, `+ -`,
/// `* / %`, unary `! -`, then primaries: number, `'string'`/`"string"`, `true`,
/// `false`, variable, `( … )`. Lexing reuses the `tokenize` pipeline (#434).
/// Any malformed input or type mismatch throws a [FormatException]; evaluation
/// is eager (both sides of `&&`/`||` are computed — fine for these side-effect-
/// free operands).
library;

import 'package:saropa_dart_utils/string/tokenizer_pipeline_utils.dart';

/// The lexer rules: longest operators first so `<=`/`==`/`&&` win over `<`/`!`.
final List<TokenRule> _rules = <TokenRule>[
  TokenRule('ws', RegExp(r'\s+'), shouldSkip: true),
  TokenRule('num', RegExp(r'\d+(?:\.\d+)?')),
  TokenRule('str', RegExp('\'[^\']*\'|"[^"]*"')),
  TokenRule('id', RegExp(r'[A-Za-z_][A-Za-z0-9_]*')),
  TokenRule('op', RegExp(r'==|!=|<=|>=|&&|\|\||[+\-*/%<>!]')),
  TokenRule('lparen', RegExp(r'\(')),
  TokenRule('rparen', RegExp(r'\)')),
];

/// Evaluates [expression] against [variables], returning the result (a `num`,
/// `bool`, or `String`). Throws [FormatException] on a syntax error, an unknown
/// variable, or a type mismatch (e.g. adding a string).
///
/// Example:
/// ```dart
/// evaluateExpression('age >= 18 && country == "US"',
///   variables: {'age': 21, 'country': 'US'}); // true
/// ```
Object? evaluateExpression(
  String expression, {
  Map<String, Object?> variables = const <String, Object?>{},
}) {
  final List<Token> tokens = tokenize(expression, _rules);
  return _Evaluator(tokens, variables).run();
}

/// Evaluates [expression] expecting a boolean result (the common case for a
/// filter/condition); throws [FormatException] if it isn't boolean.
bool evaluateBool(String expression, {Map<String, Object?> variables = const <String, Object?>{}}) {
  final Object? value = evaluateExpression(expression, variables: variables);
  if (value is bool) {
    return value;
  }
  throw FormatException('expression did not evaluate to a boolean', expression);
}

/// A single-pass recursive-descent evaluator: each grammar level both parses and
/// computes, so there is no intermediate AST to walk.
class _Evaluator {
  _Evaluator(this._tokens, this._variables);

  final List<Token> _tokens;
  final Map<String, Object?> _variables;
  int _pos = 0;

  Object? run() {
    final Object? result = _or();
    final Token? extra = _peek();
    if (extra != null) {
      throw FormatException('unexpected token "${extra.value}" at ${extra.start}');
    }
    return result;
  }

  Object? _or() {
    Object? left = _and();
    while (_matchOp('||')) {
      // Compute the right operand into a local FIRST so its tokens are always
      // consumed (a short-circuiting `||` would skip the parse otherwise).
      // ignore: saropa_lints/prefer_reusing_assigned_local -- _and() consumes tokens (advances the parser cursor); each call returns a different value and must not be reused
      final bool right = _asBool(_and(), '||');
      left = _asBool(left, '||') || right;
    }
    return left;
  }

  Object? _and() {
    Object? left = _equality();
    while (_matchOp('&&')) {
      // ignore: saropa_lints/prefer_reusing_assigned_local -- _equality() consumes tokens; re-invocation is required, not a redundant recompute
      final bool right = _asBool(_equality(), '&&');
      left = _asBool(left, '&&') && right;
    }
    return left;
  }

  Object? _equality() {
    Object? left = _comparison();
    // Left-associative chain: fold each `== ` / `!=` into the running result so
    // `a == b != c` parses as `(a == b) != c`. Equality accepts any operand
    // types (num/bool/String) — no _asNum/_asBool coercion, unlike comparison.
    while (true) {
      if (_matchOp('==')) {
        left = left == _comparison();
      } else if (_matchOp('!=')) {
        left = left != _comparison();
      } else {
        // No equality operator next: this subexpression is complete.
        return left;
      }
    }
  }

  Object? _comparison() {
    Object? left = _additive();
    // Relational operators bind tighter than equality, looser than `+`/`-`, so
    // both operands come from _additive(). Each branch coerces via _asNum so a
    // non-numeric operand throws a FormatException rather than comparing wrong.
    while (true) {
      if (_matchOp('<')) {
        left = _asNum(left, '<') < _asNum(_additive(), '<');
      } else if (_matchOp('<=')) {
        left = _asNum(left, '<=') <= _asNum(_additive(), '<=');
      } else if (_matchOp('>')) {
        left = _asNum(left, '>') > _asNum(_additive(), '>');
      } else if (_matchOp('>=')) {
        left = _asNum(left, '>=') >= _asNum(_additive(), '>=');
      } else {
        // No relational operator next: hand the operand up to _equality.
        return left;
      }
    }
  }

  Object? _additive() {
    Object? left = _multiplicative();
    // `+`/`-` are left-associative and bind looser than `*`/`/`/`%`, so each
    // operand is a full _multiplicative() subexpression. `+` is numeric only
    // (no string concatenation) — _asNum enforces that on both sides.
    while (true) {
      if (_matchOp('+')) {
        // ignore: saropa_lints/avoid_string_concatenation_loop -- _asNum() returns num; this is numeric addition, not string concatenation
        left = _asNum(left, '+') + _asNum(_multiplicative(), '+');
      } else if (_matchOp('-')) {
        left = _asNum(left, '-') - _asNum(_multiplicative(), '-');
      } else {
        // No additive operator next: this term is complete.
        return left;
      }
    }
  }

  Object? _multiplicative() {
    Object? left = _unary();
    // Highest-precedence binary level: operands are unary terms so `-a * b`
    // groups as `(-a) * b`. `/` follows Dart's `num` division (returns double,
    // throws on integer-divide-by-zero only for `~/`, which is not supported).
    while (true) {
      if (_matchOp('*')) {
        left = _asNum(left, '*') * _asNum(_unary(), '*');
      } else if (_matchOp('/')) {
        left = _asNum(left, '/') / _asNum(_unary(), '/');
      } else if (_matchOp('%')) {
        left = _asNum(left, '%') % _asNum(_unary(), '%');
      } else {
        // No multiplicative operator next: hand the factor up to _additive.
        return left;
      }
    }
  }

  Object? _unary() {
    if (_matchOp('!')) {
      return !_asBool(_unary(), '!');
    }
    if (_matchOp('-')) {
      return -_asNum(_unary(), 'unary -');
    }
    return _primary();
  }

  Object? _primary() {
    final Token? token = _peek();
    // A primary is required here; running out of tokens means a dangling
    // operator (e.g. `1 +`) — report it rather than returning null silently.
    if (token == null) {
      throw const FormatException('unexpected end of expression');
    }
    // Consume the token up front: every branch below either uses it as a leaf
    // value or (for `(`) has already moved past the opening paren.
    _pos++;
    switch (token.type) {
      // Numeric leaf: tryParse can still fail on overflow-shaped input the lexer
      // accepted, so fall back to a FormatException instead of a null.
      case 'num':
        return num.tryParse(token.value) ?? (throw FormatException('bad number "${token.value}"'));
      // String leaf: strip the quotes the lexer kept around the literal.
      case 'str':
        return _unquote(token.value);
      // Identifier: a variable lookup or the `true`/`false` keyword literals.
      case 'id':
        return _resolveIdentifier(token.value);
      // Parenthesized group: re-enter the grammar at the top, then require the
      // matching `)` so unbalanced parens throw rather than parse partially.
      case 'lparen':
        final Object? inner = _or();
        _expect('rparen');
        return inner;
      // An operator or stray token where a value was expected.
      default:
        throw FormatException('unexpected token "${token.value}" at ${token.start}');
    }
  }

  Object? _resolveIdentifier(String name) {
    // `true`/`false` are reserved literals, not variables — handle them before
    // the map lookup so a caller can't shadow them with a `true` variable.
    if (name == 'true') {
      return true;
    }
    if (name == 'false') {
      return false;
    }
    // containsKey (not `_variables[name] == null`) so an explicit null value is
    // a valid binding, while a missing key is a hard error — catches typos in
    // untrusted formula input instead of silently evaluating to null.
    if (!_variables.containsKey(name)) {
      throw FormatException('unknown variable "$name"');
    }
    return _variables[name];
  }

  Token? _peek() => _pos < _tokens.length ? _tokens[_pos] : null;

  bool _matchOp(String op) {
    final Token? token = _peek();
    if (token != null && token.type == 'op' && token.value == op) {
      _pos++;
      return true;
    }
    return false;
  }

  void _expect(String type) {
    final Token? token = _peek();
    if (token == null || token.type != type) {
      throw FormatException('expected $type but found "${token?.value ?? 'end of input'}"');
    }
    _pos++;
  }

  num _asNum(Object? value, String op) {
    if (value is num) {
      return value;
    }
    throw FormatException('operator "$op" needs a number but got ${value.runtimeType}');
  }

  bool _asBool(Object? value, String op) {
    if (value is bool) {
      return value;
    }
    throw FormatException('operator "$op" needs a boolean but got ${value.runtimeType}');
  }
}

/// Strips the surrounding quotes from a lexed string literal (always length ≥ 2
/// — the lexer regex requires both quotes).
String _unquote(String literal) =>
    // ignore: avoid_string_substring -- the str token regex guarantees a leading and trailing quote (length >= 2)
    literal.substring(1, literal.length - 1);
