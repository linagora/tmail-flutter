import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/calendar_url_template.dart';

extension CalendarUrlExtension on String? {
  String? resolveCalendarEventUrl(
    String? eventUid, {
    String? ownerEmail,
    String? domainName,
  }) {
    final template = this;
    if (template == null) return null;
    return CalendarUrlTemplate(template).resolveEventUrl(
      CalendarEventUrlRequest(
        eventUid: eventUid,
        ownerEmail: ownerEmail,
        domainName: domainName,
      ),
    );
  }
}
