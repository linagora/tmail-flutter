import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/store_event_attendance_status_state.dart';

class StoreEventAttendanceStatusInteractor {
  final EmailRepository _emailRepository;

  StoreEventAttendanceStatusInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    EmailId emailId,
    EventActionType eventActionType
  ) async* {
    try {
      yield Right(StoreEventAttendanceStatusLoading());

      await _emailRepository.storeEventAttendanceStatus(
        session,
        accountId,
        emailId,
        eventActionType);

      yield Right(StoreEventAttendanceStatusSuccess(eventActionType));
    } catch (e) {
      yield Left(StoreEventAttendanceStatusFailure(exception: e));
    }
  }
}