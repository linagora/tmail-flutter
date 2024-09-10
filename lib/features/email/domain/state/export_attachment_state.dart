import 'package:core/data/network/download/downloaded_response.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class ExportAttachmentSuccess extends UIState {
  final DownloadedResponse downloadedResponse;
  final bool isPreview;

  ExportAttachmentSuccess(this.downloadedResponse, this.isPreview);

  @override
  List<Object> get props => [downloadedResponse, isPreview];
}

class ExportAttachmentFailure extends FeatureFailure {
  final bool isPreview;

  ExportAttachmentFailure(dynamic exception, this.isPreview) : super(exception: exception);

  @override
  List<Object?> get props => [...super.props, isPreview];
}