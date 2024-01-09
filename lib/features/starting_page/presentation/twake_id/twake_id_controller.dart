
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class TwakeIdController extends GetxController {

  @override
  void onInit() {
    ThemeUtils.setPreferredPortraitOrientations();
    super.onInit();
  }

  void handleUseCompanyServer() {
    popAndPush(
      AppRoutes.login,
      arguments: LoginArguments(LoginFormType.dnsLookupForm));
  }
}