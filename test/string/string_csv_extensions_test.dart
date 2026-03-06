import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_csv_extensions.dart';

void main() {
  test('wrapCsvQuotes', () {
    expect('normal'.wrapCsvQuotes(), '"normal"');
    expect('a"b'.wrapCsvQuotes(), '"a""b"');
  });
}
