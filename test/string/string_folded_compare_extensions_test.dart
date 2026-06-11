import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_folded_compare_extensions.dart';

void main() {
  group('compareStringFolded / foldedCompare', () {
    group('core folding', () {
      test('accented Latin interfiles with base letter (the headline fix)', () {
        final List<String> names = <String>['Zoe', 'Ángel', 'Andy', 'Bob'];
        // Without folding, raw sort would put 'Ángel' (U+00C1) AFTER 'Zoe'.
        expect(
          names.sortedFolded(),
          <String>['Andy', 'Ángel', 'Bob', 'Zoe'],
        );
      });

      test('ß folds to ss, so Straße and Strasse collate equal then tie-break', () {
        // Both fold to 'strasse'; primary is 0 → raw tie-break. Raw 'ß' (U+00DF,
        // 223) > 's' (115), so 'Straße' sorts AFTER 'Strasse'. The point is it
        // never returns 0 for these distinct strings.
        expect(foldedCompare('Straße', 'Strasse'), isPositive);
        expect(foldedCompare('Straße', 'Strasse'), isNot(0));
      });

      test('æ folds to ae, fold-equal pairs tie-break by raw case', () {
        // 'Æsir' folds to 'aesir' == 'aesir'; raw 'Æ' (198) > 'a' (97).
        expect(foldedCompare('Æsir', 'aesir'), isPositive);
      });

      test('all-caps sharp s ẞ folds to SS and collates with gross', () {
        // 'GROẞ' folds to 'gross'; raw tie-break 'G' (71) < 'g' (103).
        expect(foldedCompare('GROẞ', 'gross'), isNegative);
        expect(foldedCompare('GROẞ', 'gross'), isNot(0));
      });
    });

    group('case-insensitivity (default)', () {
      test('Bob sorts after alice case-insensitively (b > a)', () {
        expect(foldedCompare('Bob', 'alice'), isPositive);
      });

      test('caseSensitive: true uses raw code-unit order', () {
        // 'B' (66) < 'a' (97).
        expect(foldedCompare('Bob', 'alice', caseSensitive: true), isNegative);
      });

      test('caseSensitive: true still folds but preserves case', () {
        // 'É' folds to 'E' (69), 'e' stays 'e' (101); distinct, never 0.
        expect(foldedCompare('É', 'e', caseSensitive: true), isNegative);
        expect(foldedCompare('É', 'e', caseSensitive: true), isNot(0));
      });
    });

    group('deterministic tie-break (the lexical_sort guarantee)', () {
      test('distinct strings that fold equal never return 0', () {
        expect(foldedCompare('Foo', 'fóò'), isNot(0));
        expect(foldedCompare('fóò', 'Foo'), isNot(0));
      });

      test('antisymmetry on a fold-collision pair (a<b ⇒ b>a)', () {
        expect(
          foldedCompare('Foo', 'fóò').sign,
          -foldedCompare('fóò', 'Foo').sign,
        );
      });

      test('identical strings return exactly 0', () {
        expect(foldedCompare('Foo', 'Foo'), isZero);
      });

      test('antisymmetry sweep over a mixed sample set', () {
        final List<String?> sample = <String?>[
          null,
          '',
          'apple',
          'Apple',
          'Ángel',
          'andy',
          'Zoe',
          'img2',
          'img10',
          'Straße',
          'Strasse',
          '李',
          'Иван',
        ];
        // A comparator that violates antisymmetry corrupts List.sort.
        for (final String? a in sample) {
          for (final String? b in sample) {
            expect(
              foldedCompare(a, b).sign,
              -foldedCompare(b, a).sign,
              reason: 'antisymmetry failed for ($a, $b)',
            );
          }
        }
      });

      test('transitivity on a folded-collision triple', () {
        // All three fold to 'foo'; raw order is 'FOO' < 'Foo' < 'fÒo'.
        const String a = 'FOO';
        const String b = 'Foo';
        const String c = 'fÒo';
        expect(foldedCompare(a, b), isNegative);
        expect(foldedCompare(b, c), isNegative);
        expect(foldedCompare(a, c), isNegative); // a < b && b < c ⇒ a < c
      });
    });

    group('natural numeric ordering', () {
      test('natural: img2 before img10', () {
        expect(
          <String>['img10', 'img2', 'img1'].sortedFolded(natural: true),
          <String>['img1', 'img2', 'img10'],
        );
      });

      test('non-natural keeps lexicographic order', () {
        // '1' (49) < '2' (50) by char, so 'img10' sorts before 'img2'.
        expect(
          <String>['img10', 'img2'].sortedFolded(),
          <String>['img10', 'img2'],
        );
      });

      test('natural + ligature length change folds before tokenizing', () {
        // 'Straße2' → 'strasse2', 'Strasse10' → 'strasse10'; 2 < 10 by value.
        expect(foldedCompare('Straße2', 'Strasse10', natural: true), isNegative);
      });
    });

    group('nulls', () {
      test('both null → 0', () {
        expect(foldedCompare(null, null), isZero);
      });

      test('null sorts first by default', () {
        expect(foldedCompare(null, 'a'), -1);
        expect(foldedCompare('a', null), 1);
      });

      test('nullsLast pushes null to the end', () {
        expect(foldedCompare(null, 'a', nullsLast: true), 1);
        expect(foldedCompare('a', null, nullsLast: true), -1);
      });

      test('nulls ignore folding/case entirely', () {
        expect(foldedCompare(null, 'Ángel', nullsLast: true), 1);
      });
    });

    group('non-Latin pass-through (documented limitation)', () {
      test('Latin sorts before CJK and Cyrillic by code point', () {
        final List<String> mixed = <String>['李', 'Zoe', 'Иван', 'Andy'];
        final List<String> sorted = mixed.sortedFolded();
        expect(sorted.indexOf('Andy') < sorted.indexOf('Zoe'), isTrue);
        expect(sorted.indexOf('Zoe') < sorted.indexOf('李'), isTrue);
        expect(sorted.indexOf('Zoe') < sorted.indexOf('Иван'), isTrue);
      });

      test('a diacritic outside the fold map passes through unfolded', () {
        // 'ạ' (a with dot below, U+1EA1) is NOT in the library's accents map, so
        // it does not fold; it orders by code point and never throws.
        expect(() => foldedCompare('ạ', 'a'), returnsNormally);
        expect(foldedCompare('ạ', 'a'), isPositive); // U+1EA1 > 'a' (97)
      });
    });

    group('SplayTreeMap safety (the reason for the tie-break)', () {
      test('fold-equal distinct keys are not dropped', () {
        final SplayTreeMap<String, int> m = SplayTreeMap<String, int>(
          (String a, String b) => foldedCompare(a, b),
        );
        m['Foo'] = 1;
        m['fóò'] = 2; // folds to 'foo' too — must NOT overwrite 'Foo'
        expect(m, hasLength(2));
      });
    });

    group('edge cases', () {
      test('empty string sorts before non-empty', () {
        expect(foldedCompare('', 'a'), isNegative);
      });

      test('both empty → 0', () {
        expect(foldedCompare('', ''), isZero);
      });

      test('emoji input does not throw', () {
        expect(() => foldedCompare('\u{1F600}', 'a'), returnsNormally);
      });

      test('whitespace-only strings compare by raw length', () {
        // '  ' shares the ' ' prefix and is longer, so it sorts after ' '.
        expect(foldedCompare('  ', ' '), isPositive);
      });
    });

    group('sortedFolded does not mutate the original', () {
      test('original list order is preserved', () {
        final List<String> original = <String>['Zoe', 'Andy'];
        final List<String> sorted = original.sortedFolded();
        expect(original, <String>['Zoe', 'Andy']);
        expect(sorted, <String>['Andy', 'Zoe']);
      });
    });
  });
}
