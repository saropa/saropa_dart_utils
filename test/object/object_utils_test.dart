import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/object/coalesce_utils.dart';
import 'package:saropa_dart_utils/object/default_value_extensions.dart';
import 'package:saropa_dart_utils/object/pipe_utils.dart';
import 'package:saropa_dart_utils/object/require_utils.dart';
import 'package:saropa_dart_utils/object/shallow_copy_utils.dart';

void main() {
  group('requireNonNull', () {
    test('returns value', () => expect(requireNonNull(1), 1));
    test('throws on null', () => expect(() => requireNonNull<int>(null), throwsArgumentError));
  });
  group('also', () {
    test('calls and returns same', () {
      int side = 0;
      expect(also(5, (int x) => side = x), 5);
      expect(side, 5);
    });
  });
  group('let', () {
    test('transforms', () => expect(let(2, (int x) => x * 3), 6));
  });
  group('coalesce', () {
    test('first non-null', () => expect(coalesce(<int?>[null, null, 3, 4]), 3));
  });
  group('orDefault', () {
    test('null returns default', () => expect((null as int?).orDefault(0), 0));
    test('non-null returns self', () => expect(5.orDefault(0), 5));
  });
  group('shallowCopyList', () {
    test('copy', () {
      final List<int> a = <int>[1, 2];
      final List<int> b = shallowCopyList(a);
      b[0] = 9;
      expect(a[0], 1);
    });
  });
}
