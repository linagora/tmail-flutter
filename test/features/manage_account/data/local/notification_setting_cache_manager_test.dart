import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/notification_setting_cache_manager.dart';

import 'notification_setting_cache_manager_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SharedPreferences>()])
void main() {
  final sharedPreferences = MockSharedPreferences();
  final notificationSettingCacheManager = NotificationSettingCacheManager(sharedPreferences);
  group('notification setting cache manager test:', () {
    test(
      'should call setBool '
      'when persistAppNotificationSettingCache is called',
    () {
      // arrange
      when(sharedPreferences.setBool(any, any)).thenAnswer((_) async => true);

      // act
      notificationSettingCacheManager.persistAppNotificationSettingCache(true);

      // assert
      verify(sharedPreferences.setBool(
        NotificationSettingCacheManager.keyAppNotificationSettingCode,
        true));
    });

    test(
      'should call getBool '
      'when getAppNotificationSettingCache is called',
    () {
      // arrange
      when(sharedPreferences.getBool(any)).thenReturn(true);

      // act
      notificationSettingCacheManager.getAppNotificationSettingCache();

      // assert
      verify(sharedPreferences.getBool(
        NotificationSettingCacheManager.keyAppNotificationSettingCode));
    });

    test(
      'should call remove '
      'when removeAppNotificationSettingCache is called',
    () {
      // arrange
      when(sharedPreferences.remove(any)).thenAnswer((_) async => true);

      // act
      notificationSettingCacheManager.removeAppNotificationSettingCache();

      // assert
      verify(sharedPreferences.remove(
        NotificationSettingCacheManager.keyAppNotificationSettingCode));
    });
  });
}