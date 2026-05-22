import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/apply_patch_utils.dart';
import 'package:saropa_dart_utils/string/myers_diff_utils.dart';

void main() {
  // cspell: disable
  group('ApplyPatchSuccess', () {
    test('should expose patched text', () {
      const ApplyPatchSuccess result = ApplyPatchSuccess('hello');
      expect(result.text, 'hello');
    });

    test('toString should report character count', () {
      expect(const ApplyPatchSuccess('abcde').toString(), 'ApplyPatchSuccess(text: 5 chars)');
    });
  });

  group('ApplyPatchConflict', () {
    test('should expose conflict message', () {
      const ApplyPatchConflict result = ApplyPatchConflict('boom');
      expect(result.message, 'boom');
    });

    test('toString should include the message', () {
      expect(const ApplyPatchConflict('boom').toString(), 'ApplyPatchConflict(message: boom)');
    });
  });

  group('applyPatch', () {
    test('should reconstruct the new text from a valid diff', () {
      const String base = 'a\nb\nc';
      const String revised = 'a\nx\nc';
      final List<DiffOp> ops = MyersDiffUtils.diffLines(base, revised);
      final ApplyPatchUtils result = applyPatch(base, ops);
      expect(result, isA<ApplyPatchSuccess>());
      expect((result as ApplyPatchSuccess).text, revised);
    });

    test('should apply a pure insertion', () {
      const String base = 'a\nc';
      const String revised = 'a\nb\nc';
      final ApplyPatchUtils result = applyPatch(base, MyersDiffUtils.diffLines(base, revised));
      expect((result as ApplyPatchSuccess).text, revised);
    });

    test('should apply a pure deletion', () {
      const String base = 'a\nb\nc';
      const String revised = 'a\nc';
      final ApplyPatchUtils result = applyPatch(base, MyersDiffUtils.diffLines(base, revised));
      expect((result as ApplyPatchSuccess).text, revised);
    });

    test('should return an empty-string success for empty base and empty ops', () {
      final ApplyPatchUtils result = applyPatch('', <DiffOp>[]);
      expect((result as ApplyPatchSuccess).text, '');
    });

    test('should conflict when an equal op does not match the base line', () {
      // Patch built against a different base: equal('a\n') but base starts 'z\n'.
      final List<DiffOp> ops = <DiffOp>[const DiffOp(DiffOpKind.equal, 'a\n')];
      final ApplyPatchUtils result = applyPatch('z\n', ops);
      expect(result, isA<ApplyPatchConflict>());
      expect((result as ApplyPatchConflict).message, contains('Conflict at line 1'));
    });

    test('should conflict when the base has extra trailing lines', () {
      final List<DiffOp> ops = <DiffOp>[const DiffOp(DiffOpKind.equal, 'a\n')];
      final ApplyPatchUtils result = applyPatch('a\nb', ops);
      expect(result, isA<ApplyPatchConflict>());
      expect((result as ApplyPatchConflict).message, contains('extra lines'));
    });

    test('should conflict when an equal op expects more lines than base has', () {
      final List<DiffOp> ops = <DiffOp>[const DiffOp(DiffOpKind.equal, 'a\nb\n')];
      final ApplyPatchUtils result = applyPatch('a\n', ops);
      expect(result, isA<ApplyPatchConflict>());
      expect((result as ApplyPatchConflict).message, contains('no more lines'));
    });
  });
}
