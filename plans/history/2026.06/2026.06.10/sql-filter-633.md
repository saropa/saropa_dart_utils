# SQL-like filter expression parser (roadmap #633)

Item 8 of the second "next 10" roadmap-utilities batch. Compiles a SQL WHERE-style clause into a predicate over Map rows, for in-memory record filtering with a familiar string.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/parsing/sql_filter_utils.dart` (`filterRows`, `compileFilter`, `RowPredicate`), new test, barrel export, CHANGELOG entry. Reuses the `tokenize` lexer (#434).

**Design:** `compileFilter` lexes then runs a recursive-descent parser that builds a closure tree of `RowPredicate` (`bool Function(Map<String, Object?>)`) — parse once, apply to many rows; `filterRows` is the one-shot `where(...).toList()`. Grammar levels: `_or → _and → _not → _comparison`, where a comparison is `field (= <> != < <= > >=) value`, or `field LIKE 'pattern'`, or `field IN (list)`, or `field IS [NOT] NULL`. Keywords (AND/OR/NOT/IS/NULL/LIKE/IN/TRUE/FALSE) are matched case-insensitively. `LIKE` compiles `%`→`.*`, `_`→`.` into an anchored case-sensitive RegExp (other chars escaped). Ordering comparisons use `_orderCompare` (two nums or two strings, else null→no match — SQL's unknown→false), keeping type mismatches from throwing.

**Distinction from `evaluateExpression` (#634):** that is a scalar arithmetic/boolean engine over a variable map; this is record-oriented with SQL operators (`<>`, `LIKE`, `IN`, `IS NULL`) against named fields. Conceptual cousins, different feature surface; both reuse the `tokenize` lexer rather than duplicating a hand-rolled scanner.

**Tests:** 15 cases — numeric comparison, AND, OR, NOT+parentheses, `LIKE` with `%` and `_`, `IN` list, `IS NULL`/`IS NOT NULL`, boolean `=`, string lexicographic `>`, `<>` inequality, incomparable-types-excluded (no throw), case-insensitive keywords; plus `compileFilter` reuse across rows and three malformed-clause throws. All pass; `flutter analyze` clean.

**Reviewer notes:** the `LIKE` predicate uses `is String` flow promotion (no cast). String literals are unquoted via `// ignore: avoid_string_substring` with proof (str regex guarantees quotes). Numbers parsed with `num.tryParse(...) ?? (throw ...)` for the safe-parse lint. The IDE's `prefer_reusing_assigned_local` Infos (on the `previous = left` capture in `_or`/`_and`, which is intentional — capturing the pre-loop value for the closure) are not in the project tier (`flutter analyze` clean). Functions ≤20 lines.

No bug archive — task did not close a bugs/*.md file.
