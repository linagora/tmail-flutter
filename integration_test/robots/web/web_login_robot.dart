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
    await enterBasicAuthEmail(email);
    await enterBasicAuthPassword(password);
    await loginBasicAuth();
  }
}
