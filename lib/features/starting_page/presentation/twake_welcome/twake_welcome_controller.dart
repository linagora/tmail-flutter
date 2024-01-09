
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class TwakeWelcomeController extends BaseController {

  @override
  void onInit() {
    ThemeUtils.setPreferredPortraitOrientations();
    super.onInit();
  }

  Future<void> _saveStateFirstTimeAppLaunch() async {
    await appStore.setItemBoolean(AppConfig.firstTimeAppLaunchKey, true);
  }

  @override
  void navigateToTwakeIdPage() async {
    await _saveStateFirstTimeAppLaunch();
    popAndPush(AppRoutes.twakeId);
  }
}