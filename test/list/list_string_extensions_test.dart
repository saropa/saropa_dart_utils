import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_string_extensions.dart';

void main() {
  group('commonPrefix', () {
    test('basic', () => expect(<String>['flower', 'flow', 'flight'].commonPrefix(), 'fl'));
    test('no common', () => expect(<String>['a', 'b'].commonPrefix(), ''));
    test('empty list', () => expect(<String>[].commonPrefix(), ''));
  });
  group('commonSuffix', () {
    test('basic', () => expect(<String>['ending', 'ding'].commonSuffix(), 'ding'));
    test('full suffix', () => expect(<String>['abc', 'bc'].commonSuffix(), 'bc'));
  });

  group('joinDisplayList', () {
    test('should return null for an empty list', () {
      expect(<String>[].joinDisplayList(), isNull);
    });

    test('should return the single item for a one-item list', () {
      expect(<String>['Alice'].joinDisplayList(), 'Alice');
    });

    test('should join two items with the double joiner', () {
      expect(<String>['Alice', 'Bob'].joinDisplayList(), 'Alice and Bob');
    });

    test('should Oxford-comma join three or more items', () {
      expect(
        <String>['Alice', 'Bob', 'Carol'].joinDisplayList(),
        'Alice, Bob, and Carol',
      );
    });

    test('should Oxford-comma join four items (multiple middle commas)', () {
      // Four items exercises more than one mid-list comma, which the 3-item
      // case cannot — the only place the "comma between every non-final pair"
      // path is verified beyond a single comma.
      expect(
        <String>['A', 'B', 'C', 'D'].joinDisplayList(),
        'A, B, C, and D',
      );
    });

    test('should Oxford-comma join five items', () {
      expect(
        <String>['A', 'B', 'C', 'D', 'E'].joinDisplayList(),
        'A, B, C, D, and E',
      );
    });

    test('should de-duplicate by default (isUnique true)', () {
      expect(
        <String>['Alice', 'Bob', 'Alice'].joinDisplayList(),
        'Alice and Bob',
      );
    });

    test('should keep duplicates when isUnique is false', () {
      expect(
        <String>['Alice', 'Bob', 'Alice'].joinDisplayList(isUnique: false),
        'Alice, Bob, and Alice',
      );
    });

    test('should trim entries and drop blank/whitespace-only entries', () {
      expect(
        <String>[' Alice ', '', '  ', 'Bob'].joinDisplayList(),
        'Alice and Bob',
      );
    });

    test('should collapse to a single item when only one entry survives trimming', () {
      expect(<String>['', '  ', ' Alice '].joinDisplayList(), 'Alice');
    });

    test('should return null when every entry is blank', () {
      expect(<String>['', '   ', '\t'].joinDisplayList(), isNull);
    });

    test('should honor custom joiners', () {
      expect(
        <String>['a', 'b', 'c'].joinDisplayList(
          joiner: '; ',
          lastJoiner: '; or ',
        ),
        'a; b; or c',
      );
    });

    test('should honor a custom double joiner', () {
      expect(
        <String>['a', 'b'].joinDisplayList(doubleJoiner: ' or '),
        'a or b',
      );
    });
  });

  group('joinWithFinal', () {
    test('empty list returns null', () {
      expect(<String>[].joinWithFinal(), isNull);
    });

    test('single item returns that item, no connector', () {
      expect(<String>['Alice'].joinWithFinal(), 'Alice');
    });

    test('two items use the final connector only', () {
      expect(<String>['Alice', 'Bob'].joinWithFinal(), 'Alice and Bob');
    });

    test('three items: no Oxford comma before "and"', () {
      expect(<String>['Alice', 'Bob', 'Carol'].joinWithFinal(), 'Alice, Bob and Carol');
    });

    test('custom separators', () {
      expect(
        <String>['a', 'b', 'c'].joinWithFinal(separator: '; ', finalSeparator: 'or'),
        'a; b or c',
      );
    });

    // No trimming/dedupe: a blank middle entry survives and prints, diverging
    // from joinDisplayList. This is the documented contract, so pin it.
    test('does not drop a blank middle entry (no trimming)', () {
      expect(<String>['a', '', 'c'].joinWithFinal(), 'a,  and c');
    });

    test('empty separator and finalSeparator', () {
      expect(<String>['a', 'b', 'c'].joinWithFinal(separator: '', finalSeparator: ''), 'ab  c');
    });

    test('multi-char separators', () {
      expect(
        <String>['a', 'b', 'c'].joinWithFinal(separator: ' -- ', finalSeparator: 'plus'),
        'a -- b plus c',
      );
    });

    // An element containing the separator substring must not be re-split: join
    // operates on whole elements, so the embedded ', ' stays intact.
    test('element containing the separator is not re-split', () {
      expect(<String>['a, x', 'b', 'c'].joinWithFinal(), 'a, x, b and c');
    });

    test('large list joins without stack issues', () {
      final List<String> big = List<String>.generate(10000, (int i) => 'i$i');
      final String? result = big.joinWithFinal();
      expect(result, isNotNull);
      // The last two items are bridged by ' and ', not the comma separator.
      expect(result!.endsWith('i9998 and i9999'), isTrue);
    });

    test('does not mutate the receiver', () {
      final List<String> input = <String>['a', 'b', 'c'];
      // Assign the @useResult return to a discarded local so the analyzer is
      // satisfied while the assertion still proves the receiver is untouched.
      final String? _ = input.joinWithFinal();
      expect(input, <String>['a', 'b', 'c']);
    });
  });

  group('anyContains', () {
    test('case sensitive finds exact match', () {
      expect(<String>['Hello', 'World'].anyContains('Hello', caseSensitive: true), isTrue);
    });

    test('case sensitive does not find different case', () {
      expect(<String>['Hello', 'World'].anyContains('hello', caseSensitive: true), isFalse);
    });

    test('case insensitive finds different case', () {
      expect(<String>['Hello', 'World'].anyContains('hello', caseSensitive: false), isTrue);
    });

    test('case insensitive finds substring', () {
      expect(<String>['HelloWorld', 'Test'].anyContains('world', caseSensitive: false), isTrue);
    });

    test('case sensitive finds substring with exact case', () {
      expect(<String>['HelloWorld', 'Test'].anyContains('World', caseSensitive: true), isTrue);
    });

    test('case sensitive does not find substring with different case', () {
      expect(<String>['HelloWorld', 'Test'].anyContains('world', caseSensitive: true), isFalse);
    });

    test('empty list returns false', () {
      expect(<String>[].anyContains('test'), isFalse);
    });

    test('null check returns false', () {
      expect(<String>['Hello'].anyContains(null), isFalse);
    });

    test('empty check returns false', () {
      expect(<String>['Hello'].anyContains(''), isFalse);
    });

    test('check equal to the whole element matches', () {
      expect(<String>['Hello'].anyContains('Hello'), isTrue);
    });

    test('check longer than every element does not match', () {
      expect(<String>['ab', 'cd'].anyContains('abcd'), isFalse);
    });

    // 'É'.toLowerCase() is 'é', so case-insensitive search finds it in 'café'.
    test('case insensitive matches accented Unicode', () {
      expect(<String>['café'].anyContains('É', caseSensitive: false), isTrue);
    });

    test('empty-string element with non-empty check does not match', () {
      expect(<String>[''].anyContains('x'), isFalse);
    });

    // Zero-width space (U+200B) is a real character: a needle containing it only
    // matches an element that also contains it.
    test('check containing zero-width space matches only when present', () {
      expect(<String>['a​b'].anyContains('a​b'), isTrue);
      expect(<String>['ab'].anyContains('a​b'), isFalse);
    });

    test('large list short-circuits and still finds a match', () {
      final List<String> big = List<String>.generate(10000, (int i) => 'x$i');
      expect(big.anyContains('x9999'), isTrue);
      expect(big.anyContains('zzz'), isFalse);
    });
  });

  group('removeTrimmedEmpty (List<String>)', () {
    test('all-blank returns null', () {
      expect(<String>['', '  ', '\t'].removeTrimmedEmpty(), isNull);
    });

    test('trims survivors when trim true', () {
      expect(<String>[' a ', 'b'].removeTrimmedEmpty(), <String>['a', 'b']);
    });

    // With trim:false the survivor keeps its surrounding spaces, and a
    // whitespace-only entry is NOT dropped (only a literal '' is) — same
    // nullIfEmpty(trimFirst:false) contract pinned by the test below.
    test('preserves surrounding space when trim false, keeps whitespace-only', () {
      expect(
        <String>[' a ', '   '].removeTrimmedEmpty(trim: false),
        <String>[' a ', '   '],
      );
    });

    // With trim:false only a literally empty string is dropped; a whitespace-only
    // entry is kept untouched. This pins the nullIfEmpty(trimFirst:false) contract.
    test('trim false keeps whitespace-only, drops only literal empty', () {
      expect(<String>[' a ', ''].removeTrimmedEmpty(trim: false), <String>[' a ']);
      expect(<String>['   '].removeTrimmedEmpty(trim: false), <String>['   ']);
    });

    test('single empty element returns null', () {
      expect(<String>[''].removeTrimmedEmpty(), isNull);
    });

    test('single space element returns null when trimming', () {
      expect(<String>[' '].removeTrimmedEmpty(), isNull);
    });

    // Dart's trim() strips a non-breaking space (U+00A0) but NOT a zero-width
    // space (U+200B): the former is dropped, the latter survives as non-empty.
    test('non-breaking space dropped, zero-width space survives', () {
      expect(<String>[' ', '​'].removeTrimmedEmpty(), <String>['​']);
    });

    test('does not mutate the receiver', () {
      final List<String> input = <String>[' a ', '', 'b'];
      final List<String>? _ = input.removeTrimmedEmpty();
      expect(input, <String>[' a ', '', 'b']);
    });
  });

  group('removeNullsAndTrimmedEmpty (List<String?>)', () {
    test('List should be empty', () {
      expect(<String?>[null, null, null].removeNullsAndTrimmedEmpty(), isNull);
      expect(<String?>['', null, ''].removeNullsAndTrimmedEmpty(), isNull);
      expect(<String?>[' ', null, ' '].removeNullsAndTrimmedEmpty(), isNull);
      expect(<String?>[' ', '     ', ' '].removeNullsAndTrimmedEmpty(), isNull);
    });

    test('List nulls should be removed', () {
      expect(<String?>[null, '', 'abc'].removeNullsAndTrimmedEmpty(), <String>['abc']);
      // space is OK
      expect(<String?>[null, ' ', 'abc'].removeNullsAndTrimmedEmpty(), <String>['abc']);
    });

    test('List nulls should be unchanged', () {
      expect(<String?>['123', 'test word', 'abc'].removeNullsAndTrimmedEmpty(), <String>[
        '123',
        'test word',
        'abc',
      ]);
    });

    test('List nulls should be trimmed', () {
      expect(
        <String?>['123 ', 'test word', 'abc'].removeNullsAndTrimmedEmpty()?.toList(),
        <String>['123', 'test word', 'abc'],
      );
      expect(
        <String?>['123', 'test word ', 'abc'].removeNullsAndTrimmedEmpty()?.toList(),
        <String>['123', 'test word', 'abc'],
      );
      expect(
        <String?>['123', 'test word', ' abc '].removeNullsAndTrimmedEmpty()?.toList(),
        <String>['123', 'test word', 'abc'],
      );
      expect(
        <String?>[
          '   123   ',
          '   test    word',
          '   abc   ',
        ].removeNullsAndTrimmedEmpty()?.toList(),
        <String>['123', 'test    word', 'abc'],
      );
      expect(
        <String?>['      ', '       ', '      '].removeNullsAndTrimmedEmpty()?.toList(),
        isNull,
      );
    });

    test('single null returns null', () {
      expect(<String?>[null].removeNullsAndTrimmedEmpty(), isNull);
    });

    test('mixed-null with one real value keeps the value', () {
      expect(<String?>[null, 'x', null].removeNullsAndTrimmedEmpty(), <String>['x']);
    });

    test('trim false keeps whitespace-only survivors after null removal', () {
      expect(<String?>[null, '   ', ''].removeNullsAndTrimmedEmpty(trim: false), <String>['   ']);
    });

    test('does not mutate the receiver', () {
      final List<String?> input = <String?>[null, ' a ', ''];
      final List<String>? _ = input.removeNullsAndTrimmedEmpty();
      expect(input, <String?>[null, ' a ', '']);
    });
  });

  group('firstNotEqualTo', () {
    test('null value returns first element', () {
      expect(<String>['a', 'b'].firstNotEqualTo(null), 'a');
    });

    test('null value on empty list returns null', () {
      expect(<String>[].firstNotEqualTo(null), isNull);
    });

    test('returns first element differing from value', () {
      expect(<String>['a', 'a', 'b'].firstNotEqualTo('a'), 'b');
    });

    test('all-equal returns null', () {
      expect(<String>['a', 'a'].firstNotEqualTo('a'), isNull);
    });

    // Comparison is case-sensitive: 'A' differs from 'a' and so is returned.
    test('comparison is case-sensitive', () {
      expect(<String>['a', 'A', 'b'].firstNotEqualTo('a'), 'A');
    });

    test('empty-string value with empty-string element returns differing element', () {
      expect(<String>['', 'x'].firstNotEqualTo(''), 'x');
    });

    test('single element equal to value returns null', () {
      expect(<String>['a'].firstNotEqualTo('a'), isNull);
    });
  });

  group('toLowerCase / toUpperCase', () {
    test('lowercases each element', () {
      expect(<String>['Ab', 'CD'].toLowerCase(), <String>['ab', 'cd']);
    });

    test('uppercases each element', () {
      expect(<String>['Ab', 'cd'].toUpperCase(), <String>['AB', 'CD']);
    });

    test('nullable variant drops nulls first (lower)', () {
      expect(<String?>['Ab', null, 'CD'].toLowerCase(), <String>['ab', 'cd']);
    });

    test('nullable variant drops nulls first (upper)', () {
      expect(<String?>['Ab', null, 'cd'].toUpperCase(), <String>['AB', 'CD']);
    });

    test('empty list yields empty list', () {
      expect(<String>[].toLowerCase(), <String>[]);
      expect(<String>[].toUpperCase(), <String>[]);
    });

    test('all-null nullable list yields empty list', () {
      expect(<String?>[null, null].toLowerCase(), <String>[]);
      expect(<String?>[null, null].toUpperCase(), <String>[]);
    });

    // Dart's String.toUpperCase() is a 1:1 code-point mapping and does NOT
    // special-case the German eszett, so 'ß' stays 'ß' (no expansion to 'SS').
    test('German eszett is left unchanged (no SS expansion)', () {
      expect(<String>['straße'].toUpperCase(), <String>['STRAßE']);
    });

    // Invariant culture, NOT Turkish: 'i' uppercases to 'I' (not dotted 'İ') and
    // 'I' lowercases to 'i' (not dotless 'ı'), so behavior is locale-independent.
    test('casing is invariant culture, not Turkish', () {
      expect(<String>['i'].toUpperCase(), <String>['I']);
      expect(<String>['I'].toLowerCase(), <String>['i']);
    });

    test('accented characters map case correctly', () {
      expect(<String>['é'].toUpperCase(), <String>['É']);
      expect(<String>['É'].toLowerCase(), <String>['é']);
    });

    // Emoji and surrogate pairs are case-invariant and must round-trip unchanged.
    test('emoji round-trips unchanged through both casings', () {
      expect(<String>['😀'].toUpperCase(), <String>['😀']);
      expect(<String>['😀'].toLowerCase(), <String>['😀']);
    });

    test('does not mutate the receiver', () {
      final List<String> input = <String>['Ab', 'CD'];
      // Both mapped results are asserted so the @useResult returns are consumed
      // and the receiver is shown to be untouched by either call.
      expect(input.toLowerCase(), <String>['ab', 'cd']);
      expect(input.toUpperCase(), <String>['AB', 'CD']);
      expect(input, <String>['Ab', 'CD']);
    });
  });
}
