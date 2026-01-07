import 'dart:math';

/// Creates a [Random] number generator.
///
/// Every time you reinstall your app, a `Random()` instance is initialized
/// with the same starting conditions, leading to the same sequence of "random" numbers.
/// To ensure you get a different sequence each time the app runs, this function
/// uses the current timestamp as a seed by default.
///
/// **NOTE:** If you call `CommonRandom()` multiple times in quick succession (within
/// the same millisecond), they might be seeded with the same value and thus
/// produce the same sequence of numbers.
///
/// To get distinct random values throughout your app, you should create a single
/// instance of `Random` and reuse it.
///
/// Example:
/// ```dart
/// final random = CommonRandom();
/// print(random.nextInt(100)); // A random number
/// print(random.nextBool());   // A random boolean
/// ```
///
/// You can also provide a fixed [seed] to get a predictable sequence of numbers,
/// which is useful for testing.
// ignore: non_constant_identifier_names
Random CommonRandom([int? seed]) =>
    // Algorithm:
    // 1. Check if a `seed` value is provided.
    // 2. If `seed` is null, use `DateTime.now().millisecondsSinceEpoch` as the seed.
    //    This makes the random sequence unique for each run.
    // 3. If `seed` is not null, use the provided value. This creates a predictable
    //    sequence, which is useful for testing or when reproducible "randomness" is needed.
    // 4. Create and return a `Random` instance with the determined seed.
    Random(seed ?? DateTime.now().millisecondsSinceEpoch);
