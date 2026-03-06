/// Log/exp transforms for analytics — roadmap #575.
library;

import 'dart:math' show log, exp;

/// Log transform: log(1 + x) to handle zeros.
double log1pSafe(num x) => x <= -1 ? double.negativeInfinity : log(1 + x.toDouble());

/// Exp transform.
double expSafe(num x) => exp(x.toDouble());

/// Log-scale list (1 + x then log).
List<double> logScale(List<num> values) => values.map((num x) => log1pSafe(x)).toList();
