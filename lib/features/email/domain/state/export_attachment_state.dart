import 'package:core/core.dart';

class ExportAttachmentSuccess extends UIState {
  final DownloadedResponse downloadedResponse;

  ExportAttachmentSuccess(this.downloadedResponse);

  @override
  List<Object> get props => [downloadedResponse];
}

class ExportAttachmentFailure extends FeatureFailure {
  final dynamic exception;

  ExportAttachmentFailure(this.exception);

  @override
  List<Object> get props => [exception];
}