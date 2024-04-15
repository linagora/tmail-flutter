import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/calendar_event_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/domain/repository/calendar_event_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_calendar_event_state.dart';

class ParseCalendarEventInteractor {
  final CalendarEventRepository _calendarEventRepository;

  ParseCalendarEventInteractor(this._calendarEventRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    Set<Id> blobIds,
    String emailContents
  ) async* {
    try {
      yield Right(ParseCalendarEventLoading());

      final listResult = await Future.wait(
        [
          _calendarEventRepository.parse(accountId, blobIds),
          _calendarEventRepository.getListEventAction(emailContents),
        ],
        eagerError: true
      );

      final mapCalendarEvent = <Id, List<CalendarEvent>>{};
      final listEventAction = List<EventAction>.empty(growable: true);

      if (listResult[0] is Map<Id, List<CalendarEvent>>) {
        mapCalendarEvent.addAll(listResult[0] as Map<Id, List<CalendarEvent>>);
      }
      if (listResult[1] is List<EventAction>) {
        listEventAction.addAll(listResult[1] as List<EventAction>);
      }

      if (mapCalendarEvent.isNotEmpty) {
        yield Right(ParseCalendarEventSuccess(mapCalendarEvent, listEventAction));
      } else {
        yield Left(ParseCalendarEventFailure(NotFoundCalendarEventException()));
      }
    } catch (e) {
      yield Left(ParseCalendarEventFailure(e));
    }
  }
}