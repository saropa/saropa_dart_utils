import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_rotate_extensions.dart';

void main() {
  test('rotate left', () {
    expect(<int>[1, 2, 3, 4].rotate(1), [2, 3, 4, 1]);
  });
  test('rotate right', () {
    expect(<int>[1, 2, 3, 4].rotate(-1), [4, 1, 2, 3]);
  });
}
