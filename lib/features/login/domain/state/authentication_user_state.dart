import 'package:core/core.dart';
import 'package:model/model.dart';

class AuthenticationUserViewState extends UIState {
  final UserProfile userProfile;

  AuthenticationUserViewState(this.userProfile);

  @override
  List<Object> get props => [userProfile];
}

class AuthenticationUserFailure extends FeatureFailure {
  final exception;

  AuthenticationUserFailure(this.exception);

  @override
  List<Object> get props => [exception];
}