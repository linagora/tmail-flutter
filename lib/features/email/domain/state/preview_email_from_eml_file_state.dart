import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';

class PreviewingEmailFromEmlFile extends LoadingState {}

class PreviewEmailFromEmlFileSuccess extends UIState {

  final EMLPreviewer emlPreviewer;

  PreviewEmailFromEmlFileSuccess(this.emlPreviewer);

  @override
  List<Object?> get props => [emlPreviewer];
}

class PreviewEmailFromEmlFileFailure extends FeatureFailure {

  PreviewEmailFromEmlFileFailure(dynamic exception) : super(exception: exception);
}