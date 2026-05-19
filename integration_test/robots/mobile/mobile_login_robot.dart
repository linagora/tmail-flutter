import '../../utils/test_timer.dart';
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
    final t = TestTimer();
    await t.timedStep('login_company_server', tapOnUseCompanyServer);
    await t.timedStep('login_enter_username', () => enterEmail(username));
    await t.timedStep('login_next_1', tapOnNextButton);
    await t.timedStep('login_enter_host_url', () => enterHostUrl(hostUrl));
    await t.timedStep('login_next_2', tapOnNextButton);
    await t.timedStep('login_enter_email', () => enterBasicAuthEmail(email));
    await t.timedStep('login_enter_password', () => enterBasicAuthPassword(password));
    await t.timedStep('login_submit', loginBasicAuth);
    await t.timedStep('login_notification', grantNotificationPermission);
  }
}
