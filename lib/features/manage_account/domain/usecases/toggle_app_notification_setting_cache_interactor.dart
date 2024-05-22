import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/notification_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/toggle_app_notification_setting_cache_state.dart';

class ToggleAppNotificationSettingCacheInteractor {

  final NotificationRepository _notificationRepository;

  ToggleAppNotificationSettingCacheInteractor(this._notificationRepository);

  Stream<Either<Failure, Success>> execute(bool isEnabled) async* {
    try {
      yield Right(TogglingAppNotificationSettingCache());
      await _notificationRepository.toggleAppNotificationSetting(isEnabled);
      yield Right(ToggleAppNotificationSettingCacheSuccess());
    } on Exception catch (_) {
      yield Left(ToggleAppNotificationSettingCacheFailure());
    }
  }
}