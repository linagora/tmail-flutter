import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';

class GettingPreviewEmailEMLContentShared extends LoadingState {}

class GetPreviewEmailEMLContentSharedSuccess extends UIState {

  final EMLPreviewer emlPreviewer;

  GetPreviewEmailEMLContentSharedSuccess(this.emlPreviewer);

  @override
  List<Object?> get props => [emlPreviewer];
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