
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_accept_response.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';

abstract class CalendarEventRepository {
  Future<Map<Id, List<CalendarEvent>>> parse(AccountId accountId, Set<Id> blobIds);

  Future<List<EventAction>> getListEventAction(String emailContents);

  Future<CalendarEventAcceptResponse> acceptEventInvitation(AccountId accountId, Set<Id> blobIds);
}