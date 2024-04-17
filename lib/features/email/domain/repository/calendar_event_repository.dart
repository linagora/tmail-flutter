
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_accept_response.dart';
import 'package:tmail_ui_user/features/email/presentation/model/blob_calendar_event.dart';

abstract class CalendarEventRepository {
  Future<List<BlobCalendarEvent>> parse(AccountId accountId, Set<Id> blobIds);

  Future<CalendarEventAcceptResponse> acceptEventInvitation(AccountId accountId, Set<Id> blobIds);
}