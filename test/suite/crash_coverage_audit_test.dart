import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/saropa_dart_utils.dart';

/// Pins the crash-family coverage audit (Suite Integration plan, R3) to two
/// contracts: the suite's crash-family id set, and the real public API.
///
/// The family ids mirror Log Capture's `CRASH_SIGNATURE_IDS`
/// (src/modules/diagnostics/crash-signature.ts). That list is the cross-tool
/// contract; if Log Capture adds a family, the set-equality check below fails
/// until the new family is triaged into the audit — which is the intended
/// "crash class observed by the suite, not yet covered" signal.
///
/// Every `covered` symbol has a probe that exercises it in compiled code, so a
/// rename or dropped export in `lib/` breaks the build instead of leaving the
/// audit claiming coverage that no longer compiles.
void main() {
  // The suite contract, copied from Log Capture's CRASH_SIGNATURE_IDS. This is
  // a deliberate duplicate of the upstream constant: the cross-tool contract is
  // not importable from a Dart package, so it is pinned here and any drift
  // (upstream add/remove) surfaces as a failing test to be reconciled by hand.
  const Set<String> suiteCrashFamilies = <String>{
    'state-error-no-element',
    'range-error-index',
    'null-check-operator',
    'late-init',
    'concurrent-modification',
    'type-error-cast',
    'format-exception',
    'no-such-method',
    'assertion-failed',
    'stack-overflow',
    'out-of-memory',
    'anr',
  };

  // One probe per `covered` symbol — the boolean is incidental; what matters is
  // that the expression compiles (symbol resolves) and returns the safe value
  // (null / no-throw) the coverage claim depends on.
  final Map<String, bool Function()> coveredProbes = <String, bool Function()>{
    'singleOrNull': () => <int>[].singleOrNull == null,
    'getOrNull': () => <int>[].getOrNull(5) == null,
    'castOrNull': () => castOrNull<int>('not an int') == null,
    'toIntNullable': () => 'not a number'.toIntNullable() == null,
    // Removing inside the body must not throw; result proves the safe walk ran.
    'forEachSnapshot': () {
      final List<int> q = <int>[1, 2, 3, 4];
      q.forEachSnapshot((int n) {
        if (n.isEven) q.remove(n);
      });
      return q.length == 2 && q.first == 1 && q.last == 3;
    },
  };

  group('kCrashCoverageAudit', () {
    test('family-id set equals the suite crash-family contract', () {
      final Set<String> auditFamilies = kCrashCoverageAudit
          .map((CrashFamilyCoverage c) => c.familyId)
          .toSet();

      expect(
        auditFamilies,
        equals(suiteCrashFamilies),
        reason:
            'Audit drifted from Log Capture CRASH_SIGNATURE_IDS. Triage any '
            'newly-added family (covered / gap / notApplicable) or drop a '
            'removed one.',
      );
    });

    test('family ids are unique', () {
      final List<String> ids = kCrashCoverageAudit
          .map((CrashFamilyCoverage c) => c.familyId)
          .toList();
      expect(ids.toSet().length, equals(ids.length));
    });

    test('status invariants: covered has symbol+source, others have neither', () {
      for (final CrashFamilyCoverage c in kCrashCoverageAudit) {
        if (c.status == CrashCoverageStatus.covered) {
          expect(c.symbol, isNotNull, reason: '${c.familyId} covered needs a symbol');
          expect(c.source, isNotNull, reason: '${c.familyId} covered needs a source');
          expect(c.source, endsWith('.dart'));
        } else {
          expect(c.symbol, isNull, reason: '${c.familyId} non-covered must omit symbol');
          expect(c.source, isNull, reason: '${c.familyId} non-covered must omit source');
        }
        expect(c.description, isNotEmpty);
        expect(c.note, isNotEmpty);
      }
    });

    test('every covered symbol has a probe and every probe is mapped', () {
      final Set<String> coveredSymbols = kCrashCoverageAudit
          .where((CrashFamilyCoverage c) => c.status == CrashCoverageStatus.covered)
          .map((CrashFamilyCoverage c) => c.symbol!)
          .toSet();

      expect(
        coveredSymbols,
        equals(coveredProbes.keys.toSet()),
        reason: 'Covered-symbol set and probe set drifted — add/remove a probe.',
      );
    });

    test('every covered symbol resolves and behaves on its safe input', () {
      for (final MapEntry<String, bool Function()> probe in coveredProbes.entries) {
        expect(
          probe.value(),
          isTrue,
          reason:
              'Probe for ${probe.key} did not return its safe value — the '
              'symbol changed behavior.',
        );
      }
    });

    test('there are no open coverage gaps', () {
      // The concurrent-modification gap was closed by forEachSnapshot (R3
      // follow-up). Pinned at zero so a newly-introduced gap (a coverage
      // regression, or a new suite family with no primitive) is noticed rather
      // than passing silently.
      final Set<String> gaps = kCrashCoverageAudit
          .where((CrashFamilyCoverage c) => c.status == CrashCoverageStatus.gap)
          .map((CrashFamilyCoverage c) => c.familyId)
          .toSet();

      expect(gaps, isEmpty);
    });
  });
}
