import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/version_compare_utils.dart';

void main() {
  group('compareVersions', () {
    test('equal versions', () => expect(compareVersions('1.2.3', '1.2.3'), 0));
    test('lower major negative', () => expect(compareVersions('1.0.0', '2.0.0') < 0, isTrue));
    test('higher minor positive', () => expect(compareVersions('1.2.0', '1.1.0') > 0, isTrue));
    test('higher patch positive', () => expect(compareVersions('1.0.2', '1.0.1') > 0, isTrue));
    test('numeric not lexical (10 > 9)', () => expect(compareVersions('1.10.0', '1.9.0') > 0, isTrue));
    test('missing trailing segment treated as zero', () {
      expect(compareVersions('1.2', '1.2.0'), 0);
    });
    test('extra non-zero segment is greater', () {
      expect(compareVersions('1.2.0.1', '1.2.0') > 0, isTrue);
    });
    test('non-numeric segment treated as zero', () {
      expect(compareVersions('1.x.3', '1.0.3'), 0);
    });
    test('single number versions', () => expect(compareVersions('2', '1') > 0, isTrue));
  });
}
