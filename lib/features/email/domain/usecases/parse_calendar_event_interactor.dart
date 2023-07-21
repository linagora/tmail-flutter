import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/email/domain/repository/calendar_event_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_calendar_event_state.dart';

class ParseCalendarEventInteractor {
  final CalendarEventRepository _calendarEventRepository;

  ParseCalendarEventInteractor(this._calendarEventRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, Set<Id> blobIds) async* {
    try {
      yield Right(ParseCalendarEventLoading());
      final calendarEventList = await _calendarEventRepository.parse(accountId, blobIds);
      yield Right(ParseCalendarEventSuccess(calendarEventList));
    } catch (e) {
      yield Left(ParseCalendarEventFailure(e));
    }
  }
}