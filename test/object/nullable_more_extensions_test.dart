import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/object/nullable_more_extensions.dart';

void main() {
  group('NullableWhen', () {
    group('whenNonNull', () {
      test('should run the callback for a non-null value', () {
        const int? value = 5;
        int? seen;
        value.whenNonNull((v) => seen = v);
        expect(seen, 5);
      });

      test('should not run the callback for a null receiver', () {
        const int? value = null;
        var called = false;
        value.whenNonNull((_) => called = true);
        expect(called, isFalse);
      });

      test('should return the original receiver for chaining', () {
        const int? value = 5;
        expect(value.whenNonNull((_) {}), 5);
      });

      test('should return null when the receiver is null', () {
        const int? value = null;
        expect(value.whenNonNull((_) {}), isNull);
      });

      test('should run the callback for a non-null falsy value (0)', () {
        const int? value = 0;
        int? seen;
        value.whenNonNull((v) => seen = v);
        expect(seen, 0);
      });
    });

    group('mapNonNull', () {
      test('should transform a non-null value', () {
        const int? value = 3;
        expect(value.mapNonNull((v) => v * 2), 6);
      });

      test('should return null for a null receiver without calling fn', () {
        const int? value = null;
        var called = false;
        final result = value.mapNonNull((v) {
          called = true;
          return v * 2;
        });
        expect(result, isNull);
        expect(called, isFalse);
      });

      test('should support a result type different from the receiver', () {
        const int? value = 7;
        expect(value.mapNonNull((v) => 'n=$v'), 'n=7');
      });

      test('should transform a non-null falsy value (0)', () {
        const int? value = 0;
        expect(value.mapNonNull((v) => v + 1), 1);
      });
    });

    group('orElse', () {
      test('should return the value when non-null', () {
        const String? value = 'hello';
        expect(value.orElse(() => 'fallback'), 'hello');
      });

      test('should return the computed fallback when null', () {
        const String? value = null;
        expect(value.orElse(() => 'fallback'), 'fallback');
      });

      test('should not evaluate compute when the value is non-null', () {
        const String? value = 'hello';
        var called = false;
        value.orElse(() {
          called = true;
          return 'fallback';
        });
        expect(called, isFalse);
      });

      test('should treat a non-null falsy value (0) as present', () {
        const int? value = 0;
        expect(value.orElse(() => -1), 0);
      });
    });
  });

  group('TryCast', () {
    group('tryCast', () {
      test('should return the value when the type matches', () {
        const Object? value = 'hi';
        expect(value.tryCast<String>(), 'hi');
      });

      test('should return null when the type does not match', () {
        const Object? value = 'hi';
        expect(value.tryCast<int>(), isNull);
      });

      test('should return null for a null receiver', () {
        const Object? value = null;
        expect(value.tryCast<String>(), isNull);
      });

      test('should cast up the hierarchy (int as num)', () {
        const Object? value = 42;
        expect(value.tryCast<num>(), 42);
      });
    });
  });

  group('isType', () {
    test('should return true when the value matches the type', () {
      expect(isType<String>('x'), isTrue);
    });

    test('should return false when the value does not match the type', () {
      expect(isType<int>('x'), isFalse);
    });

    test('should return false for null against a non-nullable type', () {
      expect(isType<String>(null), isFalse);
    });

    test('should return true for null against a nullable type', () {
      expect(isType<String?>(null), isTrue);
    });

    test('should be usable as a where predicate', () {
      final mixed = <Object?>[1, 'two', 3, 'four'];
      expect(mixed.where(isType<String>), <String>['two', 'four']);
    });
  });

  group('asTypeOr', () {
    test('should return the value when the type matches', () {
      expect(asTypeOr<int>(42, -1), 42);
    });

    test('should return the fallback when the type does not match', () {
      expect(asTypeOr<int>('not a number', -1), -1);
    });

    test('should return the fallback for null against a non-nullable type', () {
      expect(asTypeOr<int>(null, -1), -1);
    });
  });

  group('FirstOfTypeExtension', () {
    group('firstOfType', () {
      test('should return the first element of the requested type', () {
        final mixed = <Object?>[1, 'two', 3.0, 'four'];
        expect(mixed.firstOfType<String>(), 'two');
      });

      test('should return null when no element matches', () {
        final mixed = <Object?>[1, 'two', 3.0];
        expect(mixed.firstOfType<bool>(), isNull);
      });

      test('should return null for an empty list', () {
        expect(<Object?>[].firstOfType<int>(), isNull);
      });

      test('should skip null elements when matching a non-nullable type', () {
        final mixed = <Object?>[null, 'found'];
        expect(mixed.firstOfType<String>(), 'found');
      });
    });
  });

  group('ToListOrEmpty', () {
    group('toListOrEmpty', () {
      test('should wrap a non-null value in a single-element list', () {
        const int? value = 5;
        expect(value.toListOrEmpty(), <int>[5]);
      });

      test('should return an empty list for a null receiver', () {
        const String? value = null;
        expect(value.toListOrEmpty(), <String>[]);
      });

      test('should preserve falsy-but-non-null values like 0', () {
        const int? value = 0;
        expect(value.toListOrEmpty(), <int>[0]);
      });

      test('should preserve the empty string (non-null)', () {
        const String? value = '';
        expect(value.toListOrEmpty(), <String>['']);
      });
    });
  });
}
