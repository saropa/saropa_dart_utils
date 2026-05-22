import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/run_detection_utils.dart';

void main() {
  group('RunDetectionUtils (run)', () {
    test('should expose start, length, and value', () {
      const RunDetectionUtils<int> run = RunDetectionUtils<int>(2, 3, 7);
      expect(run.start, 2);
      expect(run, hasLength(3));
      expect(run.value, 7);
    });

    test('should allow null value', () {
      const RunDetectionUtils<int> run = RunDetectionUtils<int>(0, 1, null);
      expect(run.value, isNull);
    });

    test('should format toString with dash for null value', () {
      expect(
        const RunDetectionUtils<int>(0, 2, null).toString(),
        'RunDetectionUtils(start: 0, length: 2, value: -)',
      );
    });

    test('should format toString with the value', () {
      expect(
        const RunDetectionUtils<int>(1, 2, 5).toString(),
        'RunDetectionUtils(start: 1, length: 2, value: 5)',
      );
    });
  });

  group('runsEqual', () {
    test('should detect consecutive equal runs', () {
      final List<RunDetectionUtils<int>> runs = runsEqual<int>([1, 1, 2, 2, 2, 3]);
      expect(runs.map((RunDetectionUtils<int> r) => (r.start, r.length, r.value)).toList(), [
        (0, 2, 1),
        (2, 3, 2),
        (5, 1, 3),
      ]);
    });

    test('should return empty list for empty input', () {
      expect(runsEqual<int>(<int>[]), <RunDetectionUtils<int>>[]);
    });

    test('should produce one run of length 1 for a single element', () {
      final List<RunDetectionUtils<int>> runs = runsEqual<int>([9]);
      expect(runs, hasLength(1));
      expect((runs.first.start, runs.first.length, runs.first.value), (0, 1, 9));
    });

    test('should produce a single run when all elements are equal', () {
      final List<RunDetectionUtils<int>> runs = runsEqual<int>([5, 5, 5, 5]);
      expect(runs, hasLength(1));
      expect(runs.first, hasLength(4));
    });

    test('should produce one run per element when all differ', () {
      final List<RunDetectionUtils<int>> runs = runsEqual<int>([1, 2, 3]);
      expect(runs, hasLength(3));
      expect(runs.every((RunDetectionUtils<int> r) => r.length == 1), isTrue);
    });

    test('should work with strings', () {
      final List<RunDetectionUtils<String>> runs = runsEqual<String>(['a', 'a', 'b']);
      expect(runs.map((RunDetectionUtils<String> r) => (r.value, r.length)).toList(), [
        ('a', 2),
        ('b', 1),
      ]);
    });
  });
}
