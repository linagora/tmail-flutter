import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> isGranted(Permission permission) async {
    final current = await permission.status;
    switch (current) {
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.denied:
        final requestResult = await permission.request();
        final permissionGranted = requestResult == PermissionStatus.granted;
        return permissionGranted;
      default:
        return false;
    }
  }
}
