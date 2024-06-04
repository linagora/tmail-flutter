import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/notification_datasource_impl.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:tmail_ui_user/main/permissions/notification_permission_service.dart';

import 'notification_datasource_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<NotificationPermissionService>(),
  MockSpec<ExceptionThrower>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  final permissionService = MockNotificationPermissionService();
  final exceptionThrower = MockExceptionThrower();
  final notificationDatasourceImpl = NotificationDataSourceImpl(
    permissionService,
    exceptionThrower);

  final userName = UserName('value');

  void setMockNotificationPermission({
    VoidCallback? openAppSettingsCallback,
  }) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('com.spencerccf.app_settings/methods'),
        (message) async {
          if (message.method == 'openSettings') {
            openAppSettingsCallback?.call();
            return true;
          }

          return null;
        });
  }

  group('notification datasource test:', () {
    group('getAppNotificationSetting test:', () {
      test(
        'should return true '
        'when user grants notification permission',
      () async {
        // arrange
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        when(permissionService.checkNotificationPermissionEnabled(any)).thenAnswer((_) async => true);

        // act
        final result = await notificationDatasourceImpl.getNotificationSetting(userName);

        // assert
        verify(permissionService.checkNotificationPermissionEnabled(userName.value));
        expect(result, true);
        debugDefaultTargetPlatformOverride = null;
      });

      test(
        'should return false '
        'when user denies notification permission',
      () async {
        // arrange
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        when(permissionService.checkNotificationPermissionEnabled(any)).thenAnswer((_) async => false);

        // act
        final result = await notificationDatasourceImpl.getNotificationSetting(userName);

        // assert
        verify(permissionService.checkNotificationPermissionEnabled(userName.value));
        expect(result, false);
        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('toggleAppNotificationSetting test:', () {
      test(
        'should call openAppSettings '
        'when user toggles notification setting on',
      () async {
        // arrange
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        bool openAppSettingsCalled = false;
        setMockNotificationPermission(openAppSettingsCallback: () {
          openAppSettingsCalled = true;
        });

        // act
        await notificationDatasourceImpl.toggleNotificationSetting();

        // assert
        expect(openAppSettingsCalled, true);
        debugDefaultTargetPlatformOverride = null;
      });
    });
  });
}