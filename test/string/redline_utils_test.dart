import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/redline_utils.dart';

void main() {
  group('redlineDiff', () {
    test('should return empty list for two empty inputs', () {
      expect(redlineDiff([], []), isEmpty);
    });

    test('should mark every line unchanged for identical inputs', () {
      final result = redlineDiff(['a', 'b'], ['a', 'b']);
      expect(result.map((e) => e.op), [RedlineOp.unchanged, RedlineOp.unchanged]);
      expect(result.first.oldLineNo, 1);
      expect(result.first.newLineNo, 1);
      expect(result.last.text, 'b');
    });

    test('should mark all lines added when old is empty', () {
      final result = redlineDiff([], ['x', 'y']);
      expect(result.map((e) => e.op), [RedlineOp.added, RedlineOp.added]);
      expect(result.first.oldLineNo, isNull);
      expect(result.first.newLineNo, 1);
      expect(result.last.newLineNo, 2);
    });

    test('should mark all lines removed when new is empty', () {
      final result = redlineDiff(['x', 'y'], []);
      expect(result.map((e) => e.op), [RedlineOp.removed, RedlineOp.removed]);
      expect(result.first.oldLineNo, 1);
      expect(result.first.newLineNo, isNull);
      expect(result.first.text, 'x');
    });

    test('should pair an adjacent remove+add as a single changed entry', () {
      // Line 2 edited from 'b' to 'c': default pairChanges collapses it.
      final result = redlineDiff(['a', 'b'], ['a', 'c']);
      expect(result.map((e) => e.op), [RedlineOp.unchanged, RedlineOp.changed]);
      final changed = result.last;
      expect(changed.oldLineNo, 2);
      expect(changed.newLineNo, 2);
      expect(changed.text, 'c');
    });

    test('should keep removed and added separate when pairChanges is false', () {
      final result = redlineDiff(['a', 'b'], ['a', 'c'], pairChanges: false);
      expect(result.map((e) => e.op), [
        RedlineOp.unchanged,
        RedlineOp.removed,
        RedlineOp.added,
      ]);
    });

    test('should detect a pure insertion in the middle', () {
      final result = redlineDiff(['a', 'c'], ['a', 'b', 'c']);
      expect(result.map((e) => e.op), [
        RedlineOp.unchanged,
        RedlineOp.added,
        RedlineOp.unchanged,
      ]);
      expect(result[1].newLineNo, 2);
      expect(result[1].text, 'b');
    });

    test('should detect a pure deletion in the middle', () {
      final result = redlineDiff(['a', 'b', 'c'], ['a', 'c']);
      expect(result.map((e) => e.op), [
        RedlineOp.unchanged,
        RedlineOp.removed,
        RedlineOp.unchanged,
      ]);
      expect(result[1].oldLineNo, 2);
      expect(result[1].text, 'b');
    });

    test('should align unchanged lines across multiple edits via LCS', () {
      final result = redlineDiff(
        ['keep1', 'old', 'keep2'],
        ['keep1', 'new', 'keep2'],
      );
      expect(result.map((e) => e.op), [
        RedlineOp.unchanged,
        RedlineOp.changed,
        RedlineOp.unchanged,
      ]);
    });

    test('should handle Unicode and emoji lines', () {
      final result = redlineDiff(['héllo 世界'], ['héllo 🌍']);
      expect(result.single.op, RedlineOp.changed);
      expect(result.single.text, 'héllo 🌍');
    });

    test('should return an unmodifiable list', () {
      final result = redlineDiff(['a'], ['a']);
      expect(
        () => result.add(const RedlineEntry(RedlineOp.added, null, 9, 'x')),
        throwsUnsupportedError,
      );
    });
  });

  group('RedlineEntry', () {
    test('should be equal by value', () {
      const a = RedlineEntry(RedlineOp.changed, 1, 1, 'x');
      const b = RedlineEntry(RedlineOp.changed, 1, 1, 'x');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('should differ when op differs', () {
      const a = RedlineEntry(RedlineOp.added, null, 1, 'x');
      const b = RedlineEntry(RedlineOp.removed, 1, null, 'x');
      expect(a, isNot(b));
    });

    test('should render null line numbers as dashes in toString', () {
      const entry = RedlineEntry(RedlineOp.added, null, 3, 'x');
      expect(entry.toString(), contains('old=-'));
      expect(entry.toString(), contains('new=3'));
    });
  });
}
