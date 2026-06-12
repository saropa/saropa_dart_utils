/// Flexible time rounding (nearest 5/10/15 min, ceiling/floor) — roadmap #600.
library;

/// Rounds [minutes] to nearest [step] (e.g. 5, 10, 15). [mode]: 0=nearest, 1=floor, 2=ceil.
/// Audited: 2026-06-12 11:26 EDT
int roundMinutes(int minutes, int step, {int mode = 0}) {
  // A non-positive step has no meaningful quotient (and would divide by zero),
  // so leave the input untouched rather than throw.
  if (step < 1) return minutes;
  final int q = minutes ~/ step;
  final int r = minutes % step;
  // mode 1 = floor: drop the remainder. mode 2 = ceil: bump to the next step
  // whenever any remainder exists. Default = round half-up, tested as r*2 >= step
  // (pure integer arithmetic) to avoid the floating-point error a minutes/step
  // division would introduce at the exact halfway point.
  if (mode == 1) return q * step;
  if (mode == 2) return (q + (r > 0 ? 1 : 0)) * step;
  return (r * 2 >= step ? q + 1 : q) * step;
}
