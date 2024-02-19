import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_new_receive_email_from_notification_state.dart';

class GetNewReceiveEmailFromNotificationInteractor {
  final FCMRepository _fcmRepository;
  final EmailRepository _emailRepository;

  GetNewReceiveEmailFromNotificationInteractor(this._fcmRepository, this._emailRepository);

  Stream<Either<Failure, Success>> execute({
    required Session session,
    required AccountId accountId,
    required UserName userName,
    required jmap.State newState
  }) async* {
    try {
      yield Right<Failure, Success>(GetNewReceiveEmailFromNotificationLoading());

      final currentState = await _emailRepository.getEmailState(session, accountId);
      if (currentState != null && currentState != newState) {
        final listEmailIds = await _fcmRepository.getNewReceiveEmailFromNotification(
          session,
          accountId,
          currentState);
        log('GetNewReceiveEmailFromNotificationInteractor::execute: listEmailIds = $listEmailIds');
        yield Right<Failure, Success>(GetNewReceiveEmailFromNotificationSuccess(accountId, session, listEmailIds));
      } else {
        yield Left<Failure, Success>(GetNewReceiveEmailFromNotificationFailure(EmailStateNoChangeException()));
      }
    } catch (e) {
      yield Left<Failure, Success>(GetNewReceiveEmailFromNotificationFailure(e));
    }
  }
}