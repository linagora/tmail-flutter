import 'package:permission_handler/permission_handler.dart';
import 'package:tmail_ui_user/features/base/isolate/background_isolate_binary_messenger/background_isolate_binary_messenger_mobile.dart';
import 'package:tmail_ui_user/main/permissions/permission_service.dart';

class NotificationPermissionService extends PermissionService {

  Future<bool> checkGroupPermissionByGroupId(String groupId) async {
    if (groupId.isEmpty) {
      return false;
    }

    const methodChannel = MethodChannel('com.linagora.android.teammail.notification.group.permission');
    const methodName = 'getNotificationGroupPermission';
    final invokeResult = await methodChannel.invokeMethod<bool>(
      methodName,
      groupId);
    return invokeResult ?? false;
  }

  Future<bool> checkNotificationPermissionEnabled(String groupId) async {
    final permissionGranted = await isGranted(Permission.notification);
    if (!permissionGranted) {
      return false;
    }

    return await checkGroupPermissionByGroupId(groupId);
  }
}