import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/upload/file_info.dart';

class LocalFilePickerSuccess extends UIState {
  final List<FileInfo> pickedFiles;

  LocalFilePickerSuccess(this.pickedFiles);

  @override
  List<Object> get props => [pickedFiles];
}

class LocalFilePickerFailure extends FeatureFailure {

  LocalFilePickerFailure(dynamic exception) : super(exception: exception);
}

class LocalFilePickerCancel extends FeatureFailure {}