import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_string_extensions.dart';

void main() {
  group('commonPrefix', () {
    test('basic', () => expect(<String>['flower', 'flow', 'flight'].commonPrefix(), 'fl'));
    test('no common', () => expect(<String>['a', 'b'].commonPrefix(), ''));
    test('empty list', () => expect(<String>[].commonPrefix(), ''));
  });
  group('commonSuffix', () {
    test('basic', () => expect(<String>['ending', 'ding'].commonSuffix(), 'ding'));
    test('full suffix', () => expect(<String>['abc', 'bc'].commonSuffix(), 'bc'));
  });
}
