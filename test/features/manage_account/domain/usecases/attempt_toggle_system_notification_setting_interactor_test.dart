import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/domain/exceptions/notification_exceptions.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/notification_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/attempt_toggle_system_notification_setting_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/attempt_toggle_system_notification_setting_interactor.dart';

import 'attempt_toggle_system_notification_setting_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<NotificationRepository>()])
void main() {
  final notificationRepository = MockNotificationRepository();
  final attemptToggleSystemNotificationSettingInteractor 
    = AttemptToggleSystemNotificationSettingInteractor(notificationRepository);
  group('AttemptToggleSystemNotificationSettingInteractor test:', () {
    test(
      'should emit expected state '
      'when repo return value',
    () {
      // arrange
      const notificationSettingEnabled = true;
      when(notificationRepository.attemptToggleSystemNotificationSetting())
        .thenAnswer((_) async => notificationSettingEnabled);

      // assert
      expect(
        attemptToggleSystemNotificationSettingInteractor.execute(),
        emitsInOrder([
          Right(AttemptingToggleSystemNotificationSetting()),
          Right(AttemptToggleSystemNotificationSettingSuccess(notificationSettingEnabled)),
        ]),
      );
    });
    
    test(
      'should emit expected state '
      'when repo throws exception',
    () {
      // arrange
      when(notificationRepository.attemptToggleSystemNotificationSetting())
        .thenThrow(const NotificationPermissionDeniedException());

      // assert
      expect(
        attemptToggleSystemNotificationSettingInteractor.execute(),
        emitsInOrder([
          Right(AttemptingToggleSystemNotificationSetting()),
          Left(AttemptToggleSystemNotificationSettingFailure()),
        ]),
      );
    });
  });
}