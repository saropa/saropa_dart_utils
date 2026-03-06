# avoid_hardcoded_duration

## 4 violations | Severity: info

### Rule Description
Hardcoded Duration values (e.g., `Duration(days: 1)`) should be extracted to named constants for clarity, reuse, and easier maintenance.

### Assessment
- **False Positive**: Mixed. Some durations like `Duration(days: 1)` are clear and self-documenting in context. Others in date range calculations may be intentional and extracting them may reduce readability rather than improve it.
- **Should Exclude**: No, but each case should be evaluated individually.

### Affected Files
- `lib\datetime\date_time_extensions.dart`
- `lib\datetime\date_time_range_utils.dart`

### Recommended Action
INVESTIGATE -- extract repeated durations to named constants if used multiple times. For one-off uses where the meaning is clear (e.g., `Duration(days: 1)` for "one day"), consider whether a constant truly improves readability.

---

## Verification

- **Status:** Partially addressed. Both files define `const Duration _oneDay = Duration(days: 1)`. Some inline `Duration(days: ...)` remain in date_time_extensions (e.g. offset and week calculations). Run linter for current violation list; extract or keep as-is per assessment.
