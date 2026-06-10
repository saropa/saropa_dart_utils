import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/stream_combine_utils.dart';

Future<void> _pump() => Future<void>.delayed(Duration.zero);

void main() {
  group('zipStreams', () {
    test('pairs values by index', () async {
      final List<String> out = await zipStreams(
        Stream<int>.fromIterable(<int>[1, 2, 3]),
        Stream<String>.fromIterable(<String>['a', 'b', 'c']),
        (int n, String s) => '$n$s',
      ).toList();
      expect(out, <String>['1a', '2b', '3c']);
    });

    test('stops at the shorter stream and drops the trailing value', () async {
      final List<String> out = await zipStreams(
        Stream<int>.fromIterable(<int>[1, 2, 3]),
        Stream<String>.fromIterable(<String>['a', 'b']),
        (int n, String s) => '$n$s',
      ).toList();
      expect(out, <String>['1a', '2b']);
    });

    test('empty input yields nothing', () async {
      final List<String> out = await zipStreams(
        const Stream<int>.empty(),
        Stream<String>.fromIterable(<String>['a']),
        (int n, String s) => '$n$s',
      ).toList();
      expect(out, isEmpty);
    });
  });

  group('combineLatestStreams', () {
    test('emits latest pair on each event once both have a value', () async {
      final StreamController<int> a = StreamController<int>();
      final StreamController<String> b = StreamController<String>();
      final List<String> out = <String>[];
      final StreamSubscription<String> sub =
          combineLatestStreams(a.stream, b.stream, (int x, String y) => '$x$y').listen(out.add);

      a.add(1);
      await _pump(); // no emit: b unseen
      b.add('a');
      await _pump(); // 1a
      a.add(2);
      await _pump(); // 2a
      b.add('b');
      await _pump(); // 2b
      expect(out, <String>['1a', '2a', '2b']);

      await a.close();
      await b.close();
      await sub.cancel();
    });

    test('completes only after both sources complete', () async {
      final StreamController<int> a = StreamController<int>();
      final StreamController<int> b = StreamController<int>();
      bool done = false;
      final StreamSubscription<int> sub = combineLatestStreams(
        a.stream,
        b.stream,
        (int x, int y) => x + y,
      ).listen(null, onDone: () => done = true);

      await a.close();
      await _pump();
      expect(done, isFalse); // b still open
      await b.close();
      await _pump();
      expect(done, isTrue);
      await sub.cancel();
    });

    test('forwards errors from either source', () async {
      final StreamController<int> a = StreamController<int>();
      final StreamController<int> b = StreamController<int>();
      final List<Object> errors = <Object>[];
      final StreamSubscription<int> sub = combineLatestStreams(
        a.stream,
        b.stream,
        (int x, int y) => x + y,
      ).listen(null, onError: errors.add);

      a.addError(StateError('boom'));
      await _pump();
      expect(errors, hasLength(1));

      await a.close();
      await b.close();
      await sub.cancel();
    });
  });
}
