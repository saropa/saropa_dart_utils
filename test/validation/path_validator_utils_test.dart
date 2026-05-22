import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/validation/path_validator_utils.dart';

void main() {
  group('isPathSafe', () {
    test('plain descending path is safe', () {
      expect(isPathSafe('a/b/c', 'root'), isTrue);
    });

    test('path escaping above root is unsafe', () {
      expect(isPathSafe('../../../etc/passwd', 'root'), isFalse);
    });

    test('dot-dot within a deeper root stays safe', () {
      // root has 2 levels; climbing one level stays inside.
      expect(isPathSafe('../x', 'a/b'), isTrue);
    });

    test('current-dir segments ignored', () {
      expect(isPathSafe('./a/./b', 'root'), isTrue);
    });

    test('descend then ascend back is safe', () {
      expect(isPathSafe('a/../b', 'root'), isTrue);
    });

    test('backslashes normalized like slashes', () {
      expect(isPathSafe(r'a\b\c', 'root'), isTrue);
    });

    test('escaping with backslash dot-dot is unsafe', () {
      expect(isPathSafe(r'..\..\secret', 'root'), isFalse);
    });

    test('leading slash stripped, still safe', () {
      expect(isPathSafe('/a/b', 'root'), isTrue);
    });

    test('empty path is safe', () {
      expect(isPathSafe('', 'root'), isTrue);
    });

    test('single dot-dot back to filesystem root is safe', () {
      // depth from single-level root reaches 0, not below, so allowed.
      expect(isPathSafe('..', 'root'), isTrue);
    });

    test('two dot-dots from single-level root escapes', () {
      expect(isPathSafe('../..', 'root'), isFalse);
    });
  });
}
