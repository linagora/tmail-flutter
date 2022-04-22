import 'package:core/core.dart';
import 'package:model/model.dart';

class GetUserProfileSuccess extends UIState {
  final UserProfile userProfile;

  GetUserProfileSuccess(this.userProfile);

  @override
  List<Object> get props => [];
}

class GetUserProfileFailure extends FeatureFailure {
  final dynamic exception;

  GetUserProfileFailure(this.exception);

  @override
  List<Object> get props => [exception];
}