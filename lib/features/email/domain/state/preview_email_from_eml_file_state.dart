import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';

class PreviewingEmailFromEmlFile extends LoadingState {}

class PreviewEmailFromEmlFileSuccess extends UIState {

  final String storeKey;
  final EMLPreviewer emlPreviewer;

  PreviewEmailFromEmlFileSuccess(this.storeKey, this.emlPreviewer);

  @override
  List<Object?> get props => [storeKey, emlPreviewer];
}

class PreviewEmailFromEmlFileFailure extends FeatureFailure {

  PreviewEmailFromEmlFileFailure(dynamic exception) : super(exception: exception);
}