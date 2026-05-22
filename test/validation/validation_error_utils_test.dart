// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/validation/validation_error_utils.dart';

void main() {
  group('ValidationErrorUtils', () {
    test('message-only construction', () {
      const ValidationErrorUtils e = ValidationErrorUtils('bad');
      expect(e.message, 'bad');
      expect(e.code, isNull);
      expect(e.path, isNull);
    });

    test('exposes code and path when provided', () {
      const ValidationErrorUtils e = ValidationErrorUtils('bad', code: 'E1', path: 'name');
      expect(e.code, 'E1');
      expect(e.path, 'name');
    });

    test('toString without path is the message', () {
      expect(const ValidationErrorUtils('bad').toString(), 'bad');
    });

    test('toString with path prefixes the path', () {
      expect(const ValidationErrorUtils('bad', path: 'email').toString(), '[email] bad');
    });
  });

  group('ValidationErrors', () {
    test('empty by default', () {
      final ValidationErrors errs = ValidationErrors();
      expect(errs.isEmpty, isTrue);
      expect(errs.isNotEmpty, isFalse);
      expect(errs.errors, isEmpty);
    });

    test('seeded from existing list', () {
      final ValidationErrors errs = ValidationErrors(<ValidationErrorUtils>[
        const ValidationErrorUtils('a'),
      ]);
      expect(errs.isNotEmpty, isTrue);
      expect(errs.errors, hasLength(1));
    });

    test('add appends one error', () {
      final ValidationErrors errs = ValidationErrors();
      errs.add(const ValidationErrorUtils('x'));
      expect(errs.errors, hasLength(1));
      expect(errs.errors.first.message, 'x');
      expect(errs.isEmpty, isFalse);
    });

    test('addAll appends multiple errors', () {
      final ValidationErrors errs = ValidationErrors();
      errs.addAll(<ValidationErrorUtils>[
        const ValidationErrorUtils('a'),
        const ValidationErrorUtils('b'),
      ]);
      expect(errs.errors, hasLength(2));
    });

    test('errors getter is unmodifiable', () {
      final ValidationErrors errs = ValidationErrors();
      errs.add(const ValidationErrorUtils('x'));
      expect(
        () => errs.errors.add(const ValidationErrorUtils('y')),
        throwsUnsupportedError,
      );
    });

    test('toString reports count', () {
      final ValidationErrors errs = ValidationErrors();
      errs.add(const ValidationErrorUtils('x'));
      errs.add(const ValidationErrorUtils('y'));
      expect(errs.toString(), 'ValidationErrors(errors: 2)');
    });
  });
}
