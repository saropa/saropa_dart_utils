import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/text_diff_structured_utils.dart';

void main() {
  group('diffSequences', () {
    test('all-equal sequences produce only equal ops', () {
      expect(
        diffSequences<int>(<int>[1, 2, 3], <int>[1, 2, 3]),
        <SeqDiffOp<int>>[
          const SeqDiffOp<int>(SeqDiffKind.equal, 1),
          const SeqDiffOp<int>(SeqDiffKind.equal, 2),
          const SeqDiffOp<int>(SeqDiffKind.equal, 3),
        ],
      );
    });

    test('insertion in the middle', () {
      expect(
        diffSequences<int>(<int>[1, 3], <int>[1, 2, 3]),
        <SeqDiffOp<int>>[
          const SeqDiffOp<int>(SeqDiffKind.equal, 1),
          const SeqDiffOp<int>(SeqDiffKind.insert, 2),
          const SeqDiffOp<int>(SeqDiffKind.equal, 3),
        ],
      );
    });

    test('deletion at the end', () {
      expect(
        diffSequences<int>(<int>[1, 2, 3], <int>[1]),
        <SeqDiffOp<int>>[
          const SeqDiffOp<int>(SeqDiffKind.equal, 1),
          const SeqDiffOp<int>(SeqDiffKind.delete, 2),
          const SeqDiffOp<int>(SeqDiffKind.delete, 3),
        ],
      );
    });

    test('replacement appears as delete then insert', () {
      expect(
        diffSequences<String>(<String>['a', 'b'], <String>['a', 'c']),
        <SeqDiffOp<String>>[
          const SeqDiffOp<String>(SeqDiffKind.equal, 'a'),
          const SeqDiffOp<String>(SeqDiffKind.delete, 'b'),
          const SeqDiffOp<String>(SeqDiffKind.insert, 'c'),
        ],
      );
    });

    test('empty inputs', () {
      expect(diffSequences<int>(<int>[], <int>[]), isEmpty);
      expect(
        diffSequences<int>(<int>[], <int>[9]),
        <SeqDiffOp<int>>[const SeqDiffOp<int>(SeqDiffKind.insert, 9)],
      );
    });
  });

  group('diffWords', () {
    test('marks the changed word added and the old one removed', () {
      final List<SeqDiffOp<String>> ops = diffWords('the quick fox', 'the slow fox');
      expect(ops, <SeqDiffOp<String>>[
        const SeqDiffOp<String>(SeqDiffKind.equal, 'the'),
        const SeqDiffOp<String>(SeqDiffKind.delete, 'quick'),
        const SeqDiffOp<String>(SeqDiffKind.insert, 'slow'),
        const SeqDiffOp<String>(SeqDiffKind.equal, 'fox'),
      ]);
    });
  });

  group('diffSentences', () {
    test('keeps the shared sentence and diffs the changed one', () {
      final List<SeqDiffOp<String>> ops = diffSentences(
        'Hello there. How are you?',
        'Hello there. How is it?',
      );
      expect(ops.first, const SeqDiffOp<String>(SeqDiffKind.equal, 'Hello there.'));
      expect(ops.any((SeqDiffOp<String> o) => o.kind == SeqDiffKind.delete), isTrue);
      expect(ops.any((SeqDiffOp<String> o) => o.kind == SeqDiffKind.insert), isTrue);
    });
  });
}
