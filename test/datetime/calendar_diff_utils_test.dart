import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/calendar_diff_utils.dart';

void main() {
  group('diffCalendars', () {
    CalendarEvent event(String id, int hour, [String title = 'Meeting']) => CalendarEvent(
      id: id,
      start: DateTime(2026, 6, 12, hour),
      end: DateTime(2026, 6, 12, hour + 1),
      title: title,
    );

    test('should classify an added event', () {
      final CalendarDiff d = diffCalendars(
        <CalendarEvent>[event('a', 9)],
        <CalendarEvent>[event('a', 9), event('b', 10)],
      );

      expect(d.added.map((CalendarEvent e) => e.id), equals(<String>['b']));
      expect(d.removed, isEmpty);
      expect(d.changed, isEmpty);
    });

    test('should classify a removed event', () {
      final CalendarDiff d = diffCalendars(
        <CalendarEvent>[event('a', 9), event('b', 10)],
        <CalendarEvent>[event('a', 9)],
      );

      expect(d.removed.map((CalendarEvent e) => e.id), equals(<String>['b']));
      expect(d.added, isEmpty);
    });

    test('should classify a changed event by time', () {
      final CalendarDiff d = diffCalendars(
        <CalendarEvent>[event('a', 9)],
        <CalendarEvent>[event('a', 11)], // moved two hours later
      );

      expect(d.changed.length, equals(1));
      expect(d.changed.first.before.start.hour, equals(9));
      expect(d.changed.first.after.start.hour, equals(11));
      expect(d.added, isEmpty);
      expect(d.removed, isEmpty);
    });

    test('should classify a changed event by title', () {
      final CalendarDiff d = diffCalendars(
        <CalendarEvent>[event('a', 9, 'Standup')],
        <CalendarEvent>[event('a', 9, 'Retro')],
      );

      expect(d.changed.length, equals(1));
      expect(d.changed.first.after.title, equals('Retro'));
    });

    test('should report no change for identical content', () {
      final CalendarDiff d = diffCalendars(
        <CalendarEvent>[event('a', 9)],
        <CalendarEvent>[event('a', 9)],
      );

      expect(d.added, isEmpty);
      expect(d.removed, isEmpty);
      expect(d.changed, isEmpty);
    });

    test('should handle empty snapshots on either side', () {
      final CalendarDiff added = diffCalendars(<CalendarEvent>[], <CalendarEvent>[event('a', 9)]);
      final CalendarDiff removed = diffCalendars(<CalendarEvent>[event('a', 9)], <CalendarEvent>[]);

      expect(added.added.length, equals(1));
      expect(removed.removed.length, equals(1));
    });

    test('should classify a mixed diff', () {
      final CalendarDiff d = diffCalendars(
        <CalendarEvent>[event('keep', 8), event('move', 9), event('gone', 10)],
        <CalendarEvent>[event('keep', 8), event('move', 12), event('new', 14)],
      );

      expect(d.added.map((CalendarEvent e) => e.id), equals(<String>['new']));
      expect(d.removed.map((CalendarEvent e) => e.id), equals(<String>['gone']));
      expect(d.changed.map((CalendarChange c) => c.after.id), equals(<String>['move']));
    });

    test('sameContentAs should ignore id but compare start/end/title', () {
      final CalendarEvent a = event('one', 9);
      final CalendarEvent b = event('two', 9); // same time/title, different id

      expect(a.sameContentAs(b), isTrue);
    });
  });
}
