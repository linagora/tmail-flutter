import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/notification_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/attempt_toggle_system_notification_setting_state.dart';

class AttemptToggleSystemNotificationSettingInteractor {
  final NotificationRepository _notificationRepository;
  
  AttemptToggleSystemNotificationSettingInteractor(this._notificationRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right(AttemptingToggleSystemNotificationSetting());
      final isEnabled = await _notificationRepository.attemptToggleSystemNotificationSetting();
      yield Right(AttemptToggleSystemNotificationSettingSuccess(isEnabled));
    } on Exception catch (_) {
      yield Left(AttemptToggleSystemNotificationSettingFailure());
    }
  }
}