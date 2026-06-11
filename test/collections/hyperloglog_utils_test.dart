import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/hyperloglog_utils.dart';

void main() {
  group('HyperLogLogUtils constructor', () {
    test('should default to precision 12 (4096 registers)', () {
      final hll = HyperLogLogUtils();
      expect(hll.precision, 12);
      expect(hll.registerCount, 4096);
    });

    test('should size register array as 2^precision', () {
      expect(HyperLogLogUtils(precision: 4).registerCount, 16);
      expect(HyperLogLogUtils(precision: 16).registerCount, 65536);
    });

    test('should throw for precision below the minimum', () {
      expect(() => HyperLogLogUtils(precision: 3), throwsArgumentError);
    });

    test('should throw for precision above the maximum', () {
      expect(() => HyperLogLogUtils(precision: 17), throwsArgumentError);
    });

    test('should throw for negative precision', () {
      expect(() => HyperLogLogUtils(precision: -1), throwsArgumentError);
    });
  });

  group('cardinality', () {
    test('should be 0 for an empty sketch', () {
      expect(HyperLogLogUtils().cardinality(), 0);
    });

    test('should be ~1 after adding a single element', () {
      final hll = HyperLogLogUtils()..add('only');
      expect(hll.cardinality(), inInclusiveRange(1, 2));
    });

    test('should not grow when the same element is added repeatedly', () {
      // add is idempotent for equal elements: registers only ever take the max
      // rank, so re-adding cannot increase the estimate.
      final hll = HyperLogLogUtils();
      for (int i = 0; i < 1000; i++) {
        hll.add('same');
      }
      expect(hll.cardinality(), inInclusiveRange(1, 2));
    });

    test('should approximate a moderate distinct count within a few percent', () {
      final hll = HyperLogLogUtils();
      for (int i = 0; i < 1000; i++) {
        hll.add('user_$i');
      }
      // Standard error ~1.04/sqrt(4096) ≈ 1.6%; allow a generous 10% band so the
      // hashCode-derived estimate stays robust across runs/isolates.
      expect(hll.cardinality(), inInclusiveRange(900, 1100));
    });

    test('should handle a larger distinct count', () {
      final hll = HyperLogLogUtils();
      for (int i = 0; i < 10000; i++) {
        hll.add(i);
      }
      expect(hll.cardinality(), inInclusiveRange(9000, 11000));
    });

    test('should count distinct Unicode and emoji elements', () {
      final hll = HyperLogLogUtils();
      hll
        ..add('café')
        ..add('世界')
        ..add('👋')
        ..add('🚀');
      expect(hll.cardinality(), inInclusiveRange(3, 6));
    });

    test('should accept null as an element', () {
      final hll = HyperLogLogUtils()
        ..add(null)
        ..add('x');
      expect(hll.cardinality(), inInclusiveRange(1, 3));
    });

    test('should work at the minimum precision', () {
      final hll = HyperLogLogUtils(precision: 4);
      for (int i = 0; i < 50; i++) {
        hll.add('e_$i');
      }
      // Only 16 registers, so the error band is wide; just assert it is a
      // sensible positive estimate, not a degenerate value.
      expect(hll.cardinality(), inInclusiveRange(20, 120));
    });
  });

  group('merge', () {
    test('should equal the original when merging two empty sketches', () {
      final a = HyperLogLogUtils(precision: 10);
      final b = HyperLogLogUtils(precision: 10);
      expect(a.merge(b).cardinality(), 0);
    });

    test('should estimate the union of disjoint sketches', () {
      final a = HyperLogLogUtils();
      final b = HyperLogLogUtils();
      for (int i = 0; i < 500; i++) {
        a.add('a_$i');
      }
      for (int i = 0; i < 500; i++) {
        b.add('b_$i');
      }
      expect(a.merge(b).cardinality(), inInclusiveRange(900, 1100));
    });

    test('should not double-count overlapping elements', () {
      // Both sketches hold the same 500 keys; the union is still ~500, because
      // register-wise max collapses identical leading-zero runs.
      final a = HyperLogLogUtils();
      final b = HyperLogLogUtils();
      for (int i = 0; i < 500; i++) {
        a.add('shared_$i');
        b.add('shared_$i');
      }
      expect(a.merge(b).cardinality(), inInclusiveRange(450, 550));
    });

    test('should be a pure operation that leaves operands unchanged', () {
      final a = HyperLogLogUtils()..add('x');
      final b = HyperLogLogUtils()..add('y');
      final before = a.cardinality();
      a.merge(b);
      expect(a.cardinality(), before);
    });

    test('should throw when precisions differ', () {
      final a = HyperLogLogUtils(precision: 10);
      final b = HyperLogLogUtils(precision: 12);
      expect(() => a.merge(b), throwsArgumentError);
    });
  });

  group('toString', () {
    test('should report precision and register count', () {
      expect(
        HyperLogLogUtils(precision: 8).toString(),
        'HyperLogLogUtils(precision: 8, registers: 256)',
      );
    });
  });
}
