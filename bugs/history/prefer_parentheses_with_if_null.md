# prefer_parentheses_with_if_null

## Status: FIXED

## Summary
Added parentheses to clarify `??` chain precedence in `betweenBracketsResult()` and `betweenBracketsResultLast()` in `lib/string/string_between_extensions.dart`.

## Resolution
Wrapped `??` chains as `(a ?? b) ?? (c ?? d)` to satisfy the `prefer_parentheses_with_if_null` lint rule. Semantically equivalent — no behavior change.
