import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_replace_n_extensions.dart';

void main() {
  group('replaceFirstN', () {
    test('replace 2', () => expect('a-b-c'.replaceFirstN('-', '_', 2), 'a_b_c'));
    test('replace 1', () => expect('a-b-c'.replaceFirstN('-', '_', 1), 'a_b-c'));
    test(
      'pattern empty throws',
      () => expect(() => 'a'.replaceFirstN('', '_'), throwsArgumentError),
    );
  });
  group('replaceLast', () {
    test('basic', () => expect('a-b-c'.replaceLast('-', '_'), 'a-b_c'));
  });
}
