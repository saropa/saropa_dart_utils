/// Apply patch (edit script) to string with validation (roadmap #403).
library;

import 'myers_diff_utils.dart';
import 'string_extensions.dart';

/// Result of applying a patch.
sealed class ApplyPatchUtils {
  const ApplyPatchUtils();
}

/// Patch applied successfully; [text] is the result.
final class ApplyPatchSuccess extends ApplyPatchUtils {
  const ApplyPatchSuccess(String text) : _text = text;
  final String _text;

  String get text => _text;

  @override
  String toString() => 'ApplyPatchSuccess(text: ${_text.length} chars)';
}

/// Patch could not be applied; [message] describes the conflict or error.
final class ApplyPatchConflict extends ApplyPatchUtils {
  const ApplyPatchConflict(String message) : _message = message;
  final String _message;

  String get message => _message;

  @override
  String toString() => 'ApplyPatchConflict(message: $_message)';
}

/// Applies an edit script [ops] to [baseText] (line-based).
///
/// Reconstructs text by taking lines from [baseText] for equal/delete and
/// from [ops] for insert. Validates that equal segments match [baseText];
/// returns [ApplyPatchConflict] if they do not.
ApplyPatchUtils applyPatch(String baseText, List<DiffOp> ops) {
  final List<String> lines = _splitLines(baseText);
  int lineIndex = 0;
  final StringBuffer out = StringBuffer();
  for (final DiffOp op in ops) {
    final List<String> opLines = _opToLines(op.text);
    switch (op.kind) {
      case DiffOpKind.equal:
        for (final String ln in opLines) {
          if (lineIndex >= lines.length) {
            return ApplyPatchConflict(
              'Expected line "${ln.trimRight()}" but base has no more lines',
            );
          }
          final String baseLine = lines[lineIndex];
          if (baseLine != ln) {
            return ApplyPatchConflict(
              'Conflict at line ${lineIndex + 1}: expected "${ln.trimRight()}", got "${baseLine.trimRight()}"',
            );
          }
          out.write(baseLine);
          lineIndex++;
        }
        break;
      case DiffOpKind.delete:
        for (final String ln in opLines) {
          if (lineIndex >= lines.length) {
            return ApplyPatchConflict(
              'Delete expected "${ln.trimRight()}" but base has no more lines',
            );
          }
          final String baseLine = lines[lineIndex];
          if (baseLine != ln) {
            return ApplyPatchConflict(
              'Conflict at line ${lineIndex + 1}: delete expected "${ln.trimRight()}", got "${baseLine.trimRight()}"',
            );
          }
          lineIndex++;
        }
        break;
      case DiffOpKind.insert:
        for (final String ln in opLines) {
          out.write(ln);
        }
        break;
    }
  }
  if (lineIndex < lines.length) {
    return ApplyPatchConflict('Base has ${lines.length - lineIndex} extra lines after patch');
  }
  return ApplyPatchSuccess(out.toString());
}

List<String> _splitLines(String s) {
  if (s.isEmpty) return <String>[];
  final List<String> out = <String>[];
  int start = 0;
  for (int i = 0; i < s.length; i++) {
    if (s[i] == '\n') {
      out.add(s.substringSafe(start, i + 1));
      start = i + 1;
    }
  }
  if (start < s.length) out.add(s.substringSafe(start));
  return out;
}

List<String> _opToLines(String text) {
  if (text.isEmpty) return <String>[];
  final List<String> out = <String>[];
  int start = 0;
  for (int i = 0; i < text.length; i++) {
    if (text[i] == '\n') {
      out.add(text.substringSafe(start, i + 1));
      start = i + 1;
    }
  }
  if (start < text.length) out.add(text.substringSafe(start));
  return out;
}
