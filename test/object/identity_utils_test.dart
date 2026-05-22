import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/object/identity_utils.dart';

void main() {
  group('identityEquals', () {
    test('returns true for the same reference', () {
      final List<int> a = <int>[1, 2];
      expect(identityEquals(a, a), isTrue);
    });

    test('returns false for distinct but equal objects', () {
      // Two separate list instances are equal by ==, but not identical.
      expect(identityEquals(<int>[1, 2], <int>[1, 2]), isFalse);
    });

    test('returns true for two nulls', () {
      expect(identityEquals<Object>(null, null), isTrue);
    });

    test('returns false when only one side is null', () {
      expect(identityEquals<Object>(null, 'x'), isFalse);
    });

    test('returns true for identical interned constants', () {
      const String s = 'hello';
      expect(identityEquals(s, 'hello'), isTrue);
    });
  });
}
