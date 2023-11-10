
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class SessionArguments extends RouterArguments {

  final LoginFormType loginFormType;
  final String baseUrl;

  SessionArguments(
    this.loginFormType,
    this.baseUrl
  );

  @override
  List<Object?> get props => [
    loginFormType,
    baseUrl,
  ];
}