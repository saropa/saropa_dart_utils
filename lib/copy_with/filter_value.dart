/// Optional-write wrapper for `copyWith` parameters that need to distinguish
/// "keep the current value" from "explicitly clear to null".
///
/// Default `copyWith` parameters of type `T?` collapse two distinct intents:
/// passing `null` always reads as "no override given", so a nullable field can
/// never be reset to null through the idiomatic `field: newField ?? this.field`
/// pattern. For classes that store nullable fields (tri-state booleans like
/// `hasFoo: true / false / null`), callers cannot reset a previously-set field
/// back to null. The common workaround is a companion `bool fieldForceNull`
/// parameter per nullable field, which doubles the parameter surface.
///
/// [FilterValue] replaces that workaround by carrying an explicit `isSet` flag
/// so three intents stay distinguishable:
///
/// 1. **unset** — [FilterValue.unset] carries `isSet: false`; [resolve] keeps
///    the caller's current value.
/// 2. **set to a value** — `FilterValue(v)` carries `isSet: true`; [resolve]
///    overrides with `v`.
/// 3. **set to null** — `FilterValue(null)` *also* carries `isSet: true`;
///    [resolve] overrides with `null` (the explicit-clear path the
///    `*ForceNull` companion parameter used to express).
///
/// This is a pure data/value pattern with zero domain coupling — the Dart
/// analogue of an `Optional`/`Patch`/sentinel "field present vs absent" wrapper
/// used in any partial-update or tri-state-filter context.
///
/// Example:
/// ```dart
/// // In a copyWith signature, default the parameter to unset so omitting it
/// // means "keep current":
/// MyFilter copyWith({FilterValue<bool> hasPhoto = const FilterValue.unset()}) =>
///     MyFilter(hasPhoto: hasPhoto.resolve(this.hasPhoto));
///
/// filter.copyWith();                                   // hasPhoto unchanged
/// filter.copyWith(hasPhoto: const FilterValue(true));  // hasPhoto -> true
/// filter.copyWith(hasPhoto: const FilterValue(null));  // hasPhoto cleared to null
/// ```
class FilterValue<T> {
  /// Wraps an explicit override — `isSet` is `true`, so [resolve] returns
  /// [value] regardless of the current value.
  ///
  /// Passing `null` here is the explicit-clear-to-null intent and stays
  /// distinct from [FilterValue.unset]: `FilterValue(null)` overrides with
  /// null, whereas [FilterValue.unset] keeps the current value. Collapsing the
  /// two is exactly the bug this class exists to prevent.
  ///
  /// Example:
  /// ```dart
  /// const FilterValue<int>(0).resolve(5);     // 0  (set, even though falsy)
  /// const FilterValue<bool>(null).resolve(true); // null (explicit clear)
  /// ```
  const FilterValue(this.value) : isSet = true;

  /// The "no override given" wrapper — `isSet` is `false`, so [resolve] returns
  /// the caller's current value unchanged (the keep-existing path).
  ///
  /// This is the intended default for a `copyWith` parameter: a `const`
  /// constructor so `{FilterValue<T> field = const FilterValue.unset()}` is a
  /// legal default, making "parameter omitted" mean "keep current".
  ///
  /// Example:
  /// ```dart
  /// const FilterValue<String>.unset().resolve('keep'); // 'keep'
  /// const FilterValue<String>.unset().value;           // null
  /// ```
  const FilterValue.unset()
      : value = null,
        isSet = false;

  /// The override value carried when [isSet] is `true`.
  ///
  /// Always `null` for [FilterValue.unset]. For [FilterValue.new] this is the
  /// exact reference supplied by the caller — the wrapper holds it by reference
  /// and never copies it, so a held `List`/`Map` resolves to the same instance.
  final T? value;

  /// Whether this wrapper carries an explicit override.
  ///
  /// `true` for any `FilterValue(v)` (including `FilterValue(null)`), `false`
  /// only for [FilterValue.unset]. This flag — not the nullness of [value] —
  /// is what [resolve] branches on, which is why "set to null" and "unset"
  /// stay distinguishable.
  final bool isSet;

  /// Resolves to [value] if this wrapper was explicitly set (including set to
  /// null); otherwise returns [current] — the keep-existing path.
  ///
  /// Pure: branches solely on [isSet], reads no external state, and mutates
  /// nothing, so repeated calls with the same argument return the same result.
  ///
  /// Example:
  /// ```dart
  /// const FilterValue<int>.unset().resolve(5); // 5    (keep current)
  /// const FilterValue<int>(9).resolve(5);      // 9    (override)
  /// const FilterValue<int>(null).resolve(5);   // null (explicit clear)
  /// ```
  T? resolve(T? current) => isSet ? value : current;
}
