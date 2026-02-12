import 'package:core/utils/config/env_loader.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/main.dart';
import 'package:tmail_ui_user/main/main_entry.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:tmail_ui_user/main/runner/app_runner_base.dart';

Future<void> runAppWithMonitoring(Future<void> Function() runTmail) async {
  await runAppGuarded(() async {
    await EnvLoader.loadEnvFile();

    await SentryManager.instance.initialize(
      appRunner: () async {
        await runTmailPreload();
        runApp(SentryWidget(child: const TMailApp()));
      },
      fallBackRunner: runTmail,
    );
  });
}
