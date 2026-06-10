# Customizable tokenizer pipeline (roadmap #434)

Item 1 of the "next 5" roadmap-utilities batch (continuation of the top-10 build, /finish after each). Adds a reusable lexer core driven by ordered regex rules with keep/skip behavior, distinct from the existing sentence/word tokenizer (#404).

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/string/tokenizer_pipeline_utils.dart` (`tokenize`, `TokenRule`, `Token`), new test, barrel export, CODE_INDEX row, CHANGELOG entry.

**Design:** `tokenize(input, rules)` walks the input; at each cursor position it tries `rules` in order and takes the first whose `pattern` matches as a prefix (`matchAsPrefix(input, pos)`). `shouldSkip` rules advance the cursor without emitting (whitespace, comments). A zero-width match is rejected (`match.end > pos`) so a rule like `\d*` can never spin the cursor in place. A position no rule matches throws `FormatException` with the offset — unmatched text is a hard error, never silently dropped. `Token` and `TokenRule` are immutable; `Token` has value equality for easy assertions.

**Tests:** 6 cases — typed tokens with offsets + whitespace skip, first-rule-wins ordering (keyword before identifier), `FormatException` offset on unmatched char, empty input, zero-width-rule does-not-spin, all-skip input. All pass; `flutter analyze` clean.

**Reviewer notes:** One `substring` carries `// ignore: avoid_string_substring` (bounded by `matchAsPrefix` at `pos`). `shouldSkip` (not `skip`) satisfies the boolean-prefix lint. No unsafe collection accessors.

No bug archive — task did not close a bugs/*.md file.
