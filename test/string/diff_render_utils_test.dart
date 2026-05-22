import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/diff_render_utils.dart';
import 'package:saropa_dart_utils/string/myers_diff_utils.dart';

void main() {
  // cspell: disable
  // ANSI escape introducer (0x1B). Built from a code unit so the source file
  // contains no literal control characters.
  final String esc = String.fromCharCode(0x1b);

  group('DiffOutputFormat', () {
    test('should expose three formats', () {
      expect(DiffOutputFormat.values, <DiffOutputFormat>[
        DiffOutputFormat.plain,
        DiffOutputFormat.ansi,
        DiffOutputFormat.html,
      ]);
    });
  });

  group('renderUnifiedDiff', () {
    test('should render plain diff with space/+/- prefixes', () {
      final List<DiffOp> ops = <DiffOp>[
        const DiffOp(DiffOpKind.equal, 'a\n'),
        const DiffOp(DiffOpKind.insert, 'b\n'),
        const DiffOp(DiffOpKind.delete, 'c\n'),
      ];
      expect(renderUnifiedDiff(ops), '  a\n+ b\n- c\n');
    });

    test('should wrap deletions in ANSI red and additions in green', () {
      final List<DiffOp> ops = <DiffOp>[
        const DiffOp(DiffOpKind.insert, 'add\n'),
        const DiffOp(DiffOpKind.delete, 'rem\n'),
      ];
      final String expected = '${esc}[32m+ add\n$esc[0m${esc}[31m- rem\n$esc[0m';
      expect(renderUnifiedDiff(ops, format: DiffOutputFormat.ansi), expected);
    });

    test('should leave equal lines uncolored in ANSI', () {
      final List<DiffOp> ops = <DiffOp>[const DiffOp(DiffOpKind.equal, 'x\n')];
      expect(renderUnifiedDiff(ops, format: DiffOutputFormat.ansi), '  x\n');
    });

    test('should render HTML spans with classes', () {
      final List<DiffOp> ops = <DiffOp>[
        const DiffOp(DiffOpKind.equal, 'ctx\n'),
        const DiffOp(DiffOpKind.insert, 'new\n'),
        const DiffOp(DiffOpKind.delete, 'old\n'),
      ];
      expect(
        renderUnifiedDiff(ops, format: DiffOutputFormat.html),
        '<span class="diff-context">  ctx\n</span>'
            '<span class="diff-add">+ new\n</span>'
            '<span class="diff-remove">- old\n</span>',
      );
    });

    test('should HTML-escape special characters in lines', () {
      final List<DiffOp> ops = <DiffOp>[const DiffOp(DiffOpKind.insert, '<a> & "b"\n')];
      expect(
        renderUnifiedDiff(ops, format: DiffOutputFormat.html),
        '<span class="diff-add">+ &lt;a&gt; &amp; &quot;b&quot;\n</span>',
      );
    });

    test('should skip empty-text ops', () {
      final List<DiffOp> ops = <DiffOp>[const DiffOp(DiffOpKind.equal, '')];
      expect(renderUnifiedDiff(ops), '');
    });

    test('should return empty string for no ops', () {
      expect(renderUnifiedDiff(<DiffOp>[]), '');
    });

    test('should omit middle lines of a long equal run with small contextLines', () {
      final List<DiffOp> ops = <DiffOp>[
        const DiffOp(DiffOpKind.equal, 'l1\nl2\nl3\nl4\nl5\nl6\n'),
      ];
      final String result = renderUnifiedDiff(ops, contextLines: 1);
      expect(result.contains('lines omitted'), isTrue);
      expect(result.startsWith('  l1\n'), isTrue);
      expect(result.endsWith('  l6\n'), isTrue);
    });
  });
}
