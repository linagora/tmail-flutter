import 'package:core/core.dart';
import 'package:model/model.dart';

class DownloadAttachmentsSuccess extends UIState {
  final List<DownloadTaskId> taskIds;

  DownloadAttachmentsSuccess(this.taskIds);

  @override
  List<Object> get props => [taskIds];
}

class DownloadAttachmentsFailure extends FeatureFailure {
  final exception;

  DownloadAttachmentsFailure(this.exception);

  @override
  List<Object> get props => [exception];
}