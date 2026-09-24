import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/extensions/calendar_url_extension.dart';

void main() {
  group('CalendarUrlExtension::resolveCalendarEventUrl', () {
    test('SHOULD return null WHEN the calendar URL template is missing', () {
      const String? template = null;

      expect(template.resolveCalendarEventUrl('event-42'), isNull);
    });

    test('SHOULD delegate every input to CalendarUrlTemplate', () {
      expect(
        'https://{localPart}.{domainName}/events/{UID}'
            .resolveCalendarEventUrl(
              'event/42',
              ownerEmail: 'john.doe@example.com',
              domainName: 'tenant.example.com',
            )
            ?.toString(),
        'https://johndoe.tenant.example.com/events/event%2F42',
      );
    });
  });
}
