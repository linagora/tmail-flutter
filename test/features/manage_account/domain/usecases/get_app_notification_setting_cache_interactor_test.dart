import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/domain/exceptions/notification_exceptions.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_app_notification_setting_cache_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_app_notification_setting_cache_interactor.dart';

import 'attempt_toggle_system_notification_setting_interactor_test.mocks.dart';

void main() {
  final notificationRepository = MockNotificationRepository();
  final getAppNotificationSettingCacheInteractor 
    = GetAppNotificationSettingCacheInteractor(notificationRepository);
  group('GetAppNotificationSettingCacheInteractor test:', () {
    test(
      'should emit expected state '
      'when repo return value',
    () {
      // arrange
      const notificationSettingEnabled = true;
      when(notificationRepository.getAppNotificationSetting())
        .thenAnswer((_) async => notificationSettingEnabled);

      // assert
      expect(
        getAppNotificationSettingCacheInteractor.execute(),
        emitsInOrder([
          Right(GettingAppNotificationSettingCache()),
          Right(GetAppNotificationSettingCacheSuccess(notificationSettingEnabled)),
        ]),
      );
    });
    
    test(
      'should emit expected state '
      'when repo throws exception',
    () {
      // arrange
      when(notificationRepository.getAppNotificationSetting())
        .thenThrow(const NotificationPermissionDeniedException());

      // assert
      expect(
        getAppNotificationSettingCacheInteractor.execute(),
        emitsInOrder([
          Right(GettingAppNotificationSettingCache()),
          Left(GetAppNotificationSettingCacheFailure()),
        ]),
      );
    });
  });
}