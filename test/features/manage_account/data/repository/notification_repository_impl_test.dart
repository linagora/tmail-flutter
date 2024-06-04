import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/notification_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/notification_repository_impl.dart';

import 'notification_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<NotificationDataSource>()])
void main() {
  final notificationDataSource = MockNotificationDataSource();
  final notificationRepositoryImpl = NotificationRepositoryImpl(notificationDataSource);

  final userName = UserName('value');

  group('notification repository impl test:', () {
    test(
      'should call getNotificationSetting '
      'when getNotificationSetting in datasource is called',
    () {
      // arrange
      when(notificationDataSource.getNotificationSetting(any))
        .thenAnswer((_) async => true);

      // act
      notificationRepositoryImpl.getNotificationSetting(userName);

      // assert
      verify(notificationDataSource.getNotificationSetting(userName)).called(1);
    });

    test(
      'should call toggleNotificationSetting '
      'when toggleNotificationSetting in datasource is called',
    () {
      // arrange
      when(notificationDataSource.toggleNotificationSetting())
        .thenAnswer((_) async => true);

      // act
      notificationRepositoryImpl.toggleNotificationSetting();

      // assert
      verify(notificationDataSource.toggleNotificationSetting()).called(1);
    });
  });
}