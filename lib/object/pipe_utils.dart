/// Also/let style (pipe value through function). Roadmap #202.
T also<T>(T value, void Function(T) fn) {
  fn(value);
  return value;
}

R let<T, R>(T value, R Function(T) fn) => fn(value);
