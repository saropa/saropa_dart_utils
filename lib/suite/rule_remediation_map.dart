/// Saropa Suite — rule-to-remediation mapping (Suite Integration plan, R1).
///
/// Joins a `saropa_lints` crash-prevention rule (`ruleId`) to the
/// `saropa_dart_utils` public symbol that removes the runtime failure the rule
/// flags. This is the data that lets a sibling tool's quick fix upgrade from
/// "enable rule X" to "enable rule X and use `Y` from saropa_dart_utils".
///
/// Ownership (settled 2026-06-14 against the sibling changelogs): `saropa_lints`
/// owns rule -> crash-signature, this package owns rule -> util-symbol, and the
/// two join on `ruleId`. See plans/SAROPA_SUITE_INTEGRATION.md.
///
/// Every [symbol] here is a real public export of this package, pinned by
/// test/suite/rule_remediation_map_test.dart: that test exercises each symbol
/// in compiled code, so a rename in `lib/` (or a removed export) breaks the
/// build instead of shipping a dead suggestion. A rule id that disappears
/// upstream is caught the same way — the mapping is data, the test is the lock.
library;

/// One join row: a crash-prevention rule and the safe primitive that fixes it.
class RuleRemediation {
  const RuleRemediation({
    required this.ruleId,
    required this.symbol,
    required this.source,
    required this.crashClass,
    required this.note,
  });

  /// The `saropa_lints` rule id (e.g. `avoid_unsafe_reduce`). Join key.
  final String ruleId;

  /// The `saropa_dart_utils` public symbol that remediates it. For an extension
  /// member this is `member` as a developer would type it at a call site
  /// (`xs.sumBy(...)`); for a top-level function it is the bare name.
  final String symbol;

  /// The library file (relative to `lib/`) that declares [symbol].
  final String source;

  /// The runtime failure [ruleId] flags — the thing [symbol] prevents.
  final String crashClass;

  /// Why [symbol] removes [crashClass] — the property the manual code lacks.
  final String note;
}

/// The mapping table. Multiple rules may share one [RuleRemediation.symbol]
/// (several "unsafe collection access" rules collapse onto one safe accessor);
/// [RuleRemediation.ruleId] is unique. Kept crash-focused on purpose: only
/// rules whose remediation is a primitive THIS package owns appear here.
const List<RuleRemediation> kRuleRemediations = <RuleRemediation>[
  // Calling reduce on an empty collection throws StateError; sumBy returns 0.
  RuleRemediation(
    ruleId: 'avoid_unsafe_reduce',
    symbol: 'sumBy',
    source: 'iterable/iterable_sum_by_extensions.dart',
    crashClass: 'StateError — reduce() on an empty collection',
    note: 'sumBy folds from a zero accumulator, so an empty collection returns '
        '0 instead of throwing.',
  ),

  // Chaining first or single after where throws when nothing matches;
  // firstWhereOrElse returns a caller-supplied default instead.
  RuleRemediation(
    ruleId: 'avoid_unsafe_where_methods',
    symbol: 'firstWhereOrElse',
    source: 'iterable/iterable_first_last_extensions.dart',
    crashClass: 'StateError — first/single after where() with no match',
    note: 'firstWhereOrElse returns orElse when no element matches, removing the '
        'no-match throw.',
  ),
  RuleRemediation(
    ruleId: 'prefer_where_or_null',
    symbol: 'firstWhereOrElse',
    source: 'iterable/iterable_first_last_extensions.dart',
    crashClass: 'StateError — firstWhere() with no match and no orElse',
    note: 'firstWhereOrElse makes the no-match branch explicit and total.',
  ),
  RuleRemediation(
    ruleId: 'geocoding_unchecked_first',
    symbol: 'firstWhereOrElse',
    source: 'iterable/iterable_first_last_extensions.dart',
    crashClass: 'StateError — .first on an empty geocoding result list',
    note: 'A geocode lookup can return zero placemarks; firstWhereOrElse yields '
        'a default rather than throwing on the empty result.',
  ),

  // Calling single throws on zero or more-than-one elements; singleOrNull
  // returns null for both.
  RuleRemediation(
    ruleId: 'avoid_unsafe_collection_methods',
    symbol: 'singleOrNull',
    source: 'list/list_lower_extensions.dart',
    crashClass: 'StateError — .single on a list whose length is not exactly 1',
    note: 'singleOrNull returns null when the list is empty or has more than one '
        'element, so the caller handles the null branch instead of crashing.',
  ),

  // Indexing a possibly-empty result list crashes; nullIfEmpty turns an empty
  // list into a null the caller must handle before reaching in.
  RuleRemediation(
    ruleId: 'image_picker_multi_result_unchecked_empty',
    symbol: 'nullIfEmpty',
    source: 'list/list_extensions.dart',
    crashClass: 'RangeError/StateError — indexing an empty picker result list',
    note: 'nullIfEmpty collapses an empty list to null so a `?.` guard forces the '
        'empty case to be handled before any element access.',
  ),

  // Collection still holds nulls when the op assumes non-null; whereNotNull
  // strips them with promotion intact.
  RuleRemediation(
    ruleId: 'require_null_safe_extensions',
    symbol: 'whereNotNull',
    source: 'iterable/iterable_map_not_null_extensions.dart',
    crashClass: 'Null-deref — operating on a collection that still contains null',
    note: 'whereNotNull yields a non-nullable element type, removing the null '
        'elements rather than dereferencing them downstream.',
  ),

  // Parsing dynamic data with int.parse throws FormatException on bad input;
  // toIntNullable returns null instead.
  RuleRemediation(
    ruleId: 'prefer_try_parse_for_dynamic_data',
    symbol: 'toIntNullable',
    source: 'string/string_number_extensions.dart',
    crashClass: 'FormatException — parse() on non-numeric dynamic input',
    note: 'toIntNullable returns null for unparseable input, so the failure is a '
        'value to handle rather than a thrown exception.',
  ),

  // Path built from user input can escape its root; isPathSafe rejects '..'
  // escapes before any file access.
  RuleRemediation(
    ruleId: 'avoid_path_traversal',
    symbol: 'isPathSafe',
    source: 'validation/path_validator_utils.dart',
    crashClass: 'Path traversal — a path with ../ segments escaping its root',
    note: 'isPathSafe returns false when the normalized path climbs above root, '
        'so traversal is rejected before the path reaches the filesystem.',
  ),
];
