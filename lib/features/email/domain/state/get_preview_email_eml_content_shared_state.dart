import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GettingPreviewEmailEMLContentShared extends LoadingState {}

class GetPreviewEmailEMLContentSharedSuccess extends UIState {

  final String keyStored;
  final String previewEMLContent;

  GetPreviewEmailEMLContentSharedSuccess(this.keyStored, this.previewEMLContent);

  @override
  List<Object?> get props => [keyStored, previewEMLContent];
}

class GetPreviewEmailEMLContentSharedFailure extends FeatureFailure {
  final String? keyStored;

  GetPreviewEmailEMLContentSharedFailure({
    this.keyStored,
    dynamic exception,
  }) : super(exception: exception);

  @override
  List<Object?> get props => [keyStored, exception];
}