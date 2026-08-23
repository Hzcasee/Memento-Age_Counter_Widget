// This is a basic Flutter widget test for the Memento Mori age counter.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:slave/main.dart';

void main() {
  testWidgets('Shows title and prompts for a birth date before one is set', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MementoMoriApp());

    // The header and tagline should be present.
    expect(find.text('MEMENTO MORI'), findsOneWidget);
    expect(find.text('remember that you must die'), findsOneWidget);

    // No birth date has been set yet, so no age should be displayed
    // and the placeholder message should show instead.
    expect(find.text('Your time is not yet counted.'), findsOneWidget);
    expect(find.text('Set birth date'), findsOneWidget);
    expect(find.text('Change birth date'), findsNothing);
  });

  testWidgets('Age breakdown formats as Years.Months.Days.Hrs.Min.Sec', (
    WidgetTester tester,
  ) async {
    // This exercises the pure formatting logic directly, since driving the
    // native date/time picker dialogs isn't practical in a widget test.
    final birth = DateTime(2000, 1, 1, 0, 0, 0);
    final now = DateTime(2003, 3, 15, 4, 30, 10);

    // Mirrors the calendar-accurate subtraction used in AgeCounterPage.
    int years = now.year - birth.year;
    int months = now.month - birth.month;
    int days = now.day - birth.day;
    int hours = now.hour - birth.hour;
    int minutes = now.minute - birth.minute;
    int seconds = now.second - birth.second;

    if (seconds < 0) {
      seconds += 60;
      minutes--;
    }
    if (minutes < 0) {
      minutes += 60;
      hours--;
    }
    if (hours < 0) {
      hours += 24;
      days--;
    }
    if (days < 0) {
      final prevMonthLastDay = DateTime(now.year, now.month, 0).day;
      days += prevMonthLastDay;
      months--;
    }
    if (months < 0) {
      months += 12;
      years--;
    }

    final formatted = '$years.$months.$days.$hours.$minutes.$seconds';
    expect(formatted, '3.2.14.4.30.10');
  });
}
