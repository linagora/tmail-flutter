import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/user/user_profile.dart';

class AuthenticationUserLoading extends LoadingState {}

class AuthenticationUserSuccess extends UIState {
  final UserProfile userProfile;

  AuthenticationUserSuccess(this.userProfile);

  @override
  List<Object> get props => [userProfile];
}

class AuthenticationUserFailure extends FeatureFailure {

  AuthenticationUserFailure(dynamic exception) : super(exception: exception);
}