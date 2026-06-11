// Tests for FilterValue<T> — pins the three intents the wrapper distinguishes
// (unset / set-to-value / set-to-null) so a future refactor cannot collapse the
// explicit-clear-to-null path back into the implicit "no override" path.
//
// The bulletproofing groups below extend the three core intents across numeric
// edge values (0, negatives, NaN, infinities, int min/max), Unicode/emoji
// strings, reference identity for collections, const canonicalization, and a
// nested-generic composition case — confirming the wrapper holds whatever it is
// given byte-for-byte / reference-for-reference and never inspects the value.

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/copy_with/filter_value.dart';

void main() {
  group('FilterValue<T>', () {
    group('unset', () {
      test('isSet is false and value is null', () {
        const FilterValue<bool> unset = FilterValue<bool>.unset();

        expect(unset.isSet, isFalse);
        expect(unset.value, isNull);
      });

      test('resolve returns the supplied current value (keep-existing path)', () {
        const FilterValue<bool> unset = FilterValue<bool>.unset();

        expect(unset.resolve(true), isTrue);
        expect(unset.resolve(false), isFalse);
        expect(unset.resolve(null), isNull);
      });
    });

    group('set to a non-null value', () {
      test('isSet is true and value is the supplied value', () {
        const FilterValue<bool> setTrue = FilterValue<bool>(true);

        expect(setTrue.isSet, isTrue);
        expect(setTrue.value, isTrue);
      });

      test('resolve overrides the current value', () {
        const FilterValue<bool> setTrue = FilterValue<bool>(true);

        // Override applies even when the current value differs.
        expect(setTrue.resolve(false), isTrue);
        expect(setTrue.resolve(null), isTrue);
      });
    });

    group('set explicitly to null', () {
      // This is the case the prior `*ForceNull` companion-parameter pattern
      // existed to express. The wrapper must keep it distinguishable from the
      // unset case — otherwise filter reset is impossible through copyWith.
      test('isSet is true and value is null', () {
        const FilterValue<bool> clearedToNull = FilterValue<bool>(null);

        expect(clearedToNull.isSet, isTrue);
        expect(clearedToNull.value, isNull);
      });

      test('resolve returns null regardless of the current value', () {
        const FilterValue<bool> clearedToNull = FilterValue<bool>(null);

        expect(clearedToNull.resolve(true), isNull);
        expect(clearedToNull.resolve(false), isNull);
        expect(clearedToNull.resolve(null), isNull);
      });
    });

    test('works for non-bool generic types', () {
      const FilterValue<String> unset = FilterValue<String>.unset();
      const FilterValue<String> setValue = FilterValue<String>('hello');
      const FilterValue<String> setNull = FilterValue<String>(null);

      expect(unset.resolve('current'), equals('current'));
      expect(setValue.resolve('current'), equals('hello'));
      expect(setNull.resolve('current'), isNull);
    });

    group('numeric type coverage', () {
      // Zero is falsy-looking; guard against any accidental `value ?? current`
      // collapse that would treat 0 as "unset".
      test('int zero is set and resolves to 0, not the current value', () {
        const FilterValue<int> setZero = FilterValue<int>(0);

        expect(setZero.isSet, isTrue);
        expect(setZero.value, 0);
        expect(setZero.resolve(5), 0);
      });

      test('negative int is preserved', () {
        const FilterValue<int> setNeg = FilterValue<int>(-1);

        expect(setNeg.value, -1);
        expect(setNeg.resolve(5), -1);
      });

      test('double 0.0 and -0.0 are both set and resolve exactly', () {
        const FilterValue<double> setPosZero = FilterValue<double>(0.0);
        const FilterValue<double> setNegZero = FilterValue<double>(-0.0);

        expect(setPosZero.resolve(9.0), 0.0);
        expect(setNegZero.resolve(9.0), -0.0);
      });

      test('positive and negative infinity resolve to the exact value', () {
        const FilterValue<double> setInf = FilterValue<double>(double.infinity);
        const FilterValue<double> setNegInf =
            FilterValue<double>(double.negativeInfinity);

        expect(setInf.resolve(0.0), double.infinity);
        expect(setNegInf.resolve(0.0), double.negativeInfinity);
      });

      test('NaN resolves to a NaN value (NaN != NaN, so assert with isNaN)', () {
        const FilterValue<double> setNan = FilterValue<double>(double.nan);

        // Equality cannot be used — NaN is never equal to itself; assert the
        // resolved value IS NaN and that the wrapper still reports isSet.
        expect(setNan.isSet, isTrue);
        expect((setNan.resolve(0.0))!.isNaN, isTrue);
      });

      test('num and Object top types resolve through generic erasure', () {
        const FilterValue<num> setNum = FilterValue<num>(3.5);
        const FilterValue<Object> setObj = FilterValue<Object>('x');

        expect(setNum.resolve(1), 3.5);
        expect(setObj.resolve(0), 'x');
      });

      test('int min and max boundaries are preserved exactly', () {
        // 64-bit signed min/max; confirms no truncation or overflow in transit.
        const FilterValue<int> setMax = FilterValue<int>(0x7FFFFFFFFFFFFFFF);
        const FilterValue<int> setMin = FilterValue<int>(-0x8000000000000000);

        expect(setMax.resolve(0), 0x7FFFFFFFFFFFFFFF);
        expect(setMin.resolve(0), -0x8000000000000000);
      });
    });

    group('collection / reference identity', () {
      // The wrapper must hold references, not copies — resolving returns the
      // exact instance supplied, so consumers can rely on identity.
      test('List value resolves to the identical instance (held by reference)',
          () {
        final List<int> supplied = <int>[1, 2, 3];
        final FilterValue<List<int>> setList =
            FilterValue<List<int>>(supplied);

        expect(identical(setList.resolve(<int>[9]), supplied), isTrue);
      });

      test('Map value resolves to the identical instance (held by reference)',
          () {
        final Map<String, int> supplied = <String, int>{'a': 1};
        final FilterValue<Map<String, int>> setMap =
            FilterValue<Map<String, int>>(supplied);

        expect(
          identical(setMap.resolve(<String, int>{'b': 2}), supplied),
          isTrue,
        );
      });

      test('empty list is set (not unset) and distinct from unset()', () {
        final FilterValue<List<int>> setEmpty =
            FilterValue<List<int>>(<int>[]);
        const FilterValue<List<int>> unset = FilterValue<List<int>>.unset();

        // An empty collection is a real override, not "no value given".
        expect(setEmpty.isSet, isTrue);
        expect(setEmpty.resolve(<int>[7]), isEmpty);
        expect(unset.resolve(<int>[7]), <int>[7]);
      });
    });

    group('string / Unicode robustness', () {
      test('empty string is set and resolves to it, distinct from unset()', () {
        const FilterValue<String> setEmpty = FilterValue<String>('');
        const FilterValue<String> unset = FilterValue<String>.unset();

        expect(setEmpty.isSet, isTrue);
        expect(setEmpty.resolve('current'), '');
        expect(unset.resolve('current'), 'current');
      });

      test('accented and smart-quote text is preserved unchanged', () {
        const FilterValue<String> accent = FilterValue<String>('café');
        // U+2018 / U+2019 curly single quotes around q.
        const FilterValue<String> curly = FilterValue<String>('‘q’');
        // U+2026 horizontal ellipsis between a and b.
        const FilterValue<String> ellipsis = FilterValue<String>('a…b');

        expect(accent.resolve('x'), 'café');
        expect(curly.resolve('x'), '‘q’');
        expect(ellipsis.resolve('x'), 'a…b');
      });

      test('ZWJ family emoji resolves byte-for-byte with unchanged length', () {
        // man + ZWJ + woman + ZWJ + girl — a multi-code-point ZWJ sequence.
        const String family = '\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}';
        const FilterValue<String> setFamily = FilterValue<String>(family);

        expect(setFamily.resolve('x'), family);
        expect(setFamily.resolve('x')!.length, family.length);
      });

      test('non-breaking-space-only string is set, not treated as empty/unset',
          () {
        // U+00A0 — must not be coerced to empty or unset by the wrapper.
        const FilterValue<String> setNbsp = FilterValue<String>(' ');

        expect(setNbsp.isSet, isTrue);
        expect(setNbsp.resolve(''), ' ');
      });
    });

    group('resolve semantics', () {
      test('unset round-trips the current value for null/value/wrapper', () {
        const FilterValue<Object> unset = FilterValue<Object>.unset();
        const FilterValue<int> other = FilterValue<int>(1);

        expect(unset.resolve(null), isNull);
        expect(unset.resolve(42), 42);
        // A FilterValue can itself be the current value being kept.
        expect(identical(unset.resolve(other), other), isTrue);
      });

      test('set-to-null and unset diverge at every current value', () {
        const FilterValue<bool> clear = FilterValue<bool>(null);
        const FilterValue<bool> keep = FilterValue<bool>.unset();

        for (final bool? current in <bool?>[true, false, null]) {
          // The load-bearing distinction: clear always nulls; keep echoes.
          expect(clear.resolve(current), isNull);
          expect(keep.resolve(current), current);
        }
      });

      test('resolve is pure — repeated calls return the same result', () {
        const FilterValue<int> setVal = FilterValue<int>(7);

        expect(setVal.resolve(1), 7);
        expect(setVal.resolve(1), 7);
      });
    });

    group('const / immutability', () {
      test('identical const FilterValue(true) instances are canonicalized', () {
        const FilterValue<bool> a = FilterValue<bool>(true);
        const FilterValue<bool> b = FilterValue<bool>(true);

        // Const-constructor correctness: equal const expressions collapse to a
        // single canonical instance.
        expect(identical(a, b), isTrue);
      });

      test('identical const unset() instances are canonicalized', () {
        const FilterValue<int> a = FilterValue<int>.unset();
        const FilterValue<int> b = FilterValue<int>.unset();

        expect(identical(a, b), isTrue);
      });

      test('FilterValue defines no value equality — distinct instances differ',
          () {
        // The class intentionally omits operator==/hashCode. Two non-const
        // wrappers with equal contents are NOT equal; this documents that and
        // pins the set-to-null vs unset distinction at the reference level.
        expect(FilterValue<int>(1) == FilterValue<int>(1), isFalse);
        expect(FilterValue<int>(null) == FilterValue<int>.unset(), isFalse);
      });

      test('wrapper does not deep-copy a held reference', () {
        final List<int> supplied = <int>[1];
        final FilterValue<List<int>> setList =
            FilterValue<List<int>>(supplied);

        // Mutating the original is visible through value — confirms no copy.
        supplied.add(2);
        expect(setList.value, <int>[1, 2]);
      });
    });

    group('nested generic composition', () {
      test('FilterValue<FilterValue<int>> composes and resolves inner wrapper',
          () {
        const FilterValue<int> inner = FilterValue<int>(5);
        const FilterValue<FilterValue<int>> outer =
            FilterValue<FilterValue<int>>(inner);
        const FilterValue<FilterValue<int>> outerUnset =
            FilterValue<FilterValue<int>>.unset();

        // Outer resolves to the inner wrapper, which itself resolves to 5.
        expect(identical(outer.resolve(null), inner), isTrue);
        expect(outer.resolve(null)!.resolve(0), 5);
        expect(identical(outerUnset.resolve(inner), inner), isTrue);
      });
    });
  });
}
