import 'package:core/data/network/download/downloaded_response.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class ExportAttachmentSuccess extends UIState {
  final DownloadedResponse downloadedResponse;

  ExportAttachmentSuccess(this.downloadedResponse);

  @override
  List<Object> get props => [downloadedResponse];
}

class ExportAttachmentFailure extends FeatureFailure {

  ExportAttachmentFailure(dynamic exception) : super(exception: exception);
}