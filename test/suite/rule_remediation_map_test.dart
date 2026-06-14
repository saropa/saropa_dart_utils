import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/saropa_dart_utils.dart';

/// Pins the rule-to-remediation mapping (Suite Integration plan, R1) to the
/// real public API. Each mapped symbol has a probe below that exercises it in
/// compiled code: if a symbol is renamed or its export is dropped, the probe
/// fails to compile and this test (and the build) breaks — so the mapping can
/// never ship a suggestion pointing at a symbol that no longer exists.
///
/// The probe set is keyed by [RuleRemediation.symbol]. Two-way drift is caught:
/// a mapped symbol with no probe, or a probe for a symbol no longer mapped,
/// both fail the set-equality check.
void main() {
  // Each probe touches its symbol once. The boolean result is incidental — what
  // matters is that the expression compiles (symbol resolves) and runs without
  // throwing on the documented safe input (the property the rule wants).
  final Map<String, bool Function()> probes = <String, bool Function()>{
    // reduce throws on empty; sumBy returns 0.
    'sumBy': () => <int>[].sumBy((int e) => e) == 0,
    // firstWhere throws with no match; firstWhereOrElse returns the default.
    'firstWhereOrElse': () =>
        <int>[].firstWhereOrElse((int e) => true, -1) == -1,
    // single throws on length != 1; singleOrNull returns null.
    'singleOrNull': () => <int>[].singleOrNull == null,
    // empty result must be handled before access; nullIfEmpty collapses to null.
    'nullIfEmpty': () => <int>[].nullIfEmpty() == null,
    // null elements stripped with a non-nullable element type.
    'whereNotNull': () => <int?>[1, null].whereNotNull().length == 1,
    // bad numeric input returns null instead of throwing FormatException.
    'toIntNullable': () => 'not-a-number'.toIntNullable() == null,
    // a path that escapes its root is rejected before any filesystem access.
    'isPathSafe': () => isPathSafe('../secret', 'home/user') == false,
  };

  group('kRuleRemediations', () {
    test('every mapped symbol has a probe and every probe is mapped', () {
      final Set<String> mappedSymbols =
          kRuleRemediations.map((RuleRemediation r) => r.symbol).toSet();

      expect(
        mappedSymbols,
        equals(probes.keys.toSet()),
        reason: 'Mapping and probe set drifted. Add a probe for any new symbol '
            '(and remove the probe for any symbol no longer mapped).',
      );
    });

    test('every mapped symbol resolves and behaves on its safe input', () {
      // Running the probe proves the symbol resolves (compiled) AND that it
      // returns the safe value the rule's remediation depends on.
      for (final MapEntry<String, bool Function()> probe in probes.entries) {
        expect(
          probe.value(),
          isTrue,
          reason: 'Probe for ${probe.key} did not return its expected safe '
              'value — the symbol changed behavior.',
        );
      }
    });

    test('rule ids are unique and all fields are non-empty', () {
      final List<String> ruleIds =
          kRuleRemediations.map((RuleRemediation r) => r.ruleId).toList();

      expect(
        ruleIds.toSet().length,
        equals(ruleIds.length),
        reason: 'Duplicate ruleId in the mapping — each rule joins once.',
      );

      for (final RuleRemediation r in kRuleRemediations) {
        expect(r.ruleId, isNotEmpty);
        expect(r.symbol, isNotEmpty);
        expect(r.source, isNotEmpty);
        expect(r.crashClass, isNotEmpty);
        expect(r.note, isNotEmpty);
      }
    });

    test('source paths point at lib/ dart files', () {
      for (final RuleRemediation r in kRuleRemediations) {
        expect(
          r.source.endsWith('.dart'),
          isTrue,
          reason: '${r.ruleId} source must name a .dart file under lib/.',
        );
      }
    });
  });
}
