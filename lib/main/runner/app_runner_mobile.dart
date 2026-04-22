import 'package:core/utils/config/env_loader.dart';
import 'package:core/utils/logging/app_logger_registry.dart';
import 'package:core/utils/logging/formatters/mobile_console_formatter.dart';
import 'package:core/utils/logging/handlers/console_log_handler.dart';
import 'package:tmail_ui_user/main/runner/app_runner_base.dart';

Future<void> runAppWithMonitoring(Future<void> Function() runTmail) async {
  _registerLogHandlers();

  await runAppGuarded(() async {
    await EnvLoader.loadEnvFile();

    await runTmail();
  });
}

void _registerLogHandlers() {
  AppLoggerRegistry.instance.registerHandler(
    const ConsoleLogHandler(formatter: MobileConsoleFormatter()),
  );
  registerSentryLogHandlers();
}
