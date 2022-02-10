import 'package:core/core.dart';

class DeleteCredentialSuccess extends UIState {
  DeleteCredentialSuccess();

  @override
  List<Object> get props => [];
}

class DeleteCredentialFailure extends FeatureFailure {
  final exception;

  DeleteCredentialFailure(this.exception);

  @override
  List<Object> get props => [exception];
}