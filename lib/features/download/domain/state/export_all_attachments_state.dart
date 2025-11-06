import 'package:core/data/network/download/downloaded_response.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class ExportingAllAttachments extends LoadingState {}

class ExportAllAttachmentsSuccess extends UIState {
  ExportAllAttachmentsSuccess(this.downloadedResponse);

  final DownloadedResponse downloadedResponse;

  @override
  List<Object> get props => [downloadedResponse];
}

class ExportAllAttachmentsFailure extends FeatureFailure {
  ExportAllAttachmentsFailure({super.exception});
}