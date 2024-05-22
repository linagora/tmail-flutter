import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/domain/exceptions/notification_exceptions.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/toggle_app_notification_setting_cache_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/toggle_app_notification_setting_cache_interactor.dart';

import 'attempt_toggle_system_notification_setting_interactor_test.mocks.dart';

void main() {
  final notificationRepository = MockNotificationRepository();
  final toggleAppNotificationSettingCacheInteractor 
    = ToggleAppNotificationSettingCacheInteractor(notificationRepository);
  group('ToggleAppNotificationSettingCacheInteractor test:', () {
    test(
      'should emit expected state '
      'when repo return value',
    () {
      // arrange
      when(notificationRepository.toggleAppNotificationSetting(any))
        .thenAnswer((_) async {});

      // assert
      expect(
        toggleAppNotificationSettingCacheInteractor.execute(true),
        emitsInOrder([
          Right(TogglingAppNotificationSettingCache()),
          Right(ToggleAppNotificationSettingCacheSuccess()),
        ]),
      );
    });
    
    test(
      'should emit expected state '
      'when repo throws exception',
    () {
      // arrange
      when(notificationRepository.toggleAppNotificationSetting(any))
        .thenThrow(const NotificationPermissionDeniedException());

      // assert
      expect(
        toggleAppNotificationSettingCacheInteractor.execute(true),
        emitsInOrder([
          Right(TogglingAppNotificationSettingCache()),
          Left(ToggleAppNotificationSettingCacheFailure()),
        ]),
      );
    });
  });
}