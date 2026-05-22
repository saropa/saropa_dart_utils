import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/heartbeat_utils.dart';

void main() {
  group('HeartbeatUtils', () {
    test('exposes interval and onBeat', () {
      void beat() {}
      final HeartbeatUtils hb = HeartbeatUtils(const Duration(seconds: 1), beat);
      expect(hb.interval, const Duration(seconds: 1));
      expect(hb.onBeat, same(beat));
    });

    test('does not beat before start is called', () {
      fakeAsync((FakeAsync async) {
        int beats = 0;
        HeartbeatUtils(const Duration(milliseconds: 10), () => beats++);
        async.elapse(const Duration(milliseconds: 50));
        expect(beats, 0);
      });
    });

    test('beats every interval after start', () {
      fakeAsync((FakeAsync async) {
        int beats = 0;
        final HeartbeatUtils hb = HeartbeatUtils(const Duration(milliseconds: 10), () => beats++)
          ..start();
        async.elapse(const Duration(milliseconds: 35));
        expect(beats, 3); // beats at 10, 20, 30
        hb.stop();
      });
    });

    test('stop halts further beats', () {
      fakeAsync((FakeAsync async) {
        int beats = 0;
        final HeartbeatUtils hb = HeartbeatUtils(const Duration(milliseconds: 10), () => beats++)
          ..start();
        async.elapse(const Duration(milliseconds: 25));
        expect(beats, 2);
        hb.stop();
        async.elapse(const Duration(milliseconds: 50));
        expect(beats, 2); // no new beats after stop
      });
    });

    test('dispose stops the heartbeat', () {
      fakeAsync((FakeAsync async) {
        int beats = 0;
        final HeartbeatUtils hb = HeartbeatUtils(const Duration(milliseconds: 10), () => beats++)
          ..start();
        async.elapse(const Duration(milliseconds: 15));
        hb.dispose();
        async.elapse(const Duration(milliseconds: 50));
        expect(beats, 1);
      });
    });

    test('start cancels a prior timer (no double-rate beats)', () {
      fakeAsync((FakeAsync async) {
        int beats = 0;
        final HeartbeatUtils hb = HeartbeatUtils(const Duration(milliseconds: 10), () => beats++)
          ..start()
          ..start(); // second start must replace, not stack
        async.elapse(const Duration(milliseconds: 30));
        expect(beats, 3);
        hb.stop();
      });
    });

    test('toString reports interval and active flag', () {
      final HeartbeatUtils hb = HeartbeatUtils(const Duration(milliseconds: 5), () {});
      expect(hb.toString(), contains('active: false'));
      fakeAsync((FakeAsync async) {
        hb.start();
        expect(hb.toString(), contains('active: true'));
        hb.stop();
      });
    });
  });
}
