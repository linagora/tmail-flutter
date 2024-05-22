import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/notification_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/notification_repository_impl.dart';

import 'notification_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<NotificationDataSource>()])
void main() {
  final notificationDataSource = MockNotificationDataSource();
  final notificationRepositoryImpl = NotificationRepositoryImpl(notificationDataSource);

  group('notification repository impl test:', () {
    test(
      'should call getAppNotificationSetting '
      'when getAppNotificationSetting in datasource is called',
    () {
      // arrange
      when(notificationDataSource.getAppNotificationSetting())
        .thenAnswer((_) async => true);

      // act
      notificationRepositoryImpl.getAppNotificationSetting();

      // assert
      verify(notificationDataSource.getAppNotificationSetting()).called(1);
    });

    test(
      'should call toggleAppNotificationSetting '
      'when toggleAppNotificationSetting in datasource is called',
    () {
      // arrange
      const isNotificationSettingEnabled = true;
      when(notificationDataSource.toggleAppNotificationSetting(any))
        .thenAnswer((_) async => true);

      // act
      notificationRepositoryImpl.toggleAppNotificationSetting(isNotificationSettingEnabled);

      // assert
      verify(
        notificationDataSource.toggleAppNotificationSetting(isNotificationSettingEnabled))
          .called(1);
    });

    test(
      'should call attemptToggleSystemNotificationSetting '
      'when attemptToggleSystemNotificationSetting in datasource is called',
    () {
      // arrange
      when(notificationDataSource.attemptToggleSystemNotificationSetting())
        .thenAnswer((_) async => true);

      // act
      notificationRepositoryImpl.attemptToggleSystemNotificationSetting();

      // assert
      verify(notificationDataSource.attemptToggleSystemNotificationSetting()).called(1);
    });
  });
}