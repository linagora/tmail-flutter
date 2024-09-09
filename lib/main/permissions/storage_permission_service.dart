import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmail_ui_user/main/permissions/permission_service.dart';

class StoragePermissionService extends PermissionService {

  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  StoragePermissionService._();

  static final StoragePermissionService _instance = StoragePermissionService._();

  factory StoragePermissionService() => _instance;

  Future<int> _getCurrentAndroidVersion() async {
    return (await _deviceInfoPlugin.androidInfo).version.sdkInt;
  }

  Future<bool> isUserHaveToRequestStoragePermissionAndroid() async {
    return await _getCurrentAndroidVersion() <= 29
        && !(await Permission.storage.isGranted);
  }

  Future<PermissionStatus> requestPhotoAddOnlyPermissionIOS() async {
    return await Permission.photosAddOnly.request();
  }

  void goToSettingsForPermissionActions() {
    openAppSettings();
  }
}