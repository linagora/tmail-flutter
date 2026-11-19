import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/delegated_notification_baseline.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/store_delegated_notification_baselines_state.dart';

class StoreDelegatedNotificationBaselinesInteractor {
  final FCMRepository _fcmRepository;

  StoreDelegatedNotificationBaselinesInteractor(this._fcmRepository);

  /// [ownerNames] lists the delegated mailboxes to notify for, an empty map stops them all.
  Stream<Either<Failure, Success>> execute(Session session, Map<AccountId, String> ownerNames) async* {
    try {
      yield Right(StoreDelegatedNotificationBaselinesLoading());
      final baselines = <DelegatedNotificationBaseline>[];
      for (final owner in ownerNames.entries) {
        final baseline = await _baselineOf(session, owner.key, owner.value);
        if (baseline != null) baselines.add(baseline);
      }
      await _fcmRepository.storeDelegatedNotificationBaselines(session, baselines);
      yield Right(StoreDelegatedNotificationBaselinesSuccess());
    } catch (e) {
      yield Left(StoreDelegatedNotificationBaselinesFailure(e));
    }
  }

  /// One unreachable mailbox must not stop the others from notifying.
  Future<DelegatedNotificationBaseline?> _baselineOf(Session session, AccountId accountId, String ownerName) async {
    try {
      final state = await _fcmRepository.getEmailState(session, accountId);
      if (state == null) return null;
      return DelegatedNotificationBaseline(accountId: accountId, state: state, ownerName: ownerName);
    } catch (e) {
      logWarning('StoreDelegatedNotificationBaselinesInteractor::_baselineOf: $e');
      return null;
    }
  }
}
