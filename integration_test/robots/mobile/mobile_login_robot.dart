import '../abstract/abstract_login_robot.dart';
import '../login_robot.dart';

class MobileLoginRobot extends LoginRobot implements AbstractLoginRobot {
  MobileLoginRobot(super.$);

  @override
  Future<void> loginWithBasicAuth({
    required String username,
    required String hostUrl,
    required String email,
    required String password,
  }) async {
    await tapOnUseCompanyServer();
    await enterEmail(username);
    await tapOnNextButton();
    await enterHostUrl(hostUrl);
    await tapOnNextButton();
    await enterBasicAuthEmail(email);
    await enterBasicAuthPassword(password);
    await loginBasicAuth();
    await grantNotificationPermission();
  }
}
