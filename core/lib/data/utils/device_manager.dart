import 'dart:core';

import 'package:device_info/device_info.dart';

class DeviceManager {
  final DeviceInfoPlugin _deviceInfoPlugin;

  DeviceManager(this._deviceInfoPlugin);

  Future<bool> isNeedRequestStoragePermissionOnAndroid() async {
    final androidInfo = await _deviceInfoPlugin.androidInfo;
    return androidInfo.version.sdkInt <= 28;
  }
}