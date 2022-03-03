import 'package:core/core.dart';

class DownloadAttachmentForWebSuccess extends UIState {

  DownloadAttachmentForWebSuccess();

  @override
  List<Object> get props => [];
}

class DownloadAttachmentForWebFailure extends FeatureFailure {
  final exception;

  DownloadAttachmentForWebFailure(this.exception);

  @override
  List<Object> get props => [exception];
}