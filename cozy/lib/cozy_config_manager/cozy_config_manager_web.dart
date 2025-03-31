import 'dart:async';

import 'package:linagora_design_flutter/cozy_config_manager/cozy_config_manager.dart' as cozy;

class CozyConfigManager {
  bool? _isInsideCozy;

  Future<void> injectCozyScript() async {
    await cozy.CozyConfigManager().injectCozyScript();
  }

  Future<void> initialize() async {
    await cozy.CozyConfigManager().initialize();
  }

  Future<bool> get isInsideCozy async {
    return _isInsideCozy ??= await _checkCozyEnvironment();
  }

  Future<bool> _checkCozyEnvironment() async {
    return await cozy.CozyConfigManager().isInsideCozy;
  }
}