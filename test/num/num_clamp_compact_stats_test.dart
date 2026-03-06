import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/num/num_clamp_extensions.dart';
import 'package:saropa_dart_utils/num/num_compact_parse_extensions.dart';
import 'package:saropa_dart_utils/num/num_stats_utils.dart';

void main() {
  group('clampToInt', () {
    test('clamps and rounds', () {
      expect(5.7.clampToInt(0, 10), 6);
      expect((-1.2).clampToInt(0, 10), 0);
    });
  });
  group('parseCompactNumber', () {
    test('parses 1.2K', () {
      expect(parseCompactNumber('1.2K'), 1200);
    });
    test('parses 2M', () {
      expect(parseCompactNumber('2M'), 2000000);
    });
    test('invalid returns null', () {
      expect(parseCompactNumber(''), isNull);
    });
  });
  group('variance', () {
    test('population variance', () {
      expect(variance(<num>[1, 2, 3, 4, 5], isPopulation: true), 2.0);
    });
  });
  group('standardDeviation', () {
    test('non-empty', () {
      expect(standardDeviation(<num>[2, 4, 4, 4, 5, 5, 7, 9]), inInclusiveRange(2.0, 2.2));
    });
  });
  group('median', () {
    test('odd length', () {
      expect(median(<num>[1, 3, 5]), 3);
    });
    test('even length', () {
      expect(median(<num>[1, 3, 5, 7]), 4);
    });
  });
  group('percentile', () {
    test('0.5 is median-ish', () {
      expect(percentile(<num>[1, 2, 3, 4, 5], 0.5), 3);
    });
  });
}
