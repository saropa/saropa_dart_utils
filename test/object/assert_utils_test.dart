import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/object/assert_utils.dart';

void main() {
  group('assertThat', () {
    test('does nothing when the condition is true', () {
      expect(() => assertThat(true), returnsNormally);
    });

    test('throws AssertionError when the condition is false', () {
      expect(() => assertThat(false), throwsA(isA<AssertionError>()));
    });

    test('uses the default message when none is supplied', () {
      expect(
        () => assertThat(false),
        throwsA(
          isA<AssertionError>().having((AssertionError e) => e.message, 'message', 'Assertion failed'),
        ),
      );
    });

    test('uses the provided custom message', () {
      expect(
        () => assertThat(false, 'custom failure'),
        throwsA(
          isA<AssertionError>().having((AssertionError e) => e.message, 'message', 'custom failure'),
        ),
      );
    });
  });
}
