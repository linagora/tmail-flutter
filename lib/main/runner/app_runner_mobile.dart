import 'package:core/utils/config/env_loader.dart';
import 'package:tmail_ui_user/main/runner/app_runner_base.dart';

Future<void> runAppWithMonitoring(Future<void> Function() runTmail) async {
  await runWithZoneAndErrorHandling(() async {
    await EnvLoader.loadEnvFile();

    await runTmail();
  });
}
