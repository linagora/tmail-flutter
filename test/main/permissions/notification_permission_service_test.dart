import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmail_ui_user/features/base/isolate/background_isolate_binary_messenger/background_isolate_binary_messenger_mobile.dart';
import 'package:tmail_ui_user/main/permissions/notification_permission_service.dart';

class TestNotificationPermissionService extends NotificationPermissionService {
  bool callCheckGroupPermission = false;

  @override
  Future<bool> checkGroupPermissionByGroupId(String groupId) {
    callCheckGroupPermission = true;
    return super.checkGroupPermissionByGroupId(groupId);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final notificationPermissionService = TestNotificationPermissionService();

  void setMockNotificationPermission({
    required PermissionStatus currentStatus,
    PermissionStatus? requestedStatus,
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
          }

          return null;
        });
  }

  void setMockNotificationGroupStatus({
    required bool groupIsBlocked,
  }) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('com.linagora.android.teammail.notification.group.permission'),
        (message) async {
          if (message.method == 'getNotificationGroupPermission') {
            return groupIsBlocked;
          }

          return null;
        });
  }

  group('notification permission service test', () {
    test(
      'should return false '
      'when checkGroupPermission is called '
      'and group id is empty',
    () async {
      // arrange
      setMockNotificationGroupStatus(groupIsBlocked: true);

      // act
      final result = await notificationPermissionService.checkGroupPermissionByGroupId('');
      
      // assert
      expect(notificationPermissionService.callCheckGroupPermission, true);
      expect(result, false);
    });

    test(
      'should return the status of notification group '
      'when checkGroupPermission is called '
      'and group id is not empty',
    () async {
      // arrange
      setMockNotificationGroupStatus(groupIsBlocked: true);

      // act
      final result = await notificationPermissionService.checkGroupPermissionByGroupId('test');
      
      // assert
      expect(notificationPermissionService.callCheckGroupPermission, true);
      expect(result, true);
    });
    
    test(
      'should return false '
      'when checkNotificationPermissionEnabled is called '
      'and permission is not granted',
    () async {
      // arrange
      setMockNotificationPermission(currentStatus: PermissionStatus.permanentlyDenied);

      // act
      final result = await notificationPermissionService.checkNotificationPermissionEnabled('');
      
      // assert
      expect(result, false);
    });

    test(
      'should return the status of notification group '
      'when checkNotificationPermissionEnabled is called '
      'and permission is not granted',
    () async {
      // arrange
      setMockNotificationPermission(currentStatus: PermissionStatus.granted);
      setMockNotificationGroupStatus(groupIsBlocked: true);

      // act
      final result = await notificationPermissionService.checkGroupPermissionByGroupId('test');
      
      // assert
      expect(result, true);
    });
  });
}