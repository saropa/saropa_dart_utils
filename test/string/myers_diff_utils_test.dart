import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/myers_diff_utils.dart';

/// Convenience matcher: turns ops into (kind, text) tuples for exact assertion.
List<(DiffOpKind, String)> _tuples(List<DiffOp> ops) =>
    ops.map((DiffOp o) => (o.kind, o.text)).toList();

void main() {
  // cspell: disable
  group('DiffOpKind', () {
    test('should expose three values', () {
      expect(DiffOpKind.values, <DiffOpKind>[
        DiffOpKind.equal,
        DiffOpKind.insert,
        DiffOpKind.delete,
      ]);
    });
  });

  group('DiffOp', () {
    test('should expose kind and text', () {
      const DiffOp op = DiffOp(DiffOpKind.insert, 'hello');
      expect(op.kind, DiffOpKind.insert);
      expect(op.text, 'hello');
    });

    test('toString should report kind and char length', () {
      expect(const DiffOp(DiffOpKind.equal, 'abcd').toString(), 'DiffOp(DiffOpKind.equal, 4 chars)');
    });
  });

  group('MyersDiffUtils.diffLines', () {
    test('should return single equal op for identical text', () {
      expect(
        _tuples(MyersDiffUtils.diffLines('a\nb\nc', 'a\nb\nc')),
        <(DiffOpKind, String)>[(DiffOpKind.equal, 'a\nb\nc')],
      );
    });

    test('should detect a one-line substitution (delete before insert)', () {
      // For a substitution the backtrack emits the delete of the old line before
      // the insert of the new line.
      expect(
        _tuples(MyersDiffUtils.diffLines('a\nb\nc', 'a\nx\nc')),
        <(DiffOpKind, String)>[
          (DiffOpKind.equal, 'a\n'),
          (DiffOpKind.delete, 'b\n'),
          (DiffOpKind.insert, 'x\n'),
          (DiffOpKind.equal, 'c'),
        ],
      );
    });

    test('should report pure insertion', () {
      expect(
        _tuples(MyersDiffUtils.diffLines('a\nc', 'a\nb\nc')),
        <(DiffOpKind, String)>[
          (DiffOpKind.equal, 'a\n'),
          (DiffOpKind.insert, 'b\n'),
          (DiffOpKind.equal, 'c'),
        ],
      );
    });

    test('should report pure deletion', () {
      expect(
        _tuples(MyersDiffUtils.diffLines('a\nb\nc', 'a\nc')),
        <(DiffOpKind, String)>[
          (DiffOpKind.equal, 'a\n'),
          (DiffOpKind.delete, 'b\n'),
          (DiffOpKind.equal, 'c'),
        ],
      );
    });

    test('should merge adjacent inserts into one multi-line op', () {
      expect(
        _tuples(MyersDiffUtils.diffLines('', 'x\ny')),
        <(DiffOpKind, String)>[(DiffOpKind.insert, 'x\ny')],
      );
    });

    test('should produce only deletes when new text is empty', () {
      expect(
        _tuples(MyersDiffUtils.diffLines('x\ny', '')),
        <(DiffOpKind, String)>[(DiffOpKind.delete, 'x\ny')],
      );
    });

    test('should return empty list when both inputs are empty', () {
      expect(MyersDiffUtils.diffLines('', ''), <DiffOp>[]);
    });
  });
}
