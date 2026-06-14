/// Saropa Suite — remediation coverage audit (Suite Integration plan, R3).
///
/// For each crash family the suite enumerates at runtime, records whether this
/// package ships a safe primitive that removes it. The family ids are the
/// cross-tool contract owned by Log Capture
/// (src/modules/diagnostics/crash-signature.ts, `CRASH_SIGNATURE_IDS`); this
/// table is the library's answer to "is that family remediable here yet?"
///
/// A [CrashCoverageStatus.gap] entry is a library backlog input — a crash class
/// the suite observes that a primitive COULD remove but none exists yet (the
/// mirror of Lints' "observed in production, no static rule yet"). A
/// [CrashCoverageStatus.notApplicable] entry is a family no pure-Dart utility
/// can prevent (a language feature, a runtime/resource fault) — recorded so the
/// audit is honest about what is out of reach rather than silently dropping it.
///
/// Pinned by test/suite/crash_coverage_audit_test.dart: the family-id set must
/// equal the suite contract (a new upstream family fails the test until
/// triaged here), and every [CrashCoverageStatus.covered] symbol is exercised
/// in compiled code so a rename in `lib/` breaks the build.
library;

/// Whether this package can remediate a crash family, and how.
enum CrashCoverageStatus {
  /// An owned safe primitive removes this crash family.
  covered,

  /// The suite observes this family and a primitive could remove it, but none
  /// exists here yet — a library backlog input.
  gap,

  /// No pure-Dart utility can prevent this family (language feature, runtime or
  /// resource fault). Recorded for honesty, not as backlog.
  notApplicable,
}

/// One row: a suite crash family and this package's coverage of it.
class CrashFamilyCoverage {
  const CrashFamilyCoverage({
    required this.familyId,
    required this.status,
    required this.description,
    required this.note,
    this.symbol,
    this.source,
  });

  /// Stable crash-family id from Log Capture's `CRASH_SIGNATURE_IDS`.
  final String familyId;

  /// This package's coverage verdict for [familyId].
  final CrashCoverageStatus status;

  /// The runtime failure [familyId] names.
  final String description;

  /// Why the [status] holds — for [CrashCoverageStatus.covered], how [symbol]
  /// removes the crash; for the others, why no symbol applies.
  final String note;

  /// The owned remediation symbol. Non-null only for [CrashCoverageStatus.covered].
  final String? symbol;

  /// The library file (relative to `lib/`) declaring [symbol]. Non-null only for
  /// [CrashCoverageStatus.covered].
  final String? source;
}

/// The audit. Family ids and order follow Log Capture's `CRASH_SIGNATURE_IDS`.
const List<CrashFamilyCoverage> kCrashCoverageAudit = <CrashFamilyCoverage>[
  CrashFamilyCoverage(
    familyId: 'state-error-no-element',
    status: CrashCoverageStatus.covered,
    description: 'Bad state: No element — .first/.last/.single on an empty iterable.',
    symbol: 'singleOrNull',
    source: 'list/list_lower_extensions.dart',
    note: 'singleOrNull (and lastOrNull/firstWhereOrElse/nullIfEmpty) return a '
        'value or null instead of throwing on the empty/no-element case.',
  ),
  CrashFamilyCoverage(
    familyId: 'range-error-index',
    status: CrashCoverageStatus.covered,
    description: 'RangeError (index) — list[i] past the end or negative.',
    symbol: 'getOrNull',
    source: 'list/list_lower_extensions.dart',
    note: 'getOrNull(index) bounds-checks and returns null for an out-of-range '
        'index instead of throwing.',
  ),
  CrashFamilyCoverage(
    familyId: 'null-check-operator',
    status: CrashCoverageStatus.notApplicable,
    description: 'Null check operator used on a null value — the ! operator on null.',
    note: 'Avoiding ! is a usage discipline, not a single primitive; the '
        'library\'s nullable-returning accessors support writing ?? / null '
        'checks instead, but no symbol "remediates" a bang.',
  ),
  CrashFamilyCoverage(
    familyId: 'late-init',
    status: CrashCoverageStatus.notApplicable,
    description: 'LateInitializationError — a late field read before assignment.',
    note: 'A language feature; no utility can prevent a late field being read '
        'early.',
  ),
  CrashFamilyCoverage(
    familyId: 'concurrent-modification',
    status: CrashCoverageStatus.covered,
    description:
        'Concurrent modification during iteration — mutating a collection inside its own loop.',
    symbol: 'forEachSnapshot',
    source: 'list/list_mutate_during_iteration_extensions.dart',
    note: 'forEachSnapshot walks a point-in-time copy of the list, so the body '
        'may add to or remove from the original without throwing '
        'ConcurrentModificationError.',
  ),
  CrashFamilyCoverage(
    familyId: 'type-error-cast',
    status: CrashCoverageStatus.covered,
    description: "type 'X' is not a subtype of type 'Y' — a failed cast.",
    symbol: 'castOrNull',
    source: 'object/cast_utils.dart',
    note: 'castOrNull<T>(value) returns null when the value is not a T instead of '
        'throwing on a bad cast (tryCast on a nullable receiver is the extension '
        'form).',
  ),
  CrashFamilyCoverage(
    familyId: 'format-exception',
    status: CrashCoverageStatus.covered,
    description:
        'FormatException — parsing malformed input (int.parse, jsonDecode, DateTime.parse).',
    symbol: 'toIntNullable',
    source: 'string/string_number_extensions.dart',
    note: 'toIntNullable (with parseBool, toDoubleNullable, parseIsoWeekString) '
        'returns null on unparseable input instead of throwing.',
  ),
  CrashFamilyCoverage(
    familyId: 'no-such-method',
    status: CrashCoverageStatus.notApplicable,
    description: 'NoSuchMethodError — a method/getter called on null or a wrong type.',
    note: 'A dynamic-dispatch fault; the nullable accessors reduce the null '
        'sources, but no primitive remediates the error itself.',
  ),
  CrashFamilyCoverage(
    familyId: 'assertion-failed',
    status: CrashCoverageStatus.notApplicable,
    description: 'Failed assertion — an assert(...) tripped in debug.',
    note: 'Asserts encode caller invariants; preventing a trip is a caller '
        'concern, not a utility.',
  ),
  CrashFamilyCoverage(
    familyId: 'stack-overflow',
    status: CrashCoverageStatus.notApplicable,
    description: 'Stack Overflow — unbounded recursion.',
    note: 'A control-flow fault no general primitive can prevent.',
  ),
  CrashFamilyCoverage(
    familyId: 'out-of-memory',
    status: CrashCoverageStatus.notApplicable,
    description: 'OutOfMemoryError / heap exhaustion.',
    note: 'A resource fault outside the reach of a pure-Dart utility.',
  ),
  CrashFamilyCoverage(
    familyId: 'anr',
    status: CrashCoverageStatus.notApplicable,
    description: 'Application Not Responding — main-thread block past the ANR threshold.',
    note: 'A threading/scheduling fault; the async throttling utils help latency '
        'but do not prevent an ANR as a crash class.',
  ),
];
