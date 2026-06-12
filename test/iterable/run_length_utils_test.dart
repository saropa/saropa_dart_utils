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

    test('encodes and round-trips a run of nulls (nullable T)', () {
      // The old `prev == null` sentinel dropped/miscounted a leading null run.
      final List<(int?, int)> encoded = <int?>[null, null, 1, 1].runLengthEncode();
      expect(encoded, <(int?, int)>[(null, 2), (1, 2)]);
      expect(runLengthDecode<int?>(encoded), <int?>[null, null, 1, 1]);
    });
  });
}
