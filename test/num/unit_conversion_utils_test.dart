import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/num/unit_conversion_utils.dart';

void main() {
  group('LengthConversionUtils', () {
    group('convertMetersToFeet / convertFeetToMeters', () {
      test('round-trips within float tolerance', () {
        expect(
          LengthConversionUtils.convertFeetToMeters(
            LengthConversionUtils.convertMetersToFeet(1.78),
          ),
          closeTo(1.78, 1e-9),
        );
      });

      test('known values', () {
        expect(LengthConversionUtils.convertMetersToFeet(1), closeTo(3.280839895, 1e-9));
        expect(LengthConversionUtils.convertFeetToMeters(3.280839895), closeTo(1, 1e-9));
      });

      test('zero and negative scale linearly', () {
        expect(LengthConversionUtils.convertMetersToFeet(0), 0);
        expect(LengthConversionUtils.convertMetersToFeet(-2), closeTo(-6.56167979, 1e-6));
        expect(LengthConversionUtils.convertFeetToMeters(-3.280839895), closeTo(-1, 1e-9));
      });

      test('NaN and infinity propagate', () {
        expect(LengthConversionUtils.convertMetersToFeet(double.nan).isNaN, isTrue);
        expect(LengthConversionUtils.convertMetersToFeet(double.infinity), double.infinity);
        expect(
          LengthConversionUtils.convertFeetToMeters(double.negativeInfinity),
          double.negativeInfinity,
        );
      });

      test('very large and very small magnitudes keep precision', () {
        expect(
          LengthConversionUtils.convertFeetToMeters(
            LengthConversionUtils.convertMetersToFeet(1e12),
          ),
          closeTo(1e12, 1e3),
        );
        expect(
          LengthConversionUtils.convertFeetToMeters(
            LengthConversionUtils.convertMetersToFeet(1e-9),
          ),
          closeTo(1e-9, 1e-18),
        );
      });
    });

    group('feetToString', () {
      test('with/without inches + abbreviations', () {
        expect(LengthConversionUtils.feetToString(5.5), '5 feet 6 inches');
        expect(
          LengthConversionUtils.feetToString(5.5, useAbbreviations: true),
          '5 ft 6 in',
        );
        expect(LengthConversionUtils.feetToString(5.5, showInches: false), '5.5 feet');
        expect(
          LengthConversionUtils.feetToString(5.5, showInches: false, useAbbreviations: true),
          '5.5 ft',
        );
      });

      test('carries rounded inches into feet at the 12-inch boundary', () {
        // 0.9999 ft * 12 = 11.9988 in, which rounds to 12.00 at 2 places and
        // must become 1 ft 0 in rather than "0 feet 12 inches".
        expect(LengthConversionUtils.feetToString(5.9999), '6 feet 0 inches');
        // decimalPlaces: 0 rounds 11.988 to 12 as well.
        expect(
          LengthConversionUtils.feetToString(5.999, decimalPlaces: 0),
          '6 feet 0 inches',
        );
      });

      test('does not carry when inches stay below 12 at the chosen precision', () {
        expect(LengthConversionUtils.feetToString(5.99), '5 feet 11.88 inches');
      });

      test('negative heights render with a leading sign', () {
        expect(LengthConversionUtils.feetToString(-5.5), '-5 feet 6 inches');
        expect(
          LengthConversionUtils.feetToString(-5.5, useAbbreviations: true),
          '-5 ft 6 in',
        );
      });

      test('decimalPlaces: 0 with whole feet', () {
        expect(LengthConversionUtils.feetToString(5, decimalPlaces: 0), '5 feet 0 inches');
      });

      test('non-finite input falls back to the single-value form', () {
        expect(LengthConversionUtils.feetToString(double.nan), 'NaN feet');
        expect(LengthConversionUtils.feetToString(double.infinity), '∞ feet');
        expect(
          LengthConversionUtils.feetToString(double.negativeInfinity, useAbbreviations: true),
          '-∞ ft',
        );
      });
    });

    group('metersToString', () {
      test('full name and abbreviation', () {
        expect(LengthConversionUtils.metersToString(1.78), '1.78 meters');
        expect(
          LengthConversionUtils.metersToString(1.78, useAbbreviations: true),
          '1.78 m',
        );
      });

      test('drops trailing zeros', () {
        expect(LengthConversionUtils.metersToString(2), '2 meters');
      });
    });
  });

  group('WeightConversionUtils', () {
    group('convertKilogramsToPounds / convertPoundsToKilograms', () {
      test('round-trips', () {
        expect(
          WeightConversionUtils.convertPoundsToKilograms(
            WeightConversionUtils.convertKilogramsToPounds(80),
          ),
          closeTo(80, 1e-9),
        );
      });

      test('known values', () {
        expect(
          WeightConversionUtils.convertKilogramsToPounds(1),
          closeTo(2.2046226218, 1e-9),
        );
        expect(
          WeightConversionUtils.convertPoundsToKilograms(2.2046226218),
          closeTo(1, 1e-9),
        );
      });

      test('zero and negative scale linearly', () {
        expect(WeightConversionUtils.convertKilogramsToPounds(0), 0);
        expect(
          WeightConversionUtils.convertKilogramsToPounds(-10),
          closeTo(-22.046226218, 1e-9),
        );
      });

      test('NaN and infinity propagate', () {
        expect(WeightConversionUtils.convertKilogramsToPounds(double.nan).isNaN, isTrue);
        expect(
          WeightConversionUtils.convertPoundsToKilograms(double.infinity),
          double.infinity,
        );
      });
    });

    group('poundsToString / kilogramsToString', () {
      test('full names and abbreviations', () {
        expect(WeightConversionUtils.poundsToString(80), '80 pounds');
        expect(
          WeightConversionUtils.poundsToString(80, useAbbreviations: true),
          '80 lbs',
        );
        expect(WeightConversionUtils.kilogramsToString(80), '80 kilograms');
        expect(
          WeightConversionUtils.kilogramsToString(80, useAbbreviations: true),
          '80 kg',
        );
      });

      test('non-finite input renders the symbol', () {
        expect(WeightConversionUtils.kilogramsToString(double.nan), 'NaN kilograms');
        expect(WeightConversionUtils.poundsToString(double.infinity), '∞ pounds');
      });
    });
  });
}
