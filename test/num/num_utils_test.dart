import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/num/num_utils.dart';

void main() {
  group('NumberUtils', () {
    group('maxOf', () {
      test('Both null returns null', () {
        expect(NumberUtils.maxOf(null, null), null);
      });

      test('First null, second not null returns second', () {
        expect(NumberUtils.maxOf(null, 5), 5);
      });

      test('First not null, second null returns first', () {
        expect(NumberUtils.maxOf(10, null), 10);
      });

      test('Both non-null, first greater returns first', () {
        expect(NumberUtils.maxOf(15, 5), 15);
      });

      test('Both non-null, second greater returns second', () {
        expect(NumberUtils.maxOf(5, 15), 15);
      });

      test('Both non-null, equal returns first', () {
        expect(NumberUtils.maxOf(10, 10), 10);
      });

      test('Negative and positive, positive max', () {
        expect(NumberUtils.maxOf(-5, 10), 10);
      });

      test('Negative and positive, zero max', () {
        expect(NumberUtils.maxOf(-5, 0), 0);
      });

      test('Both negative, larger negative max', () {
        expect(NumberUtils.maxOf(-1, -10), -1);
      });

      test('Zero and positive, positive max', () {
        expect(NumberUtils.maxOf(0, 5), 5);
      });
    });

    group('generateIntList', () {
      test('Valid range start < end', () {
        expect(NumberUtils.generateIntList(1, 5), <int>[1, 2, 3, 4, 5]);
      });

      test('Valid range start == end', () {
        expect(NumberUtils.generateIntList(3, 3), <int>[3]);
      });

      test('Invalid range start > end returns null', () {
        expect(NumberUtils.generateIntList(5, 1), null);
      });

      test('Zero start and positive end', () {
        expect(NumberUtils.generateIntList(0, 3), <int>[0, 1, 2, 3]);
      });

      test('Negative start and positive end', () {
        expect(NumberUtils.generateIntList(-2, 2), <int>[-2, -1, 0, 1, 2]);
      });

      test('Large range', () {
        expect(NumberUtils.generateIntList(100, 105), <int>[100, 101, 102, 103, 104, 105]);
      });

      test('Negative range', () {
        expect(NumberUtils.generateIntList(-5, -1), <int>[-5, -4, -3, -2, -1]);
      });

      test('Start and end are same negative', () {
        expect(NumberUtils.generateIntList(-3, -3), <int>[-3]);
      });

      test('Start negative, end zero', () {
        expect(NumberUtils.generateIntList(-2, 0), <int>[-2, -1, 0]);
      });
      test('Small positive range', () {
        expect(NumberUtils.generateIntList(2, 4), <int>[2, 3, 4]);
      });
    });
  });
}
