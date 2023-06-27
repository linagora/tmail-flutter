
import 'package:core/core.dart';
import 'package:tmail_ui_user/features/offline_mode/work_manager/work_dispatcher.dart';
import 'package:workmanager/workmanager.dart';

class WorkManagerConfig {
  static WorkManagerConfig? _instance;

  WorkManagerConfig._();

  factory WorkManagerConfig() => _instance ??= WorkManagerConfig._();

  Future<void> initialize() {
    return Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: BuildUtils.isDebugMode
    );
  }
}