import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_email_changes_to_remove_notification_state.dart';

class GetEmailChangesToRemoveNotificationInteractor {
  final FCMRepository _fcmRepository;
  final EmailRepository _emailRepository;

  GetEmailChangesToRemoveNotificationInteractor(this._fcmRepository, this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    jmap.State newState,
    {
      Properties? propertiesCreated,
      Properties? propertiesUpdated
    }
  ) async* {
    try {
      yield Right<Failure, Success>(GetEmailChangesToRemoveNotificationLoading());

      final currentState = await _emailRepository.getEmailState(session, accountId);
      log('GetEmailChangesToRemoveNotificationInteractor::execute():currentState: $currentState');
      if (currentState != null) {
        final emailIds = await _fcmRepository.getEmailChangesToRemoveNotification(
          session,
          accountId,
          currentState,
          propertiesCreated: propertiesCreated,
          propertiesUpdated: propertiesUpdated);
        yield Right<Failure, Success>(GetEmailChangesToRemoveNotificationSuccess(session.username, emailIds));
      } else {
        yield Left<Failure, Success>(GetEmailChangesToRemoveNotificationFailure(NotFoundEmailStateException()));
      }
    } catch (e) {
      yield Left<Failure, Success>(GetEmailChangesToRemoveNotificationFailure(e));
    }
  }
}