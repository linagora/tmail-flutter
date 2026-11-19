import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/delegated_notification_baseline.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/store_delegated_notification_baselines_state.dart';

class StoreDelegatedNotificationBaselinesInteractor {
  final FCMRepository _fcmRepository;

  StoreDelegatedNotificationBaselinesInteractor(this._fcmRepository);

  /// [ownerNames] lists the delegated mailboxes to notify for, an empty map stops them all.
  /// A mailbox that already has a cursor keeps it, the pushes may not have moved it yet.
  Stream<Either<Failure, Success>> execute(Session session, Map<AccountId, String> ownerNames) async* {
    try {
      yield Right(StoreDelegatedNotificationBaselinesLoading());
      final withCursor = await _fcmRepository.getDelegatedAccountIdsWithNotificationCursor(session);
      final baselines = <DelegatedNotificationBaseline>[];
      var hasUnreadState = false;
      for (final owner in ownerNames.entries) {
        if (withCursor.contains(owner.key)) {
          baselines.add(DelegatedNotificationBaseline(accountId: owner.key, ownerName: owner.value));
          continue;
        }
        final state = await _emailStateOf(session, owner.key);
        if (state == null) {
          hasUnreadState = true;
          continue;
        }
        baselines.add(DelegatedNotificationBaseline(accountId: owner.key, state: state, ownerName: owner.value));
      }
      await _fcmRepository.storeDelegatedNotificationBaselines(session, baselines);
      // The other mailboxes are stored, the failure lets the caller retry the missing ones.
      yield hasUnreadState
          ? Left(StoreDelegatedNotificationBaselinesFailure(const NotFoundEmailStateException()))
          : Right(StoreDelegatedNotificationBaselinesSuccess());
    } catch (e) {
      yield Left(StoreDelegatedNotificationBaselinesFailure(e));
    }
  }

  /// One unreachable mailbox must not stop the others from notifying.
  Future<jmap.State?> _emailStateOf(Session session, AccountId accountId) async {
    try {
      return await _fcmRepository.getEmailState(session, accountId);
    } catch (e) {
      logWarning('StoreDelegatedNotificationBaselinesInteractor::_emailStateOf: $e');
      return null;
    }
  }
}
