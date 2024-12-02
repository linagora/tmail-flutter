import 'package:tmail_ui_user/features/home/domain/state/auto_sign_in_via_deep_link_state.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_navigate_type.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class LoginNavigateArguments extends RouterArguments {

  final LoginNavigateType navigateType;
  final AutoSignInViaDeepLinkSuccess? autoSignInViaDeepLinkSuccess;

  LoginNavigateArguments({
    required this.navigateType,
    this.autoSignInViaDeepLinkSuccess,
  });

  factory LoginNavigateArguments.autoSignIn({
    required AutoSignInViaDeepLinkSuccess autoSignInViaDeepLinkSuccess,
  }) {
    return LoginNavigateArguments(
      navigateType: LoginNavigateType.autoSignIn,
      autoSignInViaDeepLinkSuccess: autoSignInViaDeepLinkSuccess,
    );
  }

  @override
  List<Object?> get props => [
    navigateType,
    autoSignInViaDeepLinkSuccess,
  ];
}
