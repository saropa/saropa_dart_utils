/// Diff two strings (line-by-line). Roadmap #224.
List<String> stringDiffLines(String a, String b) {
  final List<String> linesA = a.split('\n');
  final List<String> linesB = b.split('\n');
  final List<String> out = <String>[];
  final int maxLen = linesA.length > linesB.length ? linesA.length : linesB.length;
  for (int i = 0; i < maxLen; i++) {
    final String lineA = i < linesA.length ? linesA[i] : '';
    final String lineB = i < linesB.length ? linesB[i] : '';
    if (lineA != lineB) {
      out.add('${i + 1}: - $lineA');
      out.add('${i + 1}: + $lineB');
    }
  }
  return out;
}
