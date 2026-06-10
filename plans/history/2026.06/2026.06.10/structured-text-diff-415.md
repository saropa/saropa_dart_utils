# Structured text diff by sentences and words (roadmap #415)

Item 2 of the "next 5" roadmap-utilities batch. Adds a UI-friendly structured diff (an ordered edit script) at word and sentence granularity, plus the generic LCS engine behind both.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/string/text_diff_structured_utils.dart` (`SeqDiffKind`, `SeqDiffOp<T>`, `diffSequences`, `diffWords`, `diffSentences`), new test, barrel export, CODE_INDEX row, CHANGELOG entry.

**Design:** `diffSequences<T>(a, b)` builds an LCS DP table back-to-front, then forward-backtracks into an ordered list of `equal`/`delete`/`insert` ops (O(n·m)). `diffWords` and `diffSentences` reuse the existing `tokenizeWords`/`tokenizeSentences` splitters and run them through the same engine, so a caller gets a structured script to color/animate rather than a rendered diff string.

**Naming collision resolved:** the barrel already exports a string-only, line-based `DiffOp`/`DiffOpKind` from `myers_diff_utils.dart`. The new generic types are named `SeqDiffOp<T>`/`SeqDiffKind` to avoid the export ambiguity (caught by analyzing the barrel, not the file in isolation).

**Tests:** 7 cases — sequence all-equal, middle insertion, end deletion, replacement (delete+insert), empty inputs; word diff (changed word), sentence diff (shared sentence kept, changed one diffed). All pass; `flutter analyze` clean on the file, test, AND barrel.

**Reviewer notes:** DP/backtrack use bounded index access inside loop guards (no `.first`/`.single`). Single non-nested ternary for the max in the DP fill (project bans nested ternaries). `SeqDiffOp` is immutable with value equality.

No bug archive — task did not close a bugs/*.md file.
