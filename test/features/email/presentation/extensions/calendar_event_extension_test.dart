import 'package:date_format/date_format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:date_format/date_format.dart' as date_format;
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_event_extension.dart';

void main() {
  group('CalendarEventExtension::formatDateTime test', () {
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

  group('CalendarEventExtension::getDateTimeEvent test', () {
    test('dateTimeEventAsString should return string with format start date - end date (timezone offset) and date formatted as DD, MM dd, YYYY for all-day event for many days', () {
      const expectedFormattedDateString = 'Sunday, October 10, 2021 - Sunday, October 24, 2021 (GMT+0)';

      final startDate = DateTime(2021, 10, 10, 00, 00, 00, 00, 00);
      final endDate = DateTime(2021, 10, 25, 00, 00, 00, 00, 00);

      final calendarEvent = CalendarEvent(
        startDate: startDate,
        endDate: endDate,
        startUtcDate: UTCDate(startDate),
        endUtcDate: UTCDate(endDate),
      );

      final formattedDateString = calendarEvent.getDateTimeEvent(
        timeZone: 'GMT+0',
        dateLocale: const EnglishDateLocale()
      );

      expect(formattedDateString, expectedFormattedDateString);
    });

    test('dateTimeEventAsString should return string with format date (timezone offset) and date formatted as DD, MM dd, YYYY for all-day event for one day', () {
      const expectedFormattedDateString = 'Sunday, October 10, 2021 (GMT+0)';

      final startDate = DateTime(2021, 10, 10, 00, 00, 00, 00, 00);
      final endDate = DateTime(2021, 10, 11, 00, 00, 00, 00, 00);

      final calendarEvent = CalendarEvent(
        startDate: startDate,
        endDate: endDate,
        startUtcDate: UTCDate(startDate),
        endUtcDate: UTCDate(endDate),
      );

      final formattedDateString = calendarEvent.getDateTimeEvent(
        timeZone: 'GMT+0',
        dateLocale: const EnglishDateLocale()
      );

      expect(formattedDateString, expectedFormattedDateString);
    });
  });
}