import 'package:get/get.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/sign_in_email_link.dart';
import 'package:tmail_ui_user/features/login/presentation/login_view_web.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

import '../../base/core_robot.dart';
import '../../utils/wait_for_condition.dart';

/// Web only: copies the location bar and pastes it into the signed-out app, like opening an email link.
class WebSignInEmailLinkRobot extends CoreRobot {
  WebSignInEmailLinkRobot(super.$);

  String copyLocationLink() => Uri(path: Uri.base.path, query: Uri.base.query).toString();

  Future<void> openPastedLinkWhileSignedOut(String link) async {
    await waitForCondition(
      () => _isOnLoginPage,
      reason: 'the app is signed out',
    );
    Get.offAllNamed(link);
    await waitForCondition(
      () => hasSignInEmailLink() && _isOnLoginPage,
      reason: 'the pasted link is kept and the app asks to sign in',
    );
  }

  bool get _isOnLoginPage =>
      Get.currentRoute.startsWith(AppRoutes.login) && $(LoginView).exists;
}
