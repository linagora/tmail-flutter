import 'package:flutter_test/flutter_test.dart';
import 'package:date_format/date_format.dart' as date_format;
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_event_extension.dart';

void main() {
  group('calendar event extension test', () {
    final dateTime = DateTime(2021, 10, 10, 10, 30, 00, 00, 00);

    const locale = date_format.EnglishDateLocale();
    const expectedFormattedDateTime = 'Sunday, October 10, 2021 10:30 AM';
    const expectedFormattedTime = '10:30 AM';

    test('formatDateTime should return a string with format DD, MM dd, yyy hh:nn am', () {
      final calendarEvent = CalendarEvent(startDate: dateTime);

      final formattedDateTime = calendarEvent.formatDateTime(locale, dateTime);

      expect(formattedDateTime, expectedFormattedDateTime);
    });

    test('formatTime should return a string with format hh:nn', () {
      final calendarEvent = CalendarEvent(startDate: dateTime);

      final formattedTime = calendarEvent.formatTime(locale, dateTime);

      expect(formattedTime, expectedFormattedTime);
    });
  });
}