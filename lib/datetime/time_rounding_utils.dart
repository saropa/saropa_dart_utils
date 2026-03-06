/// Flexible time rounding (nearest 5/10/15 min, ceiling/floor) — roadmap #600.
library;

/// Rounds [minutes] to nearest [step] (e.g. 5, 10, 15). [mode]: 0=nearest, 1=floor, 2=ceil.
int roundMinutes(int minutes, int step, {int mode = 0}) {
  if (step < 1) return minutes;
  final int q = minutes ~/ step;
  final int r = minutes % step;
  if (mode == 1) return q * step;
  if (mode == 2) return (q + (r > 0 ? 1 : 0)) * step;
  return (r * 2 >= step ? q + 1 : q) * step;
}
