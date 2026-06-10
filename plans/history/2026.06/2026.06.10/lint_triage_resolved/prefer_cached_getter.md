# prefer_cached_getter

## 45 violations | Severity: info

### Rule Description
Getter performs computation that could be cached. The rule suggests storing the result of a computed getter in a field to avoid recomputation on subsequent accesses.

### Assessment
- **False Positive**: Mixed. For extension methods (the majority of this library), caching is not possible because extensions cannot have instance fields. Extensions compute values on each access by design. For utility classes with only static methods, getters are typically not present. The rule is structurally inapplicable to this codebase.
- **Should Exclude**: Partial. Extension getters cannot cache -- this is a false positive for the dominant pattern in the library. Utility class getters (if any) should be evaluated case-by-case.

### Affected Files
13 lib files.

### Recommended Action
INVESTIGATE:
1. **Extension getters** (majority): False positive -- extensions cannot cache. Consider excluding the rule or adding inline suppressions.
2. **Utility class getters** (if any): Evaluate whether caching is beneficial based on computation cost and expected call frequency.
3. If most violations are in extensions, EXCLUDE the rule via `prefer_cached_getter: false` in `analysis_options_custom.yaml`.
