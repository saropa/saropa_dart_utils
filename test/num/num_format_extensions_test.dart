import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/num/num_format_extensions.dart';

void main() {
  group('roundToSignificantDigits', () {
    test('basic', () {
      expect(1234.0.roundToSignificantDigits(2), closeTo(1200, 1));
    });
    test('exact powers of ten round correctly (regression)', () {
      // log10 float-fuzziness previously mis-sized the scale at powers of ten.
      expect(1000.0.roundToSignificantDigits(3), closeTo(1000, 1e-9));
      expect(0.001.roundToSignificantDigits(1), closeTo(0.001, 1e-12));
      expect(0.001.roundToSignificantDigits(3), closeTo(0.001, 1e-12));
    });
  });
  group('toCompactString', () {
    test('K', () => expect(1200.toCompactString(), '1.2K'));
    test('plain', () => expect(500.toCompactString(), '500'));
  });
}
