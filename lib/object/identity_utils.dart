/// Identity equality (same reference). Roadmap #206.
bool identityEquals<T>(T? a, T? b) => identical(a, b);
