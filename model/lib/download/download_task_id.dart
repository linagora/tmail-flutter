import 'package:equatable/equatable.dart';

class DownloadTaskId with EquatableMixin {
  final String taskId;

  DownloadTaskId(this.taskId);

  @override
  List<Object> get props => [taskId];
}