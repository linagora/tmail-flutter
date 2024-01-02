
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class TwakeWelcomeController extends BaseController {

  Future<void> _saveStateFirstTimeAppLaunch() async {
    await appStore.setItemBoolean(AppConfig.firstTimeAppLaunchKey, true);
  }

  void navigateToTwakeIdPage() async {
    await _saveStateFirstTimeAppLaunch();
    popAndPush(AppRoutes.twakeId);
  }
}