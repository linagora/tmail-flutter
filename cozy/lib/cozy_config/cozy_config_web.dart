import 'dart:async';

import 'package:linagora_design_flutter/cozy_config_manager/cozy_config_manager.dart';

class CozyConfig {
  static final CozyConfig _instance = CozyConfig._internal();

  factory CozyConfig() {
    return _instance;
  }

  CozyConfig._internal();

  final manager = CozyConfigManager();

  bool? _isInsideCozy;

  Future<bool> get isInsideCozy async {
    return _isInsideCozy ??= await manager.isInsideCozy;
  }
}
