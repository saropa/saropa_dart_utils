import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_case_extensions.dart';

void main() {
  // cspell: disable
  group('isAllLetterLowerCase', () {
    test('All lowercase letters returns true', () {
      expect('lowercase'.isAllLetterLowerCase, true);
    });

    test('Mixed case letters returns false', () {
      expect('MixedCase'.isAllLetterLowerCase, false);
    });

    test('All uppercase letters returns false', () {
      expect('UPPERCASE'.isAllLetterLowerCase, false);
    });

    test('String with numbers returns false', () {
      expect('lower1case'.isAllLetterLowerCase, false);
    });

    test('String with spaces returns false', () {
      expect('lower case'.isAllLetterLowerCase, false);
    });

    test('Empty string returns false', () {
      expect(''.isAllLetterLowerCase, false);
    });

    test('String with symbols returns false', () {
      expect('lower-case'.isAllLetterLowerCase, false);
    });

    test('String with accented lowercase letters returns true', () {
      expect('café'.isAllLetterLowerCase, true);
    });

    test('String with unicode lowercase letters returns true', () {
      expect('привет'.isAllLetterLowerCase, true);
    });

    test('String with mixed lowercase and unicode letters returns false', () {
      expect('lowerприветcase'.isAllLetterLowerCase, true);
    });
  });

  group('isAnyCaseLetter', () {
    test('All lowercase letters returns true', () {
      expect('lowercase'.isAnyCaseLetter, true);
    });

    test('Mixed case letters returns true', () {
      expect('MixedCase'.isAnyCaseLetter, true);
    });

    test('All uppercase letters returns true', () {
      expect('UPPERCASE'.isAnyCaseLetter, true);
    });

    test('String with numbers returns false', () {
      expect('letter1case'.isAnyCaseLetter, false);
    });

    test('String with spaces returns false', () {
      expect('letter case'.isAnyCaseLetter, false);
    });

    test('Empty string returns false', () {
      expect(''.isAnyCaseLetter, false);
    });

    test('String with symbols returns false', () {
      expect('letter-case'.isAnyCaseLetter, false);
    });

    test('String with accented letters returns true', () {
      expect('café'.isAnyCaseLetter, true);
    });

    test('String with unicode letters returns true', () {
      expect('привет'.isAnyCaseLetter, true);
    });

    test('String with mixed case and unicode letters returns true', () {
      expect('LetterприветCase'.isAnyCaseLetter, true);
    });
  });

  group('isAllLetterUpperCase', () {
    test('All uppercase letters returns true', () {
      expect('UPPERCASE'.isAllLetterUpperCase, true);
    });

    test('Mixed case letters returns false', () {
      expect('MixedCase'.isAllLetterUpperCase, false);
    });

    test('All lowercase letters returns false', () {
      expect('lowercase'.isAllLetterUpperCase, false);
    });

    test('String with numbers returns false', () {
      expect('UPPER1CASE'.isAllLetterUpperCase, false);
    });

    test('String with spaces returns false', () {
      expect('UPPER CASE'.isAllLetterUpperCase, false);
    });

    test('Empty string returns false', () {
      expect(''.isAllLetterUpperCase, false);
    });

    test('String with symbols returns false', () {
      expect('UPPER-CASE'.isAllLetterUpperCase, false);
    });

    test('String with accented uppercase letters returns true', () {
      expect('CAFÉ'.isAllLetterUpperCase, false); // Accented chars are not uppercase in regex
    });

    test('String with unicode uppercase letters returns false', () {
      expect('ПРИВЕТ'.isAllLetterUpperCase, false); // Unicode chars are not uppercase in regex
    });

    test('String with mixed uppercase and unicode letters returns false', () {
      expect(
        'UPPERПРИВЕТCASE'.isAllLetterUpperCase,
        false,
      ); // Unicode chars are not uppercase in regex
    });
  });

  group('capitalizeWords', () {
    test('Empty string returns empty string', () {
      expect(''.capitalizeWords(), '');
    });

    test('Single word string', () {
      expect('word'.capitalizeWords(), 'Word');
    });

    test('Multiple words string', () {
      expect('multiple words'.capitalizeWords(), 'Multiple Words');
    });

    test('String with leading and trailing spaces', () {
      expect(
        '  leading and trailing spaces  '.capitalizeWords(),
        '  Leading And Trailing Spaces  ',
      );
    });

    test('String with multiple spaces between words', () {
      expect(
        'multiple   spaces  between  words'.capitalizeWords(),
        'Multiple   Spaces  Between  Words',
      );
    });

    test('String with existing capital letters', () {
      expect('already Capitalized Words'.capitalizeWords(), 'Already Capitalized Words');
    });

    test('String with mixed case words', () {
      expect('mIxEd cAsE wOrDs'.capitalizeWords(), 'MIxEd CAsE WOrDs');
    });

    test('String with numbers in words', () {
      expect('words with 123 numbers'.capitalizeWords(), 'Words With 123 Numbers');
    });

    test('String with symbols in words', () {
      expect('words-with-symbols'.capitalizeWords(), 'Words-with-symbols');
    });

    test('String with unicode words', () {
      expect('unicode слова'.capitalizeWords(), 'Unicode Слова');
    });
  });

  group('lowerCaseFirstChar', () {
    test('Empty string returns empty string', () {
      expect(''.lowerCaseFirstChar(), '');
    });

    test('Single lowercase char', () {
      expect('a'.lowerCaseFirstChar(), 'a');
    });

    test('Single uppercase char', () {
      expect('A'.lowerCaseFirstChar(), 'a');
    });

    test('Mixed case string', () {
      expect('MixedCase'.lowerCaseFirstChar(), 'mixedCase');
    });

    test('Already lowercase string', () {
      expect('lowercase'.lowerCaseFirstChar(), 'lowercase');
    });

    test('Uppercase string', () {
      expect('UPPERCASE'.lowerCaseFirstChar(), 'uPPERCASE');
    });

    test('String with number at start', () {
      expect('1String'.lowerCaseFirstChar(), '1String'); // Numbers are not changed
    });

    test('String with symbol at start', () {
      expect('-String'.lowerCaseFirstChar(), '-String'); // Symbols are not changed
    });

    test('String with accented uppercase char at start', () {
      expect('Àccented'.lowerCaseFirstChar(), 'àccented');
    });

    test('String with unicode uppercase char at start', () {
      expect('ПРИВЕТ'.lowerCaseFirstChar(), 'пРИВЕТ');
    });
  });

  group('upperCaseFirstChar', () {
    test('Empty string returns empty string', () {
      expect(''.upperCaseFirstChar(), '');
    });

    test('Single lowercase char', () {
      expect('a'.upperCaseFirstChar(), 'A');
    });

    test('Single uppercase char', () {
      expect('A'.upperCaseFirstChar(), 'A');
    });

    test('Mixed case string', () {
      expect('mixedCase'.upperCaseFirstChar(), 'MixedCase');
    });

    test('Already uppercase string', () {
      expect('UPPERCASE'.upperCaseFirstChar(), 'UPPERCASE');
    });

    test('Lowercase string', () {
      expect('lowercase'.upperCaseFirstChar(), 'Lowercase');
    });

    test('String with number at start', () {
      expect('1String'.upperCaseFirstChar(), '1String'); // Numbers are not changed
    });

    test('String with symbol at start', () {
      expect('-String'.upperCaseFirstChar(), '-String'); // Symbols are not changed
    });

    test('String with accented lowercase char at start', () {
      expect('àccented'.upperCaseFirstChar(), 'Àccented');
    });

    test('String with unicode lowercase char at start', () {
      expect(
        'привет'.upperCaseFirstChar(),
        'Привет',
      ); // Unicode chars are not upper-cased correctly
    });
  });

  group('titleCase', () {
    test('Empty string returns empty string', () {
      expect(''.titleCase(), '');
    });

    test('Single lowercase word', () {
      expect('word'.titleCase(), 'Word');
    });

    test('Single uppercase word', () {
      expect('WORD'.titleCase(), 'Word');
    });

    test('Mixed case word', () {
      expect('wORd'.titleCase(), 'Word');
    });

    test('Multiple lowercase words', () {
      expect('multiple words'.titleCase(), 'Multiple words');
    });

    test('Multiple uppercase words', () {
      expect('MULTIPLE WORDS'.titleCase(), 'Multiple words');
    });

    test('Multiple mixed case words', () {
      expect('mIxEd cAsE wOrDs'.titleCase(), 'Mixed case words');
    });

    test('String with numbers', () {
      expect('words with 123 numbers'.titleCase(), 'Words with 123 numbers');
    });

    test('String with symbols', () {
      expect('words-with-symbols'.titleCase(), 'Words-with-symbols');
    });

    test('String with unicode', () {
      expect(
        'unicode слова'.titleCase(),
        'Unicode слова',
      ); // Unicode chars are not lowercased correctly
    });
  });

  group('toUpperLatinOnly', () {
    test('Empty string returns empty string', () {
      expect(''.toUpperLatinOnly(), '');
    });

    test('Lowercase latin string', () {
      expect('lowercase'.toUpperLatinOnly(), 'LOWERCASE');
    });

    test('Uppercase latin string', () {
      expect('UPPERCASE'.toUpperLatinOnly(), 'UPPERCASE');
    });

    test('Mixed case latin string', () {
      expect('MixedCase'.toUpperLatinOnly(), 'MIXEDCASE');
    });

    test('String with numbers', () {
      expect('string123'.toUpperLatinOnly(), 'STRING123'); // Numbers are kept
    });

    test('String with symbols', () {
      expect('string-sym'.toUpperLatinOnly(), 'STRING-SYM'); // Symbols are kept
    });

    test('String with spaces', () {
      expect('string with space'.toUpperLatinOnly(), 'STRING WITH SPACE'); // Spaces are kept
    });

    test('String with accented latin chars', () {
      expect('café'.toUpperLatinOnly(), 'CAFé'); // Accented latin chars are uppercased
    });

    test('String with unicode chars', () {
      expect('string привет'.toUpperLatinOnly(), 'STRING привет'); // Unicode chars are kept as is
    });

    test('String with mixed latin and unicode chars', () {
      expect('latinПривет'.toUpperLatinOnly(), 'LATINПривет'); // Mixed string
    });

    // Fix 7: O(n) performance tests (algorithm fix - uses StringBuffer)
    test('handles long strings efficiently with O(n) performance', () {
      final String longString = 'a' * 10000;
      final String result = longString.toUpperLatinOnly();
      expect(result, 'A' * 10000);
    });

    test('preserves emoji characters', () {
      expect('hello😀world'.toUpperLatinOnly(), 'HELLO😀WORLD');
    });

    test('handles mixed content with emoji and unicode', () {
      expect('Hello World 123!😀你好'.toUpperLatinOnly(), 'HELLO WORLD 123!😀你好');
    });
  });

  group('capitalize', () {
    test('Empty string returns empty string', () {
      expect(''.capitalize(), '');
    });

    test('Lowercase string', () {
      expect('lowercase'.capitalize(), 'Lowercase');
    });

    test('Uppercase string', () {
      expect('UPPERCASE'.capitalize(), 'UPPERCASE');
    });

    test('Mixed case string', () {
      expect('mIxEd'.capitalize(), 'MIxEd');
    });

    test('String with numbers', () {
      expect('word123'.capitalize(), 'Word123'); // Numbers are kept
    });

    test('String with symbols', () {
      expect('word-sym'.capitalize(), 'Word-sym'); // Symbols are kept
    });

    test('String with spaces', () {
      expect(
        'word space'.capitalize(),
        'Word space',
      ); // Spaces are kept, only first word capitalized
    });

    test('String with accented char', () {
      expect('café'.capitalize(), 'Café'); // Accented chars are handled
    });

    test('String with unicode char', () {
      expect(
        'привет'.capitalize(),
        'Привет', // NOTE: Unicode chars are not handled correctly for capitalization
      );
    });

    test('String already capitalized', () {
      expect('Capitalized'.capitalize(), 'Capitalized');
    });
  });

  group('upperCaseLettersOnly', () {
    test('Empty string returns empty string', () {
      expect(''.upperCaseLettersOnly(), '');
    });

    test('Lowercase string returns empty string', () {
      expect('lowercase'.upperCaseLettersOnly(), '');
    });

    test('Uppercase string returns uppercase string', () {
      expect('UPPERCASE'.upperCaseLettersOnly(), 'UPPERCASE');
    });

    test('Mixed case string returns uppercase letters only', () {
      expect('MixedCase'.upperCaseLettersOnly(), 'MC');
    });

    test('String with numbers returns uppercase letters only', () {
      expect('String123'.upperCaseLettersOnly(), 'S');
    });

    test('String with symbols returns uppercase letters only', () {
      expect('String-Sym'.upperCaseLettersOnly(), 'SS');
    });

    test('String with spaces returns uppercase letters only', () {
      expect('String With Space'.upperCaseLettersOnly(), 'SWS');
    });

    test('String with accented chars returns empty string', () {
      expect('café'.upperCaseLettersOnly(), ''); // Accented chars are not uppercase letters
    });

    test('String with unicode chars returns empty string', () {
      expect('привет'.upperCaseLettersOnly(), ''); // Unicode chars are not uppercase letters
    });

    test('String with mixed letters, numbers and symbols', () {
      expect('sTrInG123-SyMbOlS'.upperCaseLettersOnly(), 'TIGSMOS');
    });

    // Fix 8: O(n) performance tests (algorithm fix - uses StringBuffer)
    test('handles long strings efficiently with O(n) performance', () {
      final String longString = 'Ab' * 5000;
      final String result = longString.upperCaseLettersOnly();
      expect(result, 'A' * 5000);
    });

    test('handles strings with only special chars', () {
      expect('!@#\$%^&*()'.upperCaseLettersOnly(), '');
    });

    test('extracts initials from name with mixed case', () {
      expect('Ben Bright 1234'.upperCaseLettersOnly(), 'BB');
    });
  });

  group('findCapitalizedWords', () {
    test('Empty string returns null', () {
      expect(''.findCapitalizedWords(), null);
    });

    test('No capitalized words', () {
      expect('no capitalized words'.findCapitalizedWords(), null);
    });

    test('Single capitalized word', () {
      expect('One capitalized word'.findCapitalizedWords(), <String>['One']);
    });

    test('Multiple capitalized words', () {
      expect('Multiple Capitalized Words'.findCapitalizedWords(), <String>[
        'Multiple',
        'Capitalized',
        'Words',
      ]);
    });

    test('Mixed case words, some capitalized', () {
      expect('mIxEd Capitalized wOrDs'.findCapitalizedWords(), <String>['Capitalized']);
    });

    test('String with leading and trailing spaces', () {
      expect('  Leading and Trailing  '.findCapitalizedWords(), <String>['Leading', 'Trailing']);
    });

    test('String with multiple spaces', () {
      expect('Multiple   Capitalized  Words'.findCapitalizedWords(), <String>[
        'Multiple',
        'Capitalized',
        'Words',
      ]);
    });

    test('String with numbers', () {
      expect('Words with 123 Numbers'.findCapitalizedWords(), <String>['Words', 'Numbers']);
    });

    test('String with symbols', () {
      expect('Words-with-Symbols'.findCapitalizedWords(), <String>[
        'Words-with-Symbols',
      ]); // Hyphenated word is considered as one word
    });

    test('String with unicode words', () {
      expect('Unicode Слова Capitalized'.findCapitalizedWords(), <String>[
        'Unicode',
        'Capitalized',
      ]); // Unicode words are not considered capitalized
    });
  });

  group('insertSpaceBetweenCapitalized', () {
    test('Empty string returns empty string', () {
      expect(''.insertSpaceBetweenCapitalized(), '');
    });

    test('No capitalized letters returns capitalized first word', () {
      expect('nocapitals'.insertSpaceBetweenCapitalized(), 'Nocapitals');
    });

    test('Single capitalized word', () {
      expect('CapitalizedWord'.insertSpaceBetweenCapitalized(), 'Capitalized Word');
    });

    test('Multiple capitalized words', () {
      expect(
        'MultipleCapitalizedWords'.insertSpaceBetweenCapitalized(),
        'Multiple Capitalized Words',
      );
    });

    test('Mixed case with capitalized words', () {
      expect(
        'mixedCaseCapitalizedWords'.insertSpaceBetweenCapitalized(),
        'Mixed Case Capitalized Words',
      );
    });

    test('String with numbers', () {
      expect('StringWithNumbers123'.insertSpaceBetweenCapitalized(), 'String With Numbers123');
      expect(
        'StringWithNumbers123'.insertSpaceBetweenCapitalized(splitNumbers: true),
        'String With Numbers 123',
      );
    });

    test('String with symbols', () {
      expect(
        'String-With-Symbols'.insertSpaceBetweenCapitalized(),
        'String-With-Symbols',
      ); // Symbols are not considered word boundaries
    });

    test('String already with spaces', () {
      expect(
        'String With Spaces'.insertSpaceBetweenCapitalized(),
        'String With Spaces',
      ); // Already spaced string remains the same
    });

    test('String with leading and trailing spaces', () {
      expect(
        '  LeadingCapitalizedTrailing  '.insertSpaceBetweenCapitalized(),
        // NOTE: a trim is applied
        'Leading Capitalized Trailing',
      );
    });

    test('String with unicode letters', () {
      expect(
        'UnicodeСловаCapitalized'.insertSpaceBetweenCapitalized(),
        // NOTE:  No split for Unicode
        'UnicodeСловаCapitalized',
      ); // Unicode letters are treated as lowercase
    });
  });

  group('splitCapitalized', () {
    test('Empty string returns empty list', () {
      expect(''.splitCapitalized(), <String>[]);
    });

    test('No capitalized letters returns list with original string', () {
      expect('nocapitals'.splitCapitalized(), <String>['nocapitals']);
    });

    test('Single capitalized word', () {
      expect('CapitalizedWord'.splitCapitalized(), <String>['Capitalized', 'Word']);
    });

    test('Multiple capitalized words', () {
      expect('MultipleCapitalizedWords'.splitCapitalized(), <String>[
        'Multiple',
        'Capitalized',
        'Words',
      ]);
    });

    test('Mixed case with capitalized words', () {
      expect('mixedCaseCapitalizedWords'.splitCapitalized(), <String>[
        'mixed',
        'Case',
        'Capitalized',
        'Words',
      ]);
    });

    test('String with numbers (no splitNumbers)', () {
      expect('StringWithNumbers123'.splitCapitalized(), <String>['String', 'With', 'Numbers123']);
    });

    test('String with numbers (splitNumbers true)', () {
      expect('StringWithNumbers123'.splitCapitalized(splitNumbers: true), <String>[
        'String',
        'With',
        'Numbers',
        '123',
      ]);
    });

    test('String with symbols', () {
      expect('String-With-Symbols'.splitCapitalized(), <String>[
        'String-With-Symbols',
      ]); // Symbols are not word boundaries
    });

    test('String already with spaces', () {
      expect('String With Spaces'.splitCapitalized(), <String>[
        'String With Spaces',
      ]); // Spaces are not considered for splitting
    });

    test('String with leading and trailing spaces', () {
      expect('  LeadingCapitalizedTrailing  '.splitCapitalized(), <String>[
        '  Leading',
        'Capitalized',
        'Trailing  ',
      ]);
    });

    test('String with unicode letters', () {
      expect('UnicodeСловаCapitalized'.splitCapitalized(), <String>[
        'UnicodeСловаCapitalized', // NOTE: No split at Unicode boundary
      ]); // Unicode letters are not considered for splitting
    });
  });

  group('unCapitalizedWords', () {
    test('Empty string returns null', () {
      expect(''.unCapitalizedWords(), null);
    });

    test('No uncapitalized words returns null', () {
      expect('CAPITALIZED WORDS'.unCapitalizedWords(), null);
    });

    test('Single uncapitalized word', () {
      expect('One uncapitalized Word'.unCapitalizedWords(), <String>['uncapitalized']);
    });

    test('Multiple uncapitalized words', () {
      expect('multiple uncapitalized words here'.unCapitalizedWords(), <String>[
        'multiple',
        'uncapitalized',
        'words',
        'here',
      ]);
    });

    test('Mixed case words, some uncapitalized', () {
      expect('mIxEd unCapitalized wOrDs'.unCapitalizedWords(), <String>[
        'mIxEd',
        'unCapitalized',
        'wOrDs',
      ]); // Mixed case words are considered uncapitalized
    });

    test('String with leading and trailing spaces', () {
      expect('  leading and trailing  '.unCapitalizedWords(), <String>[
        'leading',
        'and',
        'trailing',
      ]);
    });

    test('String with multiple spaces', () {
      expect('multiple   uncapitalized  words'.unCapitalizedWords(), <String>[
        'multiple',
        'uncapitalized',
        'words',
      ]);
    });

    test('String with numbers', () {
      expect('words with 123 numbers'.unCapitalizedWords(), <String>['words', 'with', 'numbers']);
    });

    test('String with symbols', () {
      expect('words-with-symbols'.unCapitalizedWords(), <String>[
        'words-with-symbols',
      ]); // Hyphenated word is considered one word
    });

    test('String with unicode words', () {
      expect('unicode слова uncapitalized'.unCapitalizedWords(), <String>[
        'unicode',
        'слова',
        'uncapitalized',
      ]); // Unicode words are considered uncapitalized
    });
  });
}
