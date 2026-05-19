
import 'package:get/get.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

import '../utils/test_timer.dart';
import '../factories/robot_factory.dart';
import '../mixin/scenario_utils_mixin.dart';
import 'base_scenario.dart';

abstract class BaseTestScenario extends BaseScenario with ScenarioUtilsMixin {
  final RobotFactory robots;

  const BaseTestScenario(super.$, this.robots);

  // Seeds credentials directly into app storage so HomeController skips login.
  // Tests run in the same process as the app, so Get.find<> works here.
  Future<void> _seedTestCredentials() async {
    const hostUrl = String.fromEnvironment('BASIC_AUTH_URL');
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const password = String.fromEnvironment('PASSWORD');
    if (hostUrl.isEmpty || email.isEmpty || password.isEmpty) return;

    final credentialRepository = Get.find<CredentialRepository>();
    final accountRepository = Get.find<AccountRepository>();

    await Future.wait([
      credentialRepository.saveBaseUrl(Uri.parse(hostUrl)),
      credentialRepository.storeAuthenticationInfo(
        AuthenticationInfoCache(email, password),
      ),
    ]);
    await accountRepository.setCurrentAccount(
      PersonalAccount(email, AuthenticationType.basic, isSelected: true),
    );
  }

  @override
  Future<void> execute() async {
    await TestTimer().timedPhase('login', _seedTestCredentials);
    await TestTimer().timedPhase('test_logic', runTestLogic);
  }

  Future<void> runTestLogic();
}
