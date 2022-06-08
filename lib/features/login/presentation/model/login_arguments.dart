
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class LoginArguments extends RouterArguments {

  final LoginFormType loginFormType;

  LoginArguments(this.loginFormType);

  @override
  List<Object?> get props => [loginFormType];
}