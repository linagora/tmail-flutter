import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/download/download_task_id.dart';

class DownloadAttachmentsSuccess extends UIState {
  final List<DownloadTaskId> taskIds;

  DownloadAttachmentsSuccess(this.taskIds);

  @override
  List<Object> get props => [taskIds];
}

class DownloadAttachmentsFailure extends FeatureFailure {

  DownloadAttachmentsFailure(dynamic exception) : super(exception: exception);
}