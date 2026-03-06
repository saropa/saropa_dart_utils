/// Parse simple boolean ("on"/"off", "1"/"0", "yes"/"no"). Roadmap #153.
bool? parseBool(String input) {
  final String s = input.trim().toLowerCase();
  const Set<String> trueValues = <String>{'true', '1', 'yes', 'on'};
  const Set<String> falseValues = <String>{'false', '0', 'no', 'off'};
  if (trueValues.contains(s)) return true;
  if (falseValues.contains(s)) return false;
  return null;
}
