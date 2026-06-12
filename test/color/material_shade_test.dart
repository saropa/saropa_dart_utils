import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/color/material_shade.dart';

void main() {
  // ---- Spec sample tests (verbatim coverage) --------------------------------

  group('MaterialShade.displayNameAnnotated', () {
    test('shade50 is labeled as Lightest', () {
      expect(MaterialShade.shade50.displayNameAnnotated, 'Shade 50 (Lightest)');
    });

    test('shade500 is labeled as Middle', () {
      expect(MaterialShade.shade500.displayNameAnnotated, 'Shade 500 (Middle)');
    });

    test('shade900 is labeled as Darkest', () {
      expect(MaterialShade.shade900.displayNameAnnotated, 'Shade 900 (Darkest)');
    });

    test('intermediate shades have no annotation', () {
      expect(MaterialShade.shade100.displayNameAnnotated, 'Shade 100');
      expect(MaterialShade.shade200.displayNameAnnotated, 'Shade 200');
      expect(MaterialShade.shade300.displayNameAnnotated, 'Shade 300');
      expect(MaterialShade.shade400.displayNameAnnotated, 'Shade 400');
      expect(MaterialShade.shade600.displayNameAnnotated, 'Shade 600');
      expect(MaterialShade.shade700.displayNameAnnotated, 'Shade 700');
      expect(MaterialShade.shade800.displayNameAnnotated, 'Shade 800');
    });
  });

  group('MaterialShade.value', () {
    test('shade values are correct', () {
      expect(MaterialShade.shade50.value, 50);
      expect(MaterialShade.shade100.value, 100);
      expect(MaterialShade.shade500.value, 500);
      expect(MaterialShade.shade900.value, 900);
    });
  });

  group('MaterialShade.displayName', () {
    test('displayName formats correctly', () {
      expect(MaterialShade.shade50.displayName, 'Shade 50');
      expect(MaterialShade.shade500.displayName, 'Shade 500');
      expect(MaterialShade.shade900.displayName, 'Shade 900');
    });
  });

  // ---- Bulletproofing: exhaustive value mapping -----------------------------

  group('MaterialShade.value (exhaustive)', () {
    test('all 10 members map to their integer parsed from the member name', () {
      // Loop every member so a future reorder/typo in the switch is caught,
      // deriving the expected integer from the enum's own name.
      for (final MaterialShade shade in MaterialShade.values) {
        final int expected = int.parse(shade.name.replaceAll('shade', ''));
        expect(shade.value, expected, reason: '${shade.name} should map to $expected');
      }
    });

    test('the full mapped set equals the canonical ladder', () {
      final List<int> mapped = MaterialShade.values.map((MaterialShade s) => s.value).toList();
      expect(mapped, <int>[50, 100, 200, 300, 400, 500, 600, 700, 800, 900]);
    });
  });

  // ---- Bulletproofing: exhaustive displayName -------------------------------

  group('MaterialShade.displayName (exhaustive)', () {
    test('all 10 members produce "Shade <value>"', () {
      for (final MaterialShade shade in MaterialShade.values) {
        expect(shade.displayName, 'Shade ${shade.value}');
      }
    });
  });

  // ---- Bulletproofing: displayNameAnnotated completeness --------------------

  group('MaterialShade.displayNameAnnotated (completeness)', () {
    test('exactly three members carry a parenthetical annotation', () {
      final List<MaterialShade> annotated = MaterialShade.values
          .where((MaterialShade s) => s.displayNameAnnotated.contains('('))
          .toList();
      expect(annotated, <MaterialShade>[
        MaterialShade.shade50,
        MaterialShade.shade500,
        MaterialShade.shade900,
      ]);
    });

    test('the other seven equal their plain displayName', () {
      // Guards against an accidental extra annotation leaking onto a mid-band rung.
      const Set<MaterialShade> endpoints = <MaterialShade>{
        MaterialShade.shade50,
        MaterialShade.shade500,
        MaterialShade.shade900,
      };
      for (final MaterialShade shade in MaterialShade.values) {
        if (endpoints.contains(shade)) {
          continue;
        }
        expect(shade.displayNameAnnotated, shade.displayName, reason: shade.name);
      }
    });
  });

  // ---- Bulletproofing: onShade partition + opacity --------------------------

  group('MaterialShade.onShade', () {
    test('light band (shade50..shade400) is black', () {
      for (final MaterialShade shade in <MaterialShade>[
        MaterialShade.shade50,
        MaterialShade.shade100,
        MaterialShade.shade200,
        MaterialShade.shade300,
        MaterialShade.shade400,
      ]) {
        expect(shade.onShade, Colors.black, reason: shade.name);
      }
    });

    test('dark band (shade500..shade900) is white', () {
      for (final MaterialShade shade in <MaterialShade>[
        MaterialShade.shade500,
        MaterialShade.shade600,
        MaterialShade.shade700,
        MaterialShade.shade800,
        MaterialShade.shade900,
      ]) {
        expect(shade.onShade, Colors.white, reason: shade.name);
      }
    });

    test('partition is total — every member is black or white only', () {
      for (final MaterialShade shade in MaterialShade.values) {
        final bool isBlackOrWhite = shade.onShade == Colors.black || shade.onShade == Colors.white;
        expect(isBlackOrWhite, isTrue, reason: shade.name);
      }
    });

    test('boundary sits exactly between shade400 and shade500', () {
      // The last light-band rung is black; the first dark-band rung flips to white.
      expect(MaterialShade.shade400.onShade, Colors.black);
      expect(MaterialShade.shade500.onShade, Colors.white);
    });

    test('onShade is fully opaque for every member (alpha == 1.0)', () {
      // A future tweak must not introduce a translucent foreground.
      for (final MaterialShade shade in MaterialShade.values) {
        expect(shade.onShade.a, 1.0, reason: shade.name);
      }
    });
  });

  // ---- Bulletproofing: band-list integrity ----------------------------------

  group('MaterialShadeLevels band lists', () {
    test('lightShades is exactly [50,100,200,300,400] in order', () {
      expect(MaterialShadeLevels.lightShades, <int>[50, 100, 200, 300, 400]);
    });

    test('darkShades is exactly [500,600,700,800,900] in order', () {
      expect(MaterialShadeLevels.darkShades, <int>[500, 600, 700, 800, 900]);
    });

    test('shades equals lightShades followed by darkShades', () {
      expect(
        MaterialShadeLevels.shades,
        <int>[...MaterialShadeLevels.lightShades, ...MaterialShadeLevels.darkShades],
      );
    });

    test('shades has length 10 with no duplicates', () {
      expect(MaterialShadeLevels.shades, hasLength(10));
      expect(MaterialShadeLevels.shades.toSet(), hasLength(10));
    });

    test('every integer in shades is the value of exactly one member', () {
      // Round-trip: the band lists and the enum can never diverge.
      final List<int> enumValues = MaterialShade.values.map((MaterialShade s) => s.value).toList();
      expect(MaterialShadeLevels.shades.toSet(), enumValues.toSet());
      for (final int level in MaterialShadeLevels.shades) {
        final int matches = enumValues.where((int v) => v == level).length;
        expect(matches, 1, reason: 'level $level should map to exactly one member');
      }
    });

    test('const band lists are unmodifiable — adding throws', () {
      expect(() => MaterialShadeLevels.shades.add(999), throwsUnsupportedError);
      expect(() => MaterialShadeLevels.lightShades.add(999), throwsUnsupportedError);
      expect(() => MaterialShadeLevels.darkShades.add(999), throwsUnsupportedError);
    });
  });

  // ---- Bulletproofing: onShade <-> band consistency -------------------------

  group('onShade and band lists agree', () {
    test('every lightShades value maps to a black-onShade member', () {
      for (final int level in MaterialShadeLevels.lightShades) {
        final MaterialShade shade = MaterialShade.values.firstWhere(
          (MaterialShade s) => s.value == level,
        );
        expect(shade.onShade, Colors.black, reason: 'level $level');
      }
    });

    test('every darkShades value maps to a white-onShade member', () {
      for (final int level in MaterialShadeLevels.darkShades) {
        final MaterialShade shade = MaterialShade.values.firstWhere(
          (MaterialShade s) => s.value == level,
        );
        expect(shade.onShade, Colors.white, reason: 'level $level');
      }
    });
  });

  // ---- Bulletproofing: randomShade determinism + constraints ----------------

  group('MaterialShadeLevels.randomShade', () {
    test('same seed returns the same shade across repeated calls', () {
      final int? first = MaterialShadeLevels.randomShade(seed: 42);
      final int? second = MaterialShadeLevels.randomShade(seed: 42);
      expect(first, second);
      expect(first, isNotNull);
    });

    test('isLightBackground true only ever returns a dark-band member', () {
      // Light background wants the DARK, high-contrast shade.
      for (int seed = 0; seed < 1000; seed++) {
        final int? result = MaterialShadeLevels.randomShade(
          isLightBackground: true,
          seed: seed,
        );
        expect(
          MaterialShadeLevels.darkShades.contains(result),
          isTrue,
          reason: 'seed $seed produced $result, not in dark band',
        );
      }
    });

    test('isLightBackground false only ever returns a light-band member', () {
      for (int seed = 0; seed < 1000; seed++) {
        final int? result = MaterialShadeLevels.randomShade(
          isLightBackground: false,
          seed: seed,
        );
        expect(
          MaterialShadeLevels.lightShades.contains(result),
          isTrue,
          reason: 'seed $seed produced $result, not in light band',
        );
      }
    });

    test('null background returns a member of the full ladder', () {
      for (int seed = 0; seed < 1000; seed++) {
        final int? result = MaterialShadeLevels.randomShade(seed: seed);
        expect(
          MaterialShadeLevels.shades.contains(result),
          isTrue,
          reason: 'seed $seed produced $result, not in full ladder',
        );
      }
    });

    test('distribution — every dark-band shade appears across the seed sweep', () {
      final Set<int> seen = <int>{};
      for (int seed = 0; seed < 1000; seed++) {
        final int? result = MaterialShadeLevels.randomShade(isLightBackground: true, seed: seed);
        if (result != null) {
          seen.add(result);
        }
      }
      expect(seen, MaterialShadeLevels.darkShades.toSet());
    });

    test('distribution — every light-band shade appears across the seed sweep', () {
      final Set<int> seen = <int>{};
      for (int seed = 0; seed < 1000; seed++) {
        final int? result = MaterialShadeLevels.randomShade(isLightBackground: false, seed: seed);
        if (result != null) {
          seen.add(result);
        }
      }
      expect(seen, MaterialShadeLevels.lightShades.toSet());
    });

    test('distribution — every full-ladder shade appears across the seed sweep', () {
      final Set<int> seen = <int>{};
      for (int seed = 0; seed < 1000; seed++) {
        final int? result = MaterialShadeLevels.randomShade(seed: seed);
        if (result != null) {
          seen.add(result);
        }
      }
      expect(seen, MaterialShadeLevels.shades.toSet());
    });

    test('never returns null across a seed sweep (const lists are non-empty)', () {
      // The only path to null is an empty source list, which cannot happen here.
      for (int seed = 0; seed < 1000; seed++) {
        expect(MaterialShadeLevels.randomShade(seed: seed), isNotNull);
        expect(
          MaterialShadeLevels.randomShade(isLightBackground: true, seed: seed),
          isNotNull,
        );
        expect(
          MaterialShadeLevels.randomShade(isLightBackground: false, seed: seed),
          isNotNull,
        );
      }
    });
  });

  // ---- Bulletproofing: enum stability ---------------------------------------

  group('MaterialShade enum stability', () {
    test('there are exactly 10 members', () {
      expect(MaterialShade.values, hasLength(10));
    });

    test('ordinal order is shade50 < shade100 < ... < shade900', () {
      // index-based persistence relies on this ordering staying intact.
      expect(MaterialShade.shade50.index, 0);
      expect(MaterialShade.shade900.index, 9);
      for (int i = 1; i < MaterialShade.values.length; i++) {
        expect(
          MaterialShade.values[i].value > MaterialShade.values[i - 1].value,
          isTrue,
          reason: '${MaterialShade.values[i].name} should rank above the previous',
        );
      }
    });
  });

  // ---- Bulletproofing: no locale/formatting drift ---------------------------

  group('MaterialShade.displayName byte stability', () {
    test('uses a plain ASCII space and Arabic digits, no exotic separators', () {
      // Exact code-unit comparison guards persisted/compared labels against a
      // future "pretty number" change swapping in a thin or non-breaking space.
      const String label = 'Shade 500';
      expect(MaterialShade.shade500.displayName.codeUnits, label.codeUnits);

      final String rendered = MaterialShade.shade500.displayName;
      expect(rendered.contains(' '), isFalse, reason: 'no non-breaking space');
      expect(rendered.contains(' '), isFalse, reason: 'no thin space');
      expect(rendered.codeUnitAt(5), 0x20, reason: 'separator is plain ASCII space');
    });
  });
}
