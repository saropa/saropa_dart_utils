import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/map/map_pick_omit_extensions.dart';

void main() {
  group('pick', () {
    test('basic', () {
      expect(<String, int>{'a': 1, 'b': 2, 'c': 3}.pick(['a', 'c']), {'a': 1, 'c': 3});
    });
  });
  group('omit', () {
    test('basic', () {
      expect(<String, int>{'a': 1, 'b': 2, 'c': 3}.omit(['b']), {'a': 1, 'c': 3});
    });
  });
}
