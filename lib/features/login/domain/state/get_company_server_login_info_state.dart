import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/login/domain/model/company_server_login_info.dart';

class GettingCompanyServerLoginInfo extends LoadingState {}

class GetCompanyServerLoginInfoSuccess extends UIState {
  final CompanyServerLoginInfo serverLoginInfo;
  final bool popAllRoute;

  GetCompanyServerLoginInfoSuccess(
    this.serverLoginInfo, {
    this.popAllRoute = true,
  });

  @override
  List<Object> get props => [serverLoginInfo, popAllRoute];
}

class GetCompanyServerLoginInfoFailure extends FeatureFailure {
  final bool popAllRoute;

  GetCompanyServerLoginInfoFailure(
    dynamic exception, {
    this.popAllRoute = true,
  }) : super(exception: exception);

  @override
  List<Object?> get props => [...super.props, popAllRoute];
}
