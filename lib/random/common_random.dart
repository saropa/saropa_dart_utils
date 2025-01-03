import 'dart:math';

/// Every time you reinstall your app, the CommonRandom() is being initialized
///  with the same starting conditions. To ensure you get a different result
///  each time, use the current timestamp as a seed. This makes the seed
///  dynamic and unique each time.
///
/// NOTE: if you call CommonRandom() multiple times in quick succession, they
///  might generate the same value due to the seed being based on
///  [DateTime.millisecondsSinceEpoch]
///
/// To get distinct values, you should initialize CommonRandom once and reuse
///  it.
///
// ignore: non_constant_identifier_names
Random CommonRandom([int? seed]) =>
    Random(seed ?? DateTime.now().millisecondsSinceEpoch);
