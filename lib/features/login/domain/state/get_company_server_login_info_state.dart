import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/login/domain/model/company_server_login_info.dart';

class GettingCompanyServerLoginInfo extends LoadingState {}

class GetCompanyServerLoginInfoSuccess extends UIState {
  final CompanyServerLoginInfo serverLoginInfo;

  GetCompanyServerLoginInfoSuccess(this.serverLoginInfo);

  @override
  List<Object> get props => [serverLoginInfo];
}

class GetCompanyServerLoginInfoFailure extends FeatureFailure {
  GetCompanyServerLoginInfoFailure(dynamic exception)
      : super(exception: exception);
}
