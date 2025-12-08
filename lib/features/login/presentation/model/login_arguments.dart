import 'package:tmail_ui_user/features/login/domain/model/company_server_login_info.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class LoginArguments extends RouterArguments {

  final LoginFormType loginFormType;
  final CompanyServerLoginInfo? loginInfo;

  LoginArguments(this.loginFormType, {this.loginInfo});

  @override
  List<Object?> get props => [loginFormType, loginInfo];
}