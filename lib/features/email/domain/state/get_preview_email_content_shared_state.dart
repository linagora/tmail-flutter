import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GettingPreviewEmailEMLContentShared extends LoadingState {}

class GetPreviewEmailEMLContentSharedSuccess extends UIState {

  final String previewEMLContent;

  GetPreviewEmailEMLContentSharedSuccess(this.previewEMLContent);

  @override
  List<Object?> get props => [previewEMLContent];
}

class GetPreviewEmailEMLContentSharedFailure extends FeatureFailure {

  GetPreviewEmailEMLContentSharedFailure(dynamic exception) : super(exception: exception);
}