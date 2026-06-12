/// Log/exp transforms for analytics — roadmap #575.
library;

import 'dart:math' show log, exp;

/// Log transform: log(1 + x) to handle zeros.
/// Audited: 2026-06-12 11:26 EDT
double log1pSafe(num x) => x <= -1 ? double.negativeInfinity : log(1 + x.toDouble());

/// Exp transform.
/// Audited: 2026-06-12 11:26 EDT
double expSafe(num x) => exp(x.toDouble());

/// Log-scale list (1 + x then log).
/// Audited: 2026-06-12 11:26 EDT
List<double> logScale(List<num> values) => values.map((num x) => log1pSafe(x)).toList();
