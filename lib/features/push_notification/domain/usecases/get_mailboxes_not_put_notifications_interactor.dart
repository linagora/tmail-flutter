import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_mailboxes_not_put_notifications_state.dart';

class GetMailboxesNotPutNotificationsInteractor {
  final FCMRepository _fcmRepository;

  GetMailboxesNotPutNotificationsInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId) async* {
    try {
      yield Right<Failure, Success>(GetMailboxesNotPutNotificationsLoading());
      final mailboxes = await _fcmRepository.getMailboxesNotPutNotifications(session, accountId);
      yield Right<Failure, Success>(GetMailboxesNotPutNotificationsSuccess(mailboxes, session.username));
    } catch (e) {
      yield Left<Failure, Success>(GetMailboxesNotPutNotificationsFailure(e, session.username));
    }
  }
}