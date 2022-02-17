import 'dart:core';

import 'package:device_info_plus/device_info_plus.dart';


class DeviceManager {
  final DeviceInfoPlugin _deviceInfoPlugin;

  DeviceManager(this._deviceInfoPlugin);

  Future<bool> isNeedRequestStoragePermissionOnAndroid() async {
    final androidInfo = await _deviceInfoPlugin.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    if (sdkInt != null) {
      return sdkInt <= 28;
    }
    return false;
  }
}