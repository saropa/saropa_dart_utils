# prefer_setup_teardown

## 6 violations | Severity: info

### Rule Description
Flags test files where setup code is duplicated across multiple test cases within the same group. The rule suggests extracting common setup logic into `setUp()` or `tearDown()` functions to reduce duplication and improve maintainability.

### Assessment
- **False Positive**: Partially. The project's testing rules explicitly state "Clarity Over DRY" for tests, preferring explicit, self-contained tests over abstracted ones. However, truly duplicated setup (e.g., creating the same test fixture in every test) does benefit from `setUp()` without sacrificing clarity.
- **Should Exclude**: No. Even with the "clarity over DRY" principle, extracting genuinely repeated setup code into `setUp()` is good practice and does not harm test readability.

### Affected Files
6 test files (specific files to be identified by running the analyzer).

### Recommended Action
FIX -- Review each flagged test file and extract genuinely duplicated setup into `setUp()`:

```dart
// Before
group('methodName', () {
  test('should do X', () {
    final sut = createSystemUnderTest();
    // test X
  });

  test('should do Y', () {
    final sut = createSystemUnderTest();
    // test Y
  });
});

// After
group('methodName', () {
  late SystemUnderTest sut;

  setUp(() {
    sut = createSystemUnderTest();
  });

  test('should do X', () {
    // test X
  });

  test('should do Y', () {
    // test Y
  });
});
```

Be judicious -- only extract setup that is truly identical across tests. Keep test-specific setup inline to maintain test clarity and independence.
