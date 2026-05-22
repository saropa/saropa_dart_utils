import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_symmetric_diff_extensions.dart';

void main() {
  group('symmetricDifference', () {
    test('elements in either but not both', () {
      // {1,2,3} ^ {2,3,4} = {1,4}
      expect(
        <int>[1, 2, 3].symmetricDifference(<int>[2, 3, 4]).toSet(),
        <int>{1, 4},
      );
    });

    test('this-only elements come before other-only elements', () {
      // Implementation lists this-only first, then other-only.
      expect(
        <int>[1, 2, 3].symmetricDifference(<int>[2, 3, 4]),
        <int>[1, 4],
      );
    });

    test('identical sets yield empty', () {
      expect(<int>[1, 2].symmetricDifference(<int>[1, 2]), <int>[]);
    });

    test('disjoint sets yield all elements', () {
      expect(
        <int>[1, 2].symmetricDifference(<int>[3, 4]).toSet(),
        <int>{1, 2, 3, 4},
      );
    });

    test('empty other returns this elements', () {
      expect(<int>[1, 2].symmetricDifference(<int>[]).toSet(), <int>{1, 2});
    });

    test('empty this returns other elements', () {
      expect(<int>[].symmetricDifference(<int>[3, 4]).toSet(), <int>{3, 4});
    });

    test('both empty yields empty', () {
      expect(<int>[].symmetricDifference(<int>[]), <int>[]);
    });

    test('duplicates collapse via set semantics', () {
      expect(
        <int>[1, 1, 2].symmetricDifference(<int>[2, 2, 3]).toSet(),
        <int>{1, 3},
      );
    });
  });
}
