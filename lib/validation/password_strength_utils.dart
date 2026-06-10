/// Password strength estimation (entropy heuristics) — roadmap #687.
library;

const int _scoreMin = 0;
const int _scoreLengthShort = 8;
const int _scoreLengthLong = 12;
const int _scoreMax = 4;

/// Simple strength score 0..4 from length and character variety.
int passwordStrengthScore(String password) {
  if (password.isEmpty) return _scoreMin;
  // Additive scoring: one point each for two length tiers and three character
  // variety checks, so independent strengths stack into a single score.
  int score = _scoreMin;
  if (password.length >= _scoreLengthShort) score++;
  if (password.length >= _scoreLengthLong) score++;
  // Mixed-case (both upper AND lower present) is a single point.
  if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  // Any non-alphanumeric character counts as a symbol.
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
  // Clamp so the returned score stays within the documented band.
  return score.clamp(_scoreMin, _scoreMax);
}
