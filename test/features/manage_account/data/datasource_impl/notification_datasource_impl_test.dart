import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/notification_datasource_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/notification_setting_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/exceptions/notification_exceptions.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

import 'notification_datasource_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<NotificationSettingCacheManager>(),
  MockSpec<ExceptionThrower>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  final notificationSettingCacheManager = MockNotificationSettingCacheManager();
  final exceptionThrower = MockExceptionThrower();
  final notificationDatasourceImpl = NotificationDataSourceImpl(
    notificationSettingCacheManager,
    exceptionThrower);

  void setMockNotificationPermission({
    required PermissionStatus currentStatus,
    PermissionStatus? requestedStatus,
    VoidCallback? openAppSettingsCallback,
  }) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (message) async {
          if (message.method == 'checkPermissionStatus') {
            return currentStatus.index;
          } else if (message.method == 'requestPermissions') {
            assert(
              requestedStatus != null,
              'mock requested status must not be null '
              'when requesting permission');

            return {Permission.notification.value: requestedStatus!.index};
          } else if (message.method == 'openAppSettings') {
            openAppSettingsCallback?.call();
            return true;
          }

          return null;
        });
  }

  group('notification datasource test:', () {
    group('getAppNotificationSetting test:', () {
      test(
        'should return cache notification setting '
        'when cache is available',
      () async {
        // arrange
        const cacheNotificationSetting = true;
        when(notificationSettingCacheManager.getAppNotificationSettingCache())
          .thenReturn(cacheNotificationSetting);

        // act
        final result = await notificationDatasourceImpl.getAppNotificationSetting();

        // assert
        verify(
          notificationSettingCacheManager.getAppNotificationSettingCache())
            .called(1);
        expect(result, cacheNotificationSetting);
      });

      test(
        'should return true '
        'and cache notification setting with value true '
        'when cache is not available '
        'and user already granted notification permission',
      () async {
        // arrange
        when(notificationSettingCacheManager.getAppNotificationSettingCache())
          .thenReturn(null);
        setMockNotificationPermission(currentStatus: PermissionStatus.granted);

        // act
        final result = await notificationDatasourceImpl.getAppNotificationSetting();

        // assert
        verify(
          notificationSettingCacheManager.getAppNotificationSettingCache())
            .called(1);
        verify(
          notificationSettingCacheManager.persistAppNotificationSettingCache(true))
            .called(1);
        expect(result, true);
      });

      test(
        'should return true '
        'and cache notification setting with value true '
        'when cache is not available '
        'and user grantes notification permission when asked',
      () async {
        // arrange
        when(notificationSettingCacheManager.getAppNotificationSettingCache())
          .thenReturn(null);
        setMockNotificationPermission(
          currentStatus: PermissionStatus.denied,
          requestedStatus: PermissionStatus.granted);

        // act
        final result = await notificationDatasourceImpl.getAppNotificationSetting();

        // assert
        verify(
          notificationSettingCacheManager.getAppNotificationSettingCache())
            .called(1);
        verify(
          notificationSettingCacheManager.persistAppNotificationSettingCache(true))
            .called(1);
        expect(result, true);
      });

      test(
        'should return false '
        'and cache notification setting with value false '
        'when cache is not available '
        'and user denies notification permission when asked',
      () async {
        // arrange
        when(notificationSettingCacheManager.getAppNotificationSettingCache())
          .thenReturn(null);
        setMockNotificationPermission(
          currentStatus: PermissionStatus.denied,
          requestedStatus: PermissionStatus.denied);

        // act
        final result = await notificationDatasourceImpl.getAppNotificationSetting();

        // assert
        verify(
          notificationSettingCacheManager.getAppNotificationSettingCache())
            .called(1);
        verify(
          notificationSettingCacheManager.persistAppNotificationSettingCache(false))
            .called(1);
        expect(result, false);
      });

      test(
        'should return false '
        'and cache notification setting with value false '
        'when cache is not available '
        'and user permanently denies notification permission before',
      () async {
        // arrange
        when(notificationSettingCacheManager.getAppNotificationSettingCache())
          .thenReturn(null);
        setMockNotificationPermission(
          currentStatus: PermissionStatus.permanentlyDenied);

        // act
        final result = await notificationDatasourceImpl.getAppNotificationSetting();

        // assert
        verify(
          notificationSettingCacheManager.getAppNotificationSettingCache())
            .called(1);
        verify(
          notificationSettingCacheManager.persistAppNotificationSettingCache(false))
            .called(1);
        expect(result, false);
      });
    });

    group('toggleAppNotificationSetting test:', () {
      test(
        'should call persistAppNotificationSettingCache with false value '
        'when user toggles notification setting off',
      () async {
        // arrange
        when(notificationSettingCacheManager.persistAppNotificationSettingCache(any))
          .thenAnswer((_) async {});

        // act
        await notificationDatasourceImpl.toggleAppNotificationSetting(false);

        // assert
        verify(
          notificationSettingCacheManager.persistAppNotificationSettingCache(false))
            .called(1);
      });

      test(
        'should call persistAppNotificationSettingCache with true value '
        'when user toggles notification setting on '
        'and granted notification permission before',
      () async {
        // arrange
        when(notificationSettingCacheManager.persistAppNotificationSettingCache(any))
          .thenAnswer((_) async {});
        setMockNotificationPermission(currentStatus: PermissionStatus.granted);

        // act
        await notificationDatasourceImpl.toggleAppNotificationSetting(true);

        // assert
        verify(
          notificationSettingCacheManager.persistAppNotificationSettingCache(true))
            .called(1);
      });

      test(
        'should call persistAppNotificationSettingCache with true value '
        'when user toggles notification setting on '
        'and did not grant notification permission before '
        'then grants notification permission when asked',
      () async {
        // arrange
        when(notificationSettingCacheManager.persistAppNotificationSettingCache(any))
          .thenAnswer((_) async {});
        setMockNotificationPermission(
          currentStatus: PermissionStatus.denied,
          requestedStatus: PermissionStatus.granted);

        // act
        await notificationDatasourceImpl.toggleAppNotificationSetting(true);

        // assert
        verify(
          notificationSettingCacheManager.persistAppNotificationSettingCache(true))
            .called(1);
      });

      test(
        'should throw NotificationPermissionDeniedException '
        'when user toggles notification setting on '
        'and did not grant notification permission before '
        'then denies notification permission when asked',
      () async {
        // arrange
        when(notificationSettingCacheManager.persistAppNotificationSettingCache(any))
          .thenAnswer((_) async {});
        when(exceptionThrower.throwException(const TypeMatcher<NotificationPermissionDeniedException>(), any))
          .thenThrow(const NotificationPermissionDeniedException());
        setMockNotificationPermission(
          currentStatus: PermissionStatus.denied,
          requestedStatus: PermissionStatus.denied);

        // assert
        expect(
          notificationDatasourceImpl.toggleAppNotificationSetting(true),
          throwsA(isA<NotificationPermissionDeniedException>()));
      });

      test(
        'should throw NotificationPermissionDeniedException '
        'when user toggles notification setting on '
        'and permanently denies notification permission before',
      () async {
        // arrange
        when(notificationSettingCacheManager.persistAppNotificationSettingCache(any))
          .thenAnswer((_) async {});
        when(exceptionThrower.throwException(const TypeMatcher<NotificationPermissionDeniedException>(), any))
          .thenThrow(const NotificationPermissionDeniedException());
        setMockNotificationPermission(
          currentStatus: PermissionStatus.permanentlyDenied);

        // assert
        expect(
          notificationDatasourceImpl.toggleAppNotificationSetting(true),
          throwsA(isA<NotificationPermissionDeniedException>()));
      });
    });

    group('attemptToggleSystemNotificationSetting test:', () {
      test(
        'should call openAppSettings '
        'and cache notification setting with value true '
        'and return true '
        'when user grants notification permission before',
      () async {
        // arrange
        when(notificationSettingCacheManager.persistAppNotificationSettingCache(any))
          .thenAnswer((_) async {});  
        bool openAppSettingsCalled = false;
        setMockNotificationPermission(
          currentStatus: PermissionStatus.granted,
          openAppSettingsCallback: () => openAppSettingsCalled = true);

        // act
        final result = await notificationDatasourceImpl.attemptToggleSystemNotificationSetting();

        // assert
        expect(openAppSettingsCalled, true);
        verify(
          notificationSettingCacheManager.persistAppNotificationSettingCache(true))
            .called(1);
        expect(result, true);
      });

      test(
        'should call openAppSettings '
        'and cache notification setting with value true '
        'and return true '
        'when user did not grant notification permission before '
        'then grants notification permission when asked',
      () async {
        // arrange
        when(notificationSettingCacheManager.persistAppNotificationSettingCache(any))
          .thenAnswer((_) async {});  
        bool openAppSettingsCalled = false;
        setMockNotificationPermission(
          currentStatus: PermissionStatus.denied,
          requestedStatus: PermissionStatus.granted,
          openAppSettingsCallback: () => openAppSettingsCalled = true);

        // act
        final result = await notificationDatasourceImpl.attemptToggleSystemNotificationSetting();

        // assert
        expect(openAppSettingsCalled, true);
        verify(
          notificationSettingCacheManager.persistAppNotificationSettingCache(true))
            .called(1);
        expect(result, true);
      });

      test(
        'should call openAppSettings '
        'and cache notification setting with value false '
        'and return false '
        'when user did not grant notification permission before '
        'then denies notification permission when asked',
      () async {
        // arrange
        when(notificationSettingCacheManager.persistAppNotificationSettingCache(any))
          .thenAnswer((_) async {});  
        bool openAppSettingsCalled = false;
        setMockNotificationPermission(
          currentStatus: PermissionStatus.denied,
          requestedStatus: PermissionStatus.denied,
          openAppSettingsCallback: () => openAppSettingsCalled = true);

        // act
        final result = await notificationDatasourceImpl.attemptToggleSystemNotificationSetting();

        // assert
        expect(openAppSettingsCalled, true);
        verify(
          notificationSettingCacheManager.persistAppNotificationSettingCache(false))
            .called(1);
        expect(result, false);
      });

      test(
        'should call openAppSettings '
        'and cache notification setting with value false '
        'and return false '
        'when user permanently denies notification permission before',
      () async {
        // arrange
        when(notificationSettingCacheManager.persistAppNotificationSettingCache(any))
          .thenAnswer((_) async {});  
        bool openAppSettingsCalled = false;
        setMockNotificationPermission(
          currentStatus: PermissionStatus.permanentlyDenied,
          openAppSettingsCallback: () => openAppSettingsCalled = true);

        // act
        final result = await notificationDatasourceImpl.attemptToggleSystemNotificationSetting();

        // assert
        expect(openAppSettingsCalled, true);
        verify(
          notificationSettingCacheManager.persistAppNotificationSettingCache(false))
            .called(1);
        expect(result, false);
      });
    });
  });
}