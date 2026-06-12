import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/semver_utils.dart';

void main() {
  group('SemverUtils constructor and getters', () {
    test('stores all components', () {
      final SemverUtils v = SemverUtils(1, 2, 3, 'rc.1', '001');
      expect(v.major, 1);
      expect(v.minor, 2);
      expect(v.patch, 3);
      expect(v.pre, 'rc.1');
      expect(v.build, '001');
    });

    test('pre and build default to empty', () {
      final SemverUtils v = SemverUtils(1, 0, 0);
      expect(v.pre, '');
      expect(v.build, '');
    });
  });

  group('SemverUtils.parse', () {
    test('plain version', () {
      final SemverUtils? v = SemverUtils.parse('1.2.3');
      expect(v, isNotNull);
      expect(v!.major, 1);
      expect(v.minor, 2);
      expect(v.patch, 3);
      expect(v.pre, '');
      expect(v.build, '');
    });

    test('leading v stripped', () {
      expect(SemverUtils.parse('v1.2.3')?.major, 1);
    });

    test('prerelease captured', () {
      final SemverUtils? v = SemverUtils.parse('1.2.3-rc.1');
      expect(v?.pre, 'rc.1');
      expect(v?.build, '');
    });

    test('build metadata captured', () {
      final SemverUtils? v = SemverUtils.parse('1.2.3+build.5');
      expect(v?.build, 'build.5');
      expect(v?.pre, '');
    });

    test('prerelease and build together', () {
      final SemverUtils? v = SemverUtils.parse('v1.2.3-rc.1+build');
      expect(v?.major, 1);
      expect(v?.pre, 'rc.1');
      expect(v?.build, 'build');
    });

    test('surrounding whitespace trimmed', () {
      expect(SemverUtils.parse('  1.2.3  ')?.patch, 3);
    });

    test('two-component version invalid', () => expect(SemverUtils.parse('1.2'), isNull));

    test('non-numeric component invalid', () => expect(SemverUtils.parse('1.x.3'), isNull));

    test('empty string invalid', () => expect(SemverUtils.parse(''), isNull));

    test('trailing junk invalid', () => expect(SemverUtils.parse('1.2.3 extra'), isNull));
  });

  group('SemverUtils.compareTo', () {
    test('equal versions compare equal', () {
      expect(SemverUtils(1, 0, 0).compareTo(SemverUtils(1, 0, 0)), 0);
    });

    test('lower major is negative', () {
      expect(SemverUtils(1, 0, 0).compareTo(SemverUtils(2, 0, 0)) < 0, isTrue);
    });

    test('higher minor is positive', () {
      expect(SemverUtils(1, 2, 0).compareTo(SemverUtils(1, 1, 0)) > 0, isTrue);
    });

    test('higher patch is positive', () {
      expect(SemverUtils(1, 0, 5).compareTo(SemverUtils(1, 0, 4)) > 0, isTrue);
    });

    test('prerelease ranks below release', () {
      expect(SemverUtils(1, 0, 0).compareTo(SemverUtils(1, 0, 0, 'rc.1')) > 0, isTrue);
    });

    test('release ranks above prerelease (reverse)', () {
      expect(SemverUtils(1, 0, 0, 'rc.1').compareTo(SemverUtils(1, 0, 0)) < 0, isTrue);
    });

    test('two prereleases compared lexically', () {
      expect(SemverUtils(1, 0, 0, 'rc.1').compareTo(SemverUtils(1, 0, 0, 'rc.2')) < 0, isTrue);
    });

    test('build metadata ignored in comparison', () {
      expect(SemverUtils(1, 0, 0, '', 'a').compareTo(SemverUtils(1, 0, 0, '', 'b')), 0);
    });
  });

  group('SemverUtils.compareTo prerelease precedence (semver §11)', () {
    test('numeric identifiers compare numerically, not lexically', () {
      // alpha.2 < alpha.10: a plain string compare wrongly makes "2" > "10".
      expect(
        SemverUtils(1, 0, 0, 'alpha.2').compareTo(SemverUtils(1, 0, 0, 'alpha.10')),
        lessThan(0),
      );
    });

    test('a numeric identifier ranks below an alphanumeric one', () {
      expect(
        SemverUtils(1, 0, 0, 'alpha.1').compareTo(SemverUtils(1, 0, 0, 'alpha.beta')),
        lessThan(0),
      );
    });

    test('fewer identifiers rank below more when the prefix is equal', () {
      // 1.0.0-alpha < 1.0.0-alpha.1
      expect(SemverUtils(1, 0, 0, 'alpha').compareTo(SemverUtils(1, 0, 0, 'alpha.1')), lessThan(0));
    });

    test('full semver §11 example ordering holds', () {
      // alpha < alpha.1 < alpha.beta < beta < beta.2 < beta.11 < rc.1
      final List<String> ordered = <String>[
        'alpha',
        'alpha.1',
        'alpha.beta',
        'beta',
        'beta.2',
        'beta.11',
        'rc.1',
      ];
      for (int i = 0; i + 1 < ordered.length; i++) {
        expect(
          SemverUtils(1, 0, 0, ordered[i]).compareTo(SemverUtils(1, 0, 0, ordered[i + 1])),
          lessThan(0),
          reason: '${ordered[i]} < ${ordered[i + 1]}',
        );
      }
    });
  });

  group('SemverUtils.toString', () {
    test('plain', () => expect(SemverUtils(1, 2, 3).toString(), 'SemverUtils(1.2.3)'));
    test('with prerelease', () {
      expect(SemverUtils(1, 2, 3, 'rc.1').toString(), 'SemverUtils(1.2.3-rc.1)');
    });
    test('with build', () {
      expect(SemverUtils(1, 2, 3, '', '001').toString(), 'SemverUtils(1.2.3+001)');
    });
    test('with prerelease and build', () {
      expect(SemverUtils(1, 2, 3, 'rc.1', '001').toString(), 'SemverUtils(1.2.3-rc.1+001)');
    });
  });
}
