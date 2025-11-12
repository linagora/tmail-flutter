import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/oidc/response/oidc_user_info.dart';

class GettingOidcUserInfo extends LoadingState {}

class GetOidcUserInfoSuccess extends UIState {
  final OidcUserInfo oidcUserInfo;

  GetOidcUserInfoSuccess(this.oidcUserInfo);

  @override
  List<Object> get props => [oidcUserInfo];
}

class GetOidcUserInfoFailure extends FeatureFailure {
  GetOidcUserInfoFailure(dynamic exception) : super(exception: exception);
}
