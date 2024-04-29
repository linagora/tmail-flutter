
import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_accept_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_maybe_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_reject_response.dart';
import 'package:tmail_ui_user/features/email/data/datasource/calendar_event_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/repository/calendar_event_repository.dart';
import 'package:tmail_ui_user/features/email/presentation/model/blob_calendar_event.dart';

class CalendarEventRepositoryImpl extends CalendarEventRepository {

  final Map<DataSourceType, CalendarEventDataSource> _calendarEventDataSource;

  CalendarEventRepositoryImpl(this._calendarEventDataSource);

  @override
  Future<List<BlobCalendarEvent>> parse(AccountId accountId, Set<Id> blobIds) {
    return _calendarEventDataSource[DataSourceType.network]!.parse(accountId, blobIds);
  }

  @override
  Future<CalendarEventAcceptResponse> acceptEventInvitation(AccountId accountId, Set<Id> blobIds) {
    return _calendarEventDataSource[DataSourceType.network]!.acceptEventInvitation(accountId, blobIds);
  }

  @override
  Future<CalendarEventMaybeResponse> maybeEventInvitation(AccountId accountId, Set<Id> blobIds) {
    return _calendarEventDataSource[DataSourceType.network]!.maybeEventInvitation(accountId, blobIds);
  }
  
  @override
  Future<CalendarEventRejectResponse> rejectEventInvitation(AccountId accountId, Set<Id> blobIds) {
    return _calendarEventDataSource[DataSourceType.network]!.rejectEventInvitation(accountId, blobIds);
  }
}