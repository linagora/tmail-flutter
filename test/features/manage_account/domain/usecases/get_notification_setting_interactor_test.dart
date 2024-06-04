import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/notification_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_notification_setting_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_notification_setting_interactor.dart';

import 'get_notification_setting_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<NotificationRepository>()])
void main() {
  final notificationRepository = MockNotificationRepository();
  final getNotificationSettingInteractor 
    = GetNotificationSettingInteractor(notificationRepository);

  final userName = UserName('value');

  group('GetNotificationSettingInteractor test:', () {
    test(
      'should emit expected state '
      'when repo return value',
    () {
      // arrange
      const notificationSettingEnabled = true;
      when(notificationRepository.getNotificationSetting(any))
        .thenAnswer((_) async => notificationSettingEnabled);

      // assert
      expect(
        getNotificationSettingInteractor.execute(userName),
        emitsInOrder([
          Right(GettingNotificationSetting()),
          Right(GetNotificationSettingSuccess(isEnabled: notificationSettingEnabled)),
        ]),
      );
    });
    
    test(
      'should emit expected state '
      'when repo throws exception',
    () {
      // arrange
      when(notificationRepository.getNotificationSetting(any)).thenThrow(Exception());

      // assert
      expect(
        getNotificationSettingInteractor.execute(userName),
        emitsInOrder([
          Right(GettingNotificationSetting()),
          Left(GetNotificationSettingFailure()),
        ]),
      );
    });
  });
}