import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_method.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';

extension ListEventActionsExtension on List<EventActionType> {
  List<EventActionType> validActionsOfEventMethod(EventMethod? eventMethod) {
    return where((action) {
      if (eventMethod != EventMethod.counter) {
        return action != EventActionType.acceptCounter;
      }

      return action == EventActionType.acceptCounter
        || action == EventActionType.mailToAttendees;
    }).toList();
  }
}