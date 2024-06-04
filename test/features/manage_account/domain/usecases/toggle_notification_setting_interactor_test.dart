import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/notification_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/toggle_notification_setting_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/toggle_notification_setting_interactor.dart';

import 'toggle_notification_setting_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<NotificationRepository>()])
void main() {
  final notificationRepository = MockNotificationRepository();
  final toggleNotificationSettingInteractor 
    = ToggleNotificationSettingInteractor(notificationRepository);
  group('ToggleNotificationSettingInteractor test:', () {
    test(
      'should emit expected state '
      'when repo not throw exception',
    () {
      // arrange
      when(notificationRepository.toggleNotificationSetting())
        .thenAnswer((_) async => {});

      // assert
      expect(
        toggleNotificationSettingInteractor.execute(),
        emitsInOrder([
          Right(TogglingNotificationSetting()),
          Right(ToggleNotificationSettingSuccess()),
        ]),
      );
    });
    
    test(
      'should emit expected state '
      'when repo throws exception',
    () {
      // arrange
      when(notificationRepository.toggleNotificationSetting()).thenThrow(Exception());

      // assert
      expect(
        toggleNotificationSettingInteractor.execute(),
        emitsInOrder([
          Right(TogglingNotificationSetting()),
          Left(ToggleNotificationSettingFailure()),
        ]),
      );
    });
  });
}