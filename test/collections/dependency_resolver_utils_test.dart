import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/dependency_resolver_utils.dart';

void main() {
  group('resolveDependencies', () {
    test('should resolve a simple chain and order dependencies first', () {
      final DependencyResolution result = resolveDependencies(
        root: <String, String>{'app': '^1.0.0'},
        universe: <PackageManifest>[
          const PackageManifest('app', '1.2.0', dependencies: <String, String>{'lib': '^2.0.0'}),
          const PackageManifest('lib', '2.1.0'),
        ],
      );

      expect(result.versions, equals(<String, String>{'app': '1.2.0', 'lib': '2.1.0'}));
      // lib must come before app.
      expect(result.installOrder.indexOf('lib') < result.installOrder.indexOf('app'), isTrue);
    });

    test('should pick the highest version satisfying the constraint', () {
      final DependencyResolution result = resolveDependencies(
        root: <String, String>{'lib': '^1.0.0'},
        universe: <PackageManifest>[
          const PackageManifest('lib', '1.0.0'),
          const PackageManifest('lib', '1.5.2'),
          const PackageManifest('lib', '2.0.0'), // excluded by caret upper bound
        ],
      );

      expect(result.versions['lib'], equals('1.5.2'));
    });

    test('should intersect constraints from multiple requirers (diamond)', () {
      final DependencyResolution result = resolveDependencies(
        root: <String, String>{'a': '^1.0.0', 'b': '^1.0.0'},
        universe: <PackageManifest>[
          const PackageManifest('a', '1.0.0', dependencies: <String, String>{'shared': '>=1.0.0'}),
          const PackageManifest('b', '1.0.0', dependencies: <String, String>{'shared': '<1.5.0'}),
          const PackageManifest('shared', '1.0.0'),
          const PackageManifest('shared', '1.4.0'),
          const PackageManifest('shared', '1.9.0'),
        ],
      );

      // >=1.0.0 AND <1.5.0 => highest is 1.4.0.
      expect(result.versions['shared'], equals('1.4.0'));
    });

    test('should resolve transitive dependencies', () {
      final DependencyResolution result = resolveDependencies(
        root: <String, String>{'a': '1.0.0'},
        universe: <PackageManifest>[
          const PackageManifest('a', '1.0.0', dependencies: <String, String>{'b': '1.0.0'}),
          const PackageManifest('b', '1.0.0', dependencies: <String, String>{'c': '1.0.0'}),
          const PackageManifest('c', '1.0.0'),
        ],
      );

      expect(result.versions.keys.toSet(), equals(<String>{'a', 'b', 'c'}));
      // c before b before a.
      final List<String> order = result.installOrder;
      expect(order.indexOf('c') < order.indexOf('b'), isTrue);
      expect(order.indexOf('b') < order.indexOf('a'), isTrue);
    });

    test('should throw when no version satisfies the constraints', () {
      expect(
        () => resolveDependencies(
          root: <String, String>{'a': '^1.0.0', 'b': '^1.0.0'},
          universe: <PackageManifest>[
            const PackageManifest('a', '1.0.0', dependencies: <String, String>{'shared': '>=2.0.0'}),
            const PackageManifest('b', '1.0.0', dependencies: <String, String>{'shared': '<1.0.0'}),
            const PackageManifest('shared', '1.5.0'),
          ],
        ),
        throwsA(isA<DependencyResolutionException>()),
      );
    });

    test('should throw when a required package is missing from the universe', () {
      expect(
        () => resolveDependencies(
          root: <String, String>{'ghost': '^1.0.0'},
          universe: <PackageManifest>[const PackageManifest('real', '1.0.0')],
        ),
        throwsA(isA<DependencyResolutionException>()),
      );
    });

    test('should throw on a dependency cycle', () {
      expect(
        () => resolveDependencies(
          root: <String, String>{'a': '1.0.0'},
          universe: <PackageManifest>[
            const PackageManifest('a', '1.0.0', dependencies: <String, String>{'b': '1.0.0'}),
            const PackageManifest('b', '1.0.0', dependencies: <String, String>{'a': '1.0.0'}),
          ],
        ),
        throwsA(isA<DependencyResolutionException>()),
      );
    });

    group('constraint matching', () {
      test('should honor comparison operators', () {
        final DependencyResolution result = resolveDependencies(
          root: <String, String>{'lib': '>=1.2.0 <1.4.0'},
          universe: <PackageManifest>[
            const PackageManifest('lib', '1.1.0'),
            const PackageManifest('lib', '1.3.0'),
            const PackageManifest('lib', '1.5.0'),
          ],
        );

        expect(result.versions['lib'], equals('1.3.0'));
      });

      test('should honor a 0.x caret (minor-locked)', () {
        final DependencyResolution result = resolveDependencies(
          root: <String, String>{'lib': '^0.2.0'},
          universe: <PackageManifest>[
            const PackageManifest('lib', '0.2.5'),
            const PackageManifest('lib', '0.3.0'), // excluded: ^0.2.0 => <0.3.0
          ],
        );

        expect(result.versions['lib'], equals('0.2.5'));
      });

      test('should match an exact bare version', () {
        final DependencyResolution result = resolveDependencies(
          root: <String, String>{'lib': '1.0.0'},
          universe: <PackageManifest>[
            const PackageManifest('lib', '1.0.0'),
            const PackageManifest('lib', '1.0.1'),
          ],
        );

        expect(result.versions['lib'], equals('1.0.0'));
      });

      test('should treat * as any version (highest wins)', () {
        final DependencyResolution result = resolveDependencies(
          root: <String, String>{'lib': '*'},
          universe: <PackageManifest>[
            const PackageManifest('lib', '1.0.0'),
            const PackageManifest('lib', '3.2.1'),
          ],
        );

        expect(result.versions['lib'], equals('3.2.1'));
      });
    });
  });
}
