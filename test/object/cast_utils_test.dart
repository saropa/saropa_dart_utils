import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/object/cast_utils.dart';

void main() {
  group('castOrNull', () {
    test('returns the value when the type matches', () {
      expect(castOrNull<String>('hi'), 'hi');
    });

    test('returns null when the type does not match', () {
      expect(castOrNull<int>('hi'), isNull);
    });

    test('returns null for a null input against a non-nullable type', () {
      expect(castOrNull<String>(null), isNull);
    });

    test('casts up the type hierarchy (int is num)', () {
      expect(castOrNull<num>(42), 42);
    });

    test('treats null as a valid value for a nullable target type', () {
      expect(castOrNull<String?>(null), isNull);
      // The cast succeeds (null is a String?), which is distinct from a type
      // mismatch — both happen to yield null here.
    });
  });
}
