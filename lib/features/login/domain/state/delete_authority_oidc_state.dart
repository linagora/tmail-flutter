import 'package:core/core.dart';

class DeleteAuthorityOidcSuccess extends UIState {
  DeleteAuthorityOidcSuccess();

  @override
  List<Object> get props => [];
}

class DeleteAuthorityOidcFailure extends FeatureFailure {
  final dynamic exception;

  DeleteAuthorityOidcFailure(this.exception);

  @override
  List<Object> get props => [exception];
}