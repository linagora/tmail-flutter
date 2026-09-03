
import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/video_conference_section_utils.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_accept_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_maybe_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_reject_response.dart';
import 'package:tmail_ui_user/features/email/data/datasource/calendar_event_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/repository/calendar_event_repository.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_event_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/blob_calendar_event.dart';

class CalendarEventRepositoryImpl extends CalendarEventRepository {

  final Map<DataSourceType, CalendarEventDataSource> _calendarEventDataSource;
  final HtmlDataSource _htmlDataSource;

  CalendarEventRepositoryImpl(this._calendarEventDataSource, this._htmlDataSource);

  @override
  Future<List<BlobCalendarEvent>> parse(AccountId accountId, Set<Id> blobIds) {
    return _calendarEventDataSource[DataSourceType.network]!.parse(accountId, blobIds);
  }

  @override
  Future<CalendarEventAcceptResponse> acceptEventInvitation(
    AccountId accountId,
    Set<Id> blobIds,
    String? language
  ) {
    return _calendarEventDataSource[DataSourceType.network]!
      .acceptEventInvitation(accountId, blobIds, language);
  }

  @override
  Future<CalendarEventMaybeResponse> maybeEventInvitation(
    AccountId accountId,
    Set<Id> blobIds,
    String? language
  ) {
    return _calendarEventDataSource[DataSourceType.network]!
      .maybeEventInvitation(accountId, blobIds, language);
  }
  
  @override
  Future<CalendarEventRejectResponse> rejectEventInvitation(
    AccountId accountId,
    Set<Id> blobIds,
    String? language
  ) {
    return _calendarEventDataSource[DataSourceType.network]!
      .rejectEventInvitation(accountId, blobIds, language);
  }

  /// [sanitizeDescription] cleans the raw ICS description before it is
  /// rendered. It defaults to dropping the "do not edit" section Twake Calendar
  /// appends to the description, because the visio link it holds is already
  /// rendered by the invitation email body.
  @override
  Future<List<BlobCalendarEvent>> transformCalendarEventDescription(
    List<BlobCalendarEvent> blobCalendarEvents,
    TransformConfiguration transformConfiguration, {
    String Function(String) sanitizeDescription = VideoConferenceSectionUtils.removeSection,
  }) async {
    return Future.wait(blobCalendarEvents.map((blobCalendarEvent) async {
      return BlobCalendarEvent(
        blobId: blobCalendarEvent.blobId,
        calendarEventList: await Future.wait(blobCalendarEvent.calendarEventList.map((calendarEvent) {
          return _transformCalendarEventDescription(
            calendarEvent,
            transformConfiguration,
            sanitizeDescription,
          );
        })),
        isFree: blobCalendarEvent.isFree,
        attendanceStatus: blobCalendarEvent.attendanceStatus,
      );
    }));
  }

  Future<CalendarEvent> _transformCalendarEventDescription(
    CalendarEvent calendarEvent,
    TransformConfiguration transformConfiguration,
    String Function(String) sanitizeDescription,
  ) async {
    final description = calendarEvent.description == null
        ? null
        : sanitizeDescription(calendarEvent.description!);

    return calendarEvent.copyWith(
      description: description?.trim().isNotEmpty == true
        ? await _htmlDataSource.transformHtmlEmailContent(
            description!,
            transformConfiguration,
          )
        : description,
    );
  }
  
  @override
  Future<CalendarEventAcceptResponse> acceptCounterEvent(
    AccountId accountId,
    Set<Id> blobIds,
  ) {
    return _calendarEventDataSource[DataSourceType.network]!
      .acceptCounterEvent(accountId, blobIds);
  }
}