import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/unique_list_extensions.dart';

void main() {
  group('toUnique', () {
    test('removes duplicate values, preserving first-seen order', () {
      expect(<int>[1, 2, 2, 3, 1].toUnique(), <int>[1, 2, 3]);
    });

    test('drops nulls by default', () {
      expect(<int?>[1, null, 2, null].toUnique(), <int?>[1, 2]);
    });

    test('keeps a single null when ignoreNulls is false', () {
      expect(<int?>[1, null, 2, null].toUnique(ignoreNulls: false), <int?>[1, null, 2]);
    });

    test('empty list yields empty', () {
      expect(<int>[].toUnique(), isEmpty);
    });
  });
}
