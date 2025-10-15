import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_event_extension.dart';

extension ValidateDisplayFreeBusyMessageExtension on SingleEmailController {
  bool isFreeBusyEnabled(List<String> listEmailAddressSender) {
    return !isCalendarEventFree &&
        calendarEvent?.isIMIPResponsesAvailable(listEmailAddressSender) != true;
  }
}
