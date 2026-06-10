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
Object? evaluateExpression(String expression, {Map<String, Object?> variables = const <String, Object?>{}}) {
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
      final bool right = _asBool(_and(), '||');
      left = _asBool(left, '||') || right;
    }
    return left;
  }

  Object? _and() {
    Object? left = _equality();
    while (_matchOp('&&')) {
      final bool right = _asBool(_equality(), '&&');
      left = _asBool(left, '&&') && right;
    }
    return left;
  }

  Object? _equality() {
    Object? left = _comparison();
    while (true) {
      if (_matchOp('==')) {
        left = left == _comparison();
      } else if (_matchOp('!=')) {
        left = left != _comparison();
      } else {
        return left;
      }
    }
  }

  Object? _comparison() {
    Object? left = _additive();
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
        return left;
      }
    }
  }

  Object? _additive() {
    Object? left = _multiplicative();
    while (true) {
      if (_matchOp('+')) {
        left = _asNum(left, '+') + _asNum(_multiplicative(), '+');
      } else if (_matchOp('-')) {
        left = _asNum(left, '-') - _asNum(_multiplicative(), '-');
      } else {
        return left;
      }
    }
  }

  Object? _multiplicative() {
    Object? left = _unary();
    while (true) {
      if (_matchOp('*')) {
        left = _asNum(left, '*') * _asNum(_unary(), '*');
      } else if (_matchOp('/')) {
        left = _asNum(left, '/') / _asNum(_unary(), '/');
      } else if (_matchOp('%')) {
        left = _asNum(left, '%') % _asNum(_unary(), '%');
      } else {
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
    if (token == null) {
      throw const FormatException('unexpected end of expression');
    }
    _pos++;
    switch (token.type) {
      case 'num':
        return num.tryParse(token.value) ?? (throw FormatException('bad number "${token.value}"'));
      case 'str':
        return _unquote(token.value);
      case 'id':
        return _resolveIdentifier(token.value);
      case 'lparen':
        final Object? inner = _or();
        _expect('rparen');
        return inner;
      default:
        throw FormatException('unexpected token "${token.value}" at ${token.start}');
    }
  }

  Object? _resolveIdentifier(String name) {
    if (name == 'true') {
      return true;
    }
    if (name == 'false') {
      return false;
    }
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
