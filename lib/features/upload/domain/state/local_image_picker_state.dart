import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/upload/file_info.dart';

class LocalImagePickerLoading extends LoadingState {}

class LocalImagePickerSuccess extends UIState {
  final FileInfo fileInfo;

  LocalImagePickerSuccess(this.fileInfo);

  @override
  List<Object> get props => [fileInfo];
}

class LocalImagePickerFailure extends FeatureFailure {

  LocalImagePickerFailure(dynamic exception) : super(exception: exception);
}
