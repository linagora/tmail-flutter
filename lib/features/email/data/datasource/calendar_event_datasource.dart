
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';

abstract class CalendarEventDataSource {
  Future<List<CalendarEvent>> parse(AccountId accountId, Set<Id> blobIds);
}