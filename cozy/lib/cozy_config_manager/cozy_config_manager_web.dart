import 'dart:async';

import 'package:linagora_design_flutter/cozy_config_manager/cozy_config_manager.dart' as cozy;

class CozyConfigManager {
  bool? _isInsideCozy;

  Future<void> injectCozyScript(String cozyExternalBridgeVersion) async {
    await cozy.CozyConfigManager().injectCozyScript(cozyExternalBridgeVersion);
  }

  Future<void> initialize() async {
    await cozy.CozyConfigManager().initialize();
  }

  Future<bool> get isInsideCozy async {
    try {
      return _isInsideCozy ??= await _checkCozyEnvironment();
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkCozyEnvironment() async {
    return await cozy.CozyConfigManager().isInsideCozy;
  }
}