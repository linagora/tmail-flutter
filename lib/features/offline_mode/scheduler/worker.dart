
import 'package:core/utils/platform_info.dart';
import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/offline_mode/config/work_manager_constants.dart';
import 'package:tmail_ui_user/features/offline_mode/scheduler/worker_type.dart';

/// Equivalent to the task or work that needs to be done in the background
class Worker with EquatableMixin {

  final String id;
  final WorkerType type;
  final Map<String, dynamic> data;

  Worker(this.id, this.type, this.data);

  String get uniqueId {
    if (PlatformInfo.isIOS) {
      return type.iOSUniqueId;
    }
    return id;
  }

  Map<String, dynamic> get inputData {
    data[WorkManagerConstants.workerTypeKey] = type.name;
    return data;
  }

  @override
  List<Object?> get props => [id, type, data];
}