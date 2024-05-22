import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/notification_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_app_notification_setting_cache_state.dart';

class GetAppNotificationSettingCacheInteractor {
  final NotificationRepository _notificationRepository;

  GetAppNotificationSettingCacheInteractor(this._notificationRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right(GettingAppNotificationSettingCache());
      final isEnabled = await _notificationRepository.getAppNotificationSetting();
      yield Right(GetAppNotificationSettingCacheSuccess(isEnabled));
    } on Exception catch (_) {
      yield Left(GetAppNotificationSettingCacheFailure());
    }
  }
}