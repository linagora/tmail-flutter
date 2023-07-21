
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:tmail_ui_user/features/email/data/datasource/calendar_event_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/repository/calendar_event_repository.dart';

class CalendarEventRepositoryImpl extends CalendarEventRepository {

  final CalendarEventDataSource _calendarEventDataSource;

  CalendarEventRepositoryImpl(this._calendarEventDataSource);

  @override
  Future<List<CalendarEvent>> parse(AccountId accountId, Set<Id> blobIds) {
    return _calendarEventDataSource.parse(accountId, blobIds);
  }
}