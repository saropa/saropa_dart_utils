# prefer_secure_random

## 3 violations | Severity: warning

### Rule Description
`Random()` uses a predictable PRNG. Replace with `Random.secure()` for security-sensitive operations.

### Assessment
- **False Positive**: Yes. The flagged usages are utility functions for shuffling lists and picking random elements from collections -- not security-sensitive operations. `Random.secure()` is cryptographically secure but slower, and is unnecessary for casual randomization such as shuffling a list or selecting a random element. Using `Random.secure()` here would add overhead with no security benefit.
- **Should Exclude**: Yes. This library provides general-purpose collection utilities where predictable PRNG is perfectly acceptable. Security-sensitive randomness is outside the scope of this library. Add `prefer_secure_random: false` to `analysis_options_custom.yaml`.

### Affected Files
- `lib\iterable\iterable_extensions.dart`
- `lib\map\map_extensions.dart`
- `lib\random\common_random.dart`

### Locations
3 violations, one in each of the files listed above. Each is a usage of `Random()` for non-security-sensitive randomization.

### Recommended Action
EXCLUDE -- add `prefer_secure_random: false` to `analysis_options_custom.yaml`. The rule is designed for applications handling cryptographic keys, tokens, or passwords. A utility library providing shuffle and random-pick helpers does not require cryptographic randomness.
