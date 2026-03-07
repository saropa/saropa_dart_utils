# avoid_hardcoded_locale

## 5 violations | Severity: info

### Rule Description
Flags hardcoded locale strings (e.g., `'en_US'`, `'fr_FR'`) in source code. Hardcoded locales make the code inflexible for internationalization and can produce unexpected results for users in different regions.

### Assessment
- **False Positive**: Mixed. Date formatting utilities may intentionally use a specific locale as a default for consistent behavior. For example, a `formatDate()` method might default to `'en_US'` to produce predictable output. However, the locale should ideally be a configurable parameter with a default, not a buried hardcoded value.
- **Should Exclude**: No. Even if defaults are intentional, the code should make locale configurable.

### Affected Files
- `lib\datetime\date_time_utils.dart`

### Recommended Action
INVESTIGATE -- Review each hardcoded locale in `date_time_utils.dart`:

1. **Make configurable with default**: Convert hardcoded locales to optional parameters:
   ```dart
   // Before
   String formatDate(DateTime date) {
     return Jiffy.parseDateTime(date).format('en_US');
   }

   // After
   String formatDate(DateTime date, {String locale = 'en_US'}) {
     return Jiffy.parseDateTime(date).format(locale);
   }
   ```

2. **Extract to constants**: If a locale must remain hardcoded (e.g., for ISO standard formats), extract it to a named constant to document the intent:
   ```dart
   static const _defaultLocale = 'en_US';
   ```

---

## Verification

- **Status:** Partially fixed. `isDeviceDateMonthFirst()` was renamed to `isDateMonthFirst({required String localeName})` — the `dart:io` `Platform` dependency was removed and the locale is now a caller-provided parameter. The set of month-first locales (`_monthFirstLocales`) still uses hardcoded strings, which is intentional for this lookup table. The constants are documented with inline comments.

3. **Document the default**: Add dartdoc explaining why a specific locale is the default.

Note: This may be an API-breaking change if parameter signatures change. Evaluate impact on downstream consumers.
