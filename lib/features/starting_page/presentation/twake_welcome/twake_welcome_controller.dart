import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class TwakeWelcomeController extends BaseController {

  void handleUseCompanyServer() {
    popAndPush(
      AppRoutes.login,
      arguments: LoginArguments(LoginFormType.dnsLookupForm));
  }

  void onClickPrivacyPolicy() {
    AppUtils.launchLink(AppConfig.linagoraPrivacyUrl);
  }
}