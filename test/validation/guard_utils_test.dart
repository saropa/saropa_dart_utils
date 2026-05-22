import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/validation/guard_utils.dart';

void main() {
  group('guardArgument', () {
    test('does not throw when condition met', () {
      expect(() => guardArgument(true), returnsNormally);
    });
    test('throws ArgumentError when condition not met', () {
      expect(() => guardArgument(false), throwsArgumentError);
    });
    test('uses default message', () {
      expect(
        () => guardArgument(false),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError e) => e.message,
            'message',
            'Assertion failed',
          ),
        ),
      );
    });
    test('uses custom message', () {
      expect(
        () => guardArgument(false, 'must be positive'),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError e) => e.message,
            'message',
            'must be positive',
          ),
        ),
      );
    });
  });

  group('guard', () {
    test('returns value when condition met', () {
      expect(guard<int>(isConditionMet: true, value: 42), 42);
    });
    test('throws when condition not met', () {
      expect(
        () => guard<int>(isConditionMet: false, value: 42),
        throwsArgumentError,
      );
    });
    test('preserves generic type', () {
      final List<String> result = guard<List<String>>(
        isConditionMet: true,
        value: <String>['a'],
      );
      expect(result, <String>['a']);
    });
    test('custom message on failure', () {
      expect(
        () => guard<int>(isConditionMet: false, value: 1, message: 'nope'),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError e) => e.message,
            'message',
            'nope',
          ),
        ),
      );
    });
  });
}
