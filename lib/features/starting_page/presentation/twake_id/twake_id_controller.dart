
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_navigate_arguments.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_navigate_type.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class TwakeIdController extends GetxController {

  final ImagePaths imagePaths = Get.find<ImagePaths>();

  final navigateArguments = Rxn<LoginNavigateArguments>();

  @override
  void onInit() {
    ThemeUtils.setPreferredPortraitOrientations();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    navigateArguments.value = Get.arguments;
  }

  void handleUseCompanyServer() {
    if (isAddAnotherAccount) {
      push(
        AppRoutes.login,
        arguments: navigateArguments.value);
    } else {
      popAndPush(
        AppRoutes.login,
        arguments: LoginArguments(LoginFormType.dnsLookupForm));
    }
  }

  void backToHomeView() {
    popAndPush(AppRoutes.home);
  }

  bool get isAddAnotherAccount => navigateArguments.value != null &&
    navigateArguments.value?.navigateType == LoginNavigateType.addAnotherAccount;
}