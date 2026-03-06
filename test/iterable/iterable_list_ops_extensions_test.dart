import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_list_ops_extensions.dart';

void main() {
  group('difference', () {
    test('basic', () => expect(<int>[1, 2, 3].difference([2]), [1, 3]));
  });
  group('intersection', () {
    test('basic', () => expect(<int>[1, 2, 3].intersection([2, 3]), [2, 3]));
  });
  group('union', () {
    test('basic', () => expect(<int>[1, 2].union([2, 3]), hasLength(3)));
  });
  group('interleave', () {
    test('basic', () => expect(<int>[1, 3].interleave([2, 4]), [1, 2, 3, 4]));
  });
}
