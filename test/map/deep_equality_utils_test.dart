import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/map/deep_equality_utils.dart';

void main() {
  group('deepEquals', () {
    test('identical maps', () {
      expect(deepEquals(<String, dynamic>{'a': 1}, <String, dynamic>{'a': 1}), isTrue);
    });
    test('nested', () {
      expect(
        deepEquals(
          <String, dynamic>{
            'a': <int>[1, 2],
          },
          <String, dynamic>{
            'a': <int>[1, 2],
          },
        ),
        isTrue,
      );
    });
    test('different', () {
      expect(deepEquals(<String, int>{'a': 1}, <String, int>{'a': 2}), isFalse);
    });
  });
}
