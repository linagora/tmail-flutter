
import 'package:core/core.dart';
import 'package:model/model.dart';

class LocalFilePickerSuccess extends UIState {
  final FileInfo fileInfo;

  LocalFilePickerSuccess(this.fileInfo);

  @override
  List<Object> get props => [fileInfo];
}

class LocalFilePickerFailure extends FeatureFailure {
  final exception;

  LocalFilePickerFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class LocalFilePickerCancel extends FeatureFailure {
  @override
  List<Object> get props => [];
}