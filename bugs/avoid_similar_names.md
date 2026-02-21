# avoid_similar_names

## 10 violations | Severity: info

### Rule Description
Flags variables or parameters with names that are too similar to each other within the same scope, which can cause confusion and lead to bugs. For example, `start` and `startIndex`, or `value` and `values`, may be flagged as too similar.

### Assessment
- **False Positive**: Mixed. Some similar names are intentional and well-understood in context (e.g., `start`/`end`, `min`/`max`, `width`/`height`). Others may genuinely be confusing and deserve renaming.
- **Should Exclude**: No, not globally. The rule catches real readability issues, but individual cases need judgment.

### Affected Files
5 lib files (specific files to be identified by running the analyzer).

### Recommended Action
INVESTIGATE -- Review each of the 10 violations:

1. If the similar names are standard programming conventions (e.g., `index`/`indexOf`), suppress with an inline comment explaining the intent.
2. If the similar names are genuinely confusing (e.g., `result` and `results` in the same scope), rename one to be more descriptive.
3. Consider whether the function is doing too much if it needs many similarly-named variables -- it may benefit from being split.
