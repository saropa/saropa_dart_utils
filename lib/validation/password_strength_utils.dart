/// Password strength estimation (entropy heuristics) — roadmap #687.
library;

const int _scoreMin = 0;
const int _scoreLengthShort = 8;
const int _scoreLengthLong = 12;
const int _scoreMax = 4;

/// Simple strength score 0..4 from length and character variety.
int passwordStrengthScore(String password) {
  if (password.isEmpty) return _scoreMin;
  int score = _scoreMin;
  if (password.length >= _scoreLengthShort) score++;
  if (password.length >= _scoreLengthLong) score++;
  if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
  return score.clamp(_scoreMin, _scoreMax);
}
