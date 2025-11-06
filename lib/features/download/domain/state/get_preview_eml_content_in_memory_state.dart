import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';

class GettingPreviewEMLContentInMemory extends LoadingState {}

class GetPreviewEMLContentInMemorySuccess extends UIState {
  final EMLPreviewer emlPreviewer;

  GetPreviewEMLContentInMemorySuccess(this.emlPreviewer);

  @override
  List<Object?> get props => [emlPreviewer];
}

class GetPreviewEMLContentInMemoryFailure extends FeatureFailure {
  final String? keyStored;

  GetPreviewEMLContentInMemoryFailure({
    this.keyStored,
    dynamic exception,
  }) : super(exception: exception);

  @override
  List<Object?> get props => [keyStored, exception];
}