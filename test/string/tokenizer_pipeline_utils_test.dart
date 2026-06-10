import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/tokenizer_pipeline_utils.dart';

void main() {
  final List<TokenRule> rules = <TokenRule>[
    TokenRule('ws', RegExp(r'\s+'), shouldSkip: true),
    TokenRule('id', RegExp(r'[a-z]+')),
    TokenRule('op', RegExp(r'=')),
    TokenRule('num', RegExp(r'\d+')),
  ];

  group('tokenize', () {
    test('emits typed tokens with offsets and skips whitespace', () {
      expect(tokenize('ab = 12', rules), <Token>[
        const Token('id', 'ab', 0),
        const Token('op', '=', 3),
        const Token('num', '12', 5),
      ]);
    });

    test('first matching rule in order wins', () {
      // 'kw' precedes 'id', so a keyword is tagged kw, not id.
      final List<TokenRule> ordered = <TokenRule>[
        TokenRule('kw', RegExp(r'let')),
        TokenRule('id', RegExp(r'[a-z]+')),
      ];
      expect(tokenize('let', ordered), <Token>[const Token('kw', 'let', 0)]);
    });

    test('throws FormatException at an unmatched position', () {
      expect(
        () => tokenize('ab#', rules),
        throwsA(isA<FormatException>().having((FormatException e) => e.offset, 'offset', 2)),
      );
    });

    test('empty input yields no tokens', () {
      expect(tokenize('', rules), isEmpty);
    });

    test('a zero-width-capable rule does not spin the cursor', () {
      // \d* can match empty; it must be treated as a non-match so 'a' is reached
      // by the id rule rather than looping forever on an empty number.
      final List<TokenRule> withStar = <TokenRule>[
        TokenRule('num', RegExp(r'\d*')),
        TokenRule('id', RegExp(r'[a-z]+')),
      ];
      expect(tokenize('a', withStar), <Token>[const Token('id', 'a', 0)]);
    });

    test('all-skip input yields no tokens', () {
      expect(tokenize('   ', rules), isEmpty);
    });
  });
}
