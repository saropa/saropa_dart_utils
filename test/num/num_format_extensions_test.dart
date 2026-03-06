import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/num/num_format_extensions.dart';

void main() {
  group('roundToSignificantDigits', () {
    test('basic', () {
      expect(1234.0.roundToSignificantDigits(2), closeTo(1200, 1));
    });
  });
  group('toCompactString', () {
    test('K', () => expect(1200.toCompactString(), '1.2K'));
    test('plain', () => expect(500.toCompactString(), '500'));
  });
}
