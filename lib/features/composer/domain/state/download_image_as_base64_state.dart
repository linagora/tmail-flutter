
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/upload/file_info.dart';

class DownloadingImageAsBase64 extends UIState {}

class DownloadImageAsBase64Success extends UIState {

  final String base64Uri;
  final String cid;
  final FileInfo fileInfo;

  DownloadImageAsBase64Success(
    this.base64Uri,
    this.cid,
    this.fileInfo,
  );

  @override
  List<Object?> get props => [
    base64Uri,
    cid,
    fileInfo,
  ];
}

class DownloadImageAsBase64Failure extends FeatureFailure {

  DownloadImageAsBase64Failure(dynamic exception) : super(exception: exception);
}