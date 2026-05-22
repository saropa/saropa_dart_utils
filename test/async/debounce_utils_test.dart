import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/debounce_utils.dart';

void main() {
  group('debounce', () {
    test('invokes fn only once after the quiet period', () {
      fakeAsync((FakeAsync async) {
        int calls = 0;
        final VoidCallback fn = debounce(() => calls++, const Duration(milliseconds: 100));

        fn();
        fn();
        fn();
        // No call yet; the timer keeps resetting.
        async.elapse(const Duration(milliseconds: 50));
        expect(calls, 0);

        // After the full delay since the last call, fn fires once.
        async.elapse(const Duration(milliseconds: 100));
        expect(calls, 1);
      });
    });

    test('a single call fires after the delay', () {
      fakeAsync((FakeAsync async) {
        int calls = 0;
        final VoidCallback fn = debounce(() => calls++, const Duration(milliseconds: 30));
        fn();
        expect(calls, 0);
        async.elapse(const Duration(milliseconds: 30));
        expect(calls, 1);
      });
    });

    test('calls separated by more than the delay each fire', () {
      fakeAsync((FakeAsync async) {
        int calls = 0;
        final VoidCallback fn = debounce(() => calls++, const Duration(milliseconds: 20));
        fn();
        async.elapse(const Duration(milliseconds: 25));
        fn();
        async.elapse(const Duration(milliseconds: 25));
        expect(calls, 2);
      });
    });
  });
}
