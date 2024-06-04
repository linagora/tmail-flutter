import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmail_ui_user/main/permissions/permission_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final permissionService = PermissionService();
  
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

  group('permission service test:', () {
    group('isGranted test:', () {
      test(
        'should return true '
        'when permission is granted before',
      () async {
        // arrange
        setMockNotificationPermission(currentStatus: PermissionStatus.granted);

        // act
        final result = await permissionService.isGranted(Permission.notification);

        // assert
        expect(result, true);
      });

      test(
        'should return true '
        'when permission is not granted before '
        'and granted when request',
      () async {
        // arrange
        setMockNotificationPermission(
          currentStatus: PermissionStatus.denied,
          requestedStatus: PermissionStatus.granted);

        // act
        final result = await permissionService.isGranted(Permission.notification);

        // assert
        expect(result, true);
      });

      test(
        'should return false '
        'when permission is not granted before '
        'and denied when request',
      () async {
        // arrange
        setMockNotificationPermission(
          currentStatus: PermissionStatus.denied,
          requestedStatus: PermissionStatus.denied);

        // act
        final result = await permissionService.isGranted(Permission.notification);

        // assert
        expect(result, false);
      });
    });
  });
}