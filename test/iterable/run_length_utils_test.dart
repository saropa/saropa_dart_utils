import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/run_length_utils.dart';

void main() {
  group('runLengthEncode', () {
    test('basic', () {
      expect([1, 1, 2, 2, 2].runLengthEncode(), [(1, 2), (2, 3)]);
    });
    test('empty', () => expect(<int>[].runLengthEncode(), <(int, int)>[]));
  });
  group('runLengthDecode', () {
    test('basic', () {
      expect(runLengthDecode<int>([(1, 2), (2, 3)]), [1, 1, 2, 2, 2]);
    });
  });
}
