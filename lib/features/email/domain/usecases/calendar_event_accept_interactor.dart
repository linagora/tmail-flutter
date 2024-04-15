import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/email/domain/repository/calendar_event_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_accept_state.dart';

class AcceptCalendarEventInteractor {
  AcceptCalendarEventInteractor(this._calendarEventRepository);

  final CalendarEventRepository _calendarEventRepository;

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    Set<Id> blobIds
  ) async* {
    try {
      yield Right(CalendarEventAccepting());
      final result = await _calendarEventRepository.acceptEventInvitation(accountId, blobIds);
      yield Right(CalendarEventAccepted(result));
    } catch (e) {
      yield Left(CalendarEventAcceptFailure(exception: e));
    }
  }
}