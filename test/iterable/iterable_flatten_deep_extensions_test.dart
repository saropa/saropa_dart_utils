import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_flatten_deep_extensions.dart';

void main() {
  group('flattenDeep', () {
    test('fully flattens deeply nested lists when depth is null', () {
      final List<dynamic> nested = <dynamic>[
        1,
        <dynamic>[
          2,
          <dynamic>[
            3,
            <dynamic>[4],
          ],
        ],
        5,
      ];
      expect(nested.flattenDeep().toList(), <dynamic>[1, 2, 3, 4, 5]);
    });

    test('depth 1 flattens only one level', () {
      final List<dynamic> nested = <dynamic>[
        1,
        <dynamic>[
          2,
          <dynamic>[3],
        ],
      ];
      // One level removed: inner [3] remains as a list.
      expect(nested.flattenDeep(1).toList(), <dynamic>[
        1,
        2,
        <dynamic>[3],
      ]);
    });

    test('depth 2 flattens two levels', () {
      final List<dynamic> nested = <dynamic>[
        <dynamic>[
          1,
          <dynamic>[
            2,
            <dynamic>[3],
          ],
        ],
      ];
      expect(nested.flattenDeep(2).toList(), <dynamic>[
        1,
        2,
        <dynamic>[3],
      ]);
    });

    test('already flat list is returned unchanged', () {
      expect(<dynamic>[1, 2, 3].flattenDeep().toList(), <dynamic>[1, 2, 3]);
    });

    test('empty list yields empty', () {
      expect(<dynamic>[].flattenDeep().toList(), <dynamic>[]);
    });

    test('depth 0 leaves nested lists intact', () {
      final List<dynamic> nested = <dynamic>[
        1,
        <dynamic>[2, 3],
      ];
      expect(nested.flattenDeep(0).toList(), <dynamic>[
        1,
        <dynamic>[2, 3],
      ]);
    });

    test('flattens nested strings (which are not Iterable here) as values', () {
      // Strings are not Iterable<dynamic>, so they are kept as leaf values.
      final List<dynamic> nested = <dynamic>[
        <dynamic>['a', 'b'],
        'c',
      ];
      expect(nested.flattenDeep().toList(), <dynamic>['a', 'b', 'c']);
    });
  });
}
