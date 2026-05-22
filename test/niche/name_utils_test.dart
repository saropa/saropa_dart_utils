import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/niche/name_utils.dart';

void main() {
  group('abbreviateName', () {
    test('two-part name abbreviates the first', () {
      expect(abbreviateName('John Doe'), 'J. Doe');
    });

    test('three-part name uses first and last', () {
      expect(abbreviateName('John Quincy Adams'), 'J. Adams');
    });

    test('single-word name is returned as-is', () {
      expect(abbreviateName('Plato'), 'Plato');
    });

    test('collapses extra whitespace', () {
      expect(abbreviateName('John   Doe'), 'J. Doe');
    });

    test('empty string returns empty', () {
      expect(abbreviateName(''), '');
    });

    test('whitespace-only returns empty', () {
      expect(abbreviateName('   '), '');
    });
  });

  group('initialsFromName', () {
    test('two-part name gives two uppercase initials', () {
      expect(initialsFromName('John Doe'), 'JD');
    });

    test('lowercases input are uppercased', () {
      expect(initialsFromName('ada lovelace'), 'AL');
    });

    test('three-part name uses first and last initials', () {
      expect(initialsFromName('John Quincy Adams'), 'JA');
    });

    test('single-word name yields one initial', () {
      expect(initialsFromName('Plato'), 'P');
    });

    test('empty string returns empty', () {
      expect(initialsFromName(''), '');
    });

    test('whitespace-only returns empty', () {
      expect(initialsFromName('   '), '');
    });
  });
}
