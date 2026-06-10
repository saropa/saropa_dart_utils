# Safe expression evaluator (roadmap #634)

Item 7 of the second "next 10" roadmap-utilities batch. Evaluates arithmetic/boolean string expressions over a variable map in a sandbox — no host access — so untrusted formula input can run safely.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/parsing/expression_evaluator_utils.dart` (`evaluateExpression`, `evaluateBool`), new test, barrel export, CHANGELOG entry. Reuses the `tokenize` lexer (#434).

**Design:** lexing uses `tokenize` with ordered rules (longest operators first so `<=`/`==`/`&&` beat `<`/`!`). A `_Evaluator` does single-pass recursive descent that both parses AND computes (no intermediate AST), one method per precedence level: `_or → _and → _equality → _comparison → _additive → _multiplicative → _unary → _primary`. Primaries are number, quoted string, `true`/`false`, variable (resolved from the map; unknown throws), and parenthesized sub-expression. `evaluateBool` wraps `evaluateExpression` and requires a boolean.

**Sandbox safety:** the grammar admits ONLY literals, the caller's named variables, and a fixed operator set — no function calls, property access, or `eval`. Untrusted input therefore can't reach host state; the worst case is a `FormatException`.

**Eager-eval subtlety:** `&&`/`||` are evaluated eagerly (operands are side-effect-free here). The right operand is computed into a local BEFORE applying `||`/`&&`, because a short-circuiting operator would otherwise skip the recursive-descent call and leave its tokens unconsumed — corrupting the parse. This also resolved the `avoid_bitwise_operators_with_booleans` warning from the initial `|`/`&` attempt.

**Tests:** 17 cases — precedence, parentheses, real division + modulo, unary minus + decimals, numeric comparison, cross-type equality (incl. string ==), boolean logic + negation, mixed-type variable resolution, arithmetic over variables, unknown-variable throw, type-mismatch throws (`1 + true`, `2 && 3`), trailing-token / incomplete / unbalanced-paren / unknown-char syntax errors, and `evaluateBool` success + non-boolean throw. All pass; `flutter analyze` clean.

**Reviewer notes:** the string-literal `_unquote` carries an `// ignore: avoid_string_substring` with proof (the str token regex guarantees both quotes, length ≥ 2). Number parsing uses `num.tryParse(...) ?? (throw ...)` to satisfy the safe-parse lint while the regex guarantees parseability. Several stylistic Infos (`prefer_reusing_assigned_local`, `avoid_string_concatenation_loop` false-positive on numeric `+`) are not in the project tier (`flutter analyze` clean). Methods ≤20 lines.

No bug archive — task did not close a bugs/*.md file.
