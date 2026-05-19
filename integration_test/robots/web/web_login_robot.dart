import '../../utils/test_timer.dart';
import '../mobile/mobile_login_robot.dart';

class WebLoginRobot extends MobileLoginRobot {
  WebLoginRobot(super.$);

  @override
  Future<void> loginWithBasicAuth({
    required String username,
    required String hostUrl,
    required String email,
    required String password,
  }) async {
    final t = TestTimer();
    await t.timedStep('login_enter_email', () => enterBasicAuthEmail(email));
    await t.timedStep('login_enter_password', () => enterBasicAuthPassword(password));
    await t.timedStep('login_submit', loginBasicAuth);
  }
}
