
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_navigate_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class TwakeIdController extends GetxController {

  final ImagePaths imagePaths = Get.find<ImagePaths>();

  final loginNavigateArguments = Rxn<LoginNavigateArguments>();

  @override
  void onInit() {
    ThemeUtils.setPreferredPortraitOrientations();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    loginNavigateArguments.value = Get.arguments;
  }

  void handleUseCompanyServer() {
    popAndPush(
      AppRoutes.login,
      arguments: LoginArguments(LoginFormType.dnsLookupForm));
  }
}