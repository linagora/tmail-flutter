import 'package:core/core.dart';
import 'package:model/model.dart';

class AuthenticationUserViewState extends UIState {
  final User user;

  AuthenticationUserViewState(this.user);

  @override
  List<Object> get props => [user];
}

class AuthenticationUserFailure extends FeatureFailure {
  final exception;

  AuthenticationUserFailure(this.exception);

  @override
  List<Object> get props => [exception];
}