# BUG-020: Critical Methods Have Zero Test Coverage

**Multiple Files**
**Severity:** 🔴 High
**Category:** Missing Test Coverage
**Status:** Open

---

## Summary

Several methods across the codebase have **zero test coverage** despite containing complex logic. These untested methods represent silent failure risks.

---

## Methods with Zero Test Coverage

### 1. `getFirstDiffChar()` — String Extensions
**File:** `lib/string/string_extensions.dart` ~line 625
**Tests:** `test/string/string_extensions_test.dart`

This method finds the first character where two strings differ — used for diffing, validation, debugging. It has no tests at all.

```dart
// What happens with:
'hello'.getFirstDiffChar('hello');     // identical strings
''.getFirstDiffChar('hello');          // empty first
'hello'.getFirstDiffChar('');          // empty second
''.getFirstDiffChar('');               // both empty
'🎉'.getFirstDiffChar('🎊');          // emoji comparison
```

---

### 2. `hasInvalidUnicode()` and `removeInvalidUnicode()` — String Extensions
**File:** `lib/string/string_extensions.dart` ~line 650, 657
**Tests:** `test/string/string_extensions_test.dart`

Zero tests for two methods dealing with potentially dangerous invalid Unicode data. Invalid Unicode can cause crashes in many operations.

```dart
// What happens with:
'test\uFFFDvalue'.hasInvalidUnicode();    // String with replacement char
'\uFFFD'.removeInvalidUnicode();           // All invalid
'hello'.removeInvalidUnicode();            // No invalid chars — returns original?
''.hasInvalidUnicode();                    // Empty string
```

---

### 3. `collapseMultilineString()` — String Extensions
**File:** `lib/string/string_extensions.dart` ~line 1126
**Tests:** `test/string/string_extensions_test.dart`

This is a complex method with multiple parameters (`cropLength`, `commonWordEndings`) and conditional logic — yet has no tests.

```dart
// What happens with:
'Hello\nWorld\nFoo'.collapseMultilineString(cropLength: 5);
'Short'.collapseMultilineString(cropLength: 100);  // shorter than cropLength
''.collapseMultilineString();                       // empty
```

---

### 4. `splitCapitalizedUnicode()` — String Case Extensions
**File:** `lib/string/string_case_extensions.dart` ~line 413
**Tests:** `test/string/string_case_extensions_test.dart`

Complex method with merging logic for Unicode capitalized words. Zero coverage.

```dart
// What happens with:
'CamelCase'.splitCapitalizedUnicode();
'HelloWorldFoo'.splitCapitalizedUnicode();
'ALLCAPS'.splitCapitalizedUnicode();
'mixedUnicode你好'.splitCapitalizedUnicode();
```

---

### 5. `isVowel()` — String Extensions
**File:** `lib/string/string_extensions.dart` ~line 667
**Tests:** `test/string/string_extensions_test.dart`

No dedicated test group:

```dart
// What happens with:
'a'.isVowel();   // → true
'A'.isVowel();   // → true (case-insensitive?)
'b'.isVowel();   // → false
'e'.isVowel();   // → true
'ab'.isVowel();  // → ? (multiple chars)
''.isVowel();    // → ? (empty)
'é'.isVowel();   // → ? (accented vowel)
'y'.isVowel();   // → ? (sometimes vowel)
```

---

### 6. `pluralize()` — String Extensions
**File:** `lib/string/string_extensions.dart` ~line 1066
**Tests:** `test/string/string_extensions_test.dart`

No tests for pluralization logic, which is well-known for edge cases:

```dart
// What happens with:
'knife'.pluralize(2);    // → 'knives'? or 'knifes'?
'hero'.pluralize(2);     // → 'heroes'? or 'heros'?
'sheep'.pluralize(2);    // → 'sheep' (irregular)
'person'.pluralize(2);   // → 'persons'? 'people'? (irregular)
'child'.pluralize(2);    // → 'children'? (irregular)
''.pluralize(2);         // → ''
'a'.pluralize(2);        // → 'a' (due to `length == 1` guard)
```

---

### 7. `endsWithPunctuation()` and `endsWithAny()` — String Extensions
**File:** `lib/string/string_extensions.dart` ~line 920
**Tests:** `test/string/string_extensions_test.dart`

```dart
// What happens with:
'Hello!'.endsWithPunctuation();      // → true
'Hello'.endsWithPunctuation();       // → false
''.endsWithPunctuation();            // → false?
'Hello, world'.endsWithAny([',', '.', '!']); // → ?
```

---

### 8. `removeSingleCharacterWords()` — String Extensions
**File:** `lib/string/string_extensions.dart` ~line 764
**Tests:** `test/string/string_extensions_test.dart`

Complex regex-based method with no tests:

```dart
// What happens with:
'I am a developer'.removeSingleCharacterWords(); // 'I' and 'a' removed?
'A B C'.removeSingleCharacterWords();             // all removed?
''.removeSingleCharacterWords();
```

---

## Required Test Files to Add/Augment

For each of the above, add tests to the relevant test file following the project pattern:

```dart
group('getFirstDiffChar', () {
  test('identical strings return empty string', () {
    expect('hello'.getFirstDiffChar('hello'), equals(''));
  });
  test('first char differs', () {
    expect('hello'.getFirstDiffChar('world'), equals('h'));
  });
  test('strings of different lengths', () {
    expect('hi'.getFirstDiffChar('hello'), equals('i'));
  });
  test('both empty return empty', () {
    expect(''.getFirstDiffChar(''), equals(''));
  });
  test('first empty returns empty', () {
    expect(''.getFirstDiffChar('hello'), equals(''));
  });
  test('emoji comparison', () {
    expect('🎉'.getFirstDiffChar('🎊'), equals('🎉'));
  });
});

group('hasInvalidUnicode / removeInvalidUnicode', () {
  test('string without replacement chars returns false', () {
    expect('hello'.hasInvalidUnicode(), isFalse);
  });
  test('string with replacement char returns true', () {
    expect('test\uFFFDvalue'.hasInvalidUnicode(), isTrue);
  });
  test('removeInvalidUnicode removes replacement chars', () {
    expect('test\uFFFDvalue'.removeInvalidUnicode(), equals('testvalue'));
  });
  test('empty string has no invalid unicode', () {
    expect(''.hasInvalidUnicode(), isFalse);
  });
});
```
