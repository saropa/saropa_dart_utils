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

    test('single dot-dot escaping a multi-level root is unsafe (traversal bypass)', () {
      // The reported bypass: '../secret' from 'home/user' resolves to
      // 'home/secret', a sibling outside the root. Must be rejected.
      expect(isPathSafe('../secret', 'home/user'), isFalse);
    });

    test('dot-dot that climbs above a deeper root is unsafe (regression)', () {
      // '../x' from root 'a/b' resolves to 'a/x' — a SIBLING of the root, outside
      // it. The old code measured depth from the filesystem root and wrongly
      // allowed climbing rootParts.length levels above the supplied root.
      expect(isPathSafe('../x', 'a/b'), isFalse);
    });

    test('internal dot-dot that stays within root is safe', () {
      // 'sub/../x' from 'a/b' is 'a/b/x' — never leaves the root.
      expect(isPathSafe('sub/../x', 'a/b'), isTrue);
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

    test('single dot-dot above the root is unsafe (regression)', () {
      // '..' from 'root' resolves to the root's parent, outside the root.
      expect(isPathSafe('..', 'root'), isFalse);
    });

    test('two dot-dots from single-level root escapes', () {
      expect(isPathSafe('../..', 'root'), isFalse);
    });
  });
}
