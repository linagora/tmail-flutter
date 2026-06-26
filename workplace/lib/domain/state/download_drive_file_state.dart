import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/upload/file_info.dart';

class DownloadingDriveFile extends UIState {}

class DownloadDriveFileSuccess extends UIState {
  final FileInfo fileInfo;

  DownloadDriveFileSuccess(this.fileInfo);

  @override
  List<Object?> get props => [fileInfo];
}

class DownloadDriveFileFailure extends FeatureFailure {
  DownloadDriveFileFailure(dynamic exception) : super(exception: exception);
}
