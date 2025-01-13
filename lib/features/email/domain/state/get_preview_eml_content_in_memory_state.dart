import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GettingPreviewEMLContentInMemory extends LoadingState {}

class GetPreviewEMLContentInMemorySuccess extends UIState {
  final String previewEMLContent;

  GetPreviewEMLContentInMemorySuccess(this.previewEMLContent);

  @override
  List<Object?> get props => [previewEMLContent];
}

class GetPreviewEMLContentInMemoryFailure extends FeatureFailure {

  GetPreviewEMLContentInMemoryFailure(dynamic exception) : super(exception: exception);
}