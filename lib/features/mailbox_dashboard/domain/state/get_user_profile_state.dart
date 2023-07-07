import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/user/user_profile.dart';

class GetUserProfileSuccess extends UIState {
  final UserProfile userProfile;

  GetUserProfileSuccess(this.userProfile);

  @override
  List<Object> get props => [];
}

class GetUserProfileFailure extends FeatureFailure {

  GetUserProfileFailure(dynamic exception) : super(exception: exception);
}