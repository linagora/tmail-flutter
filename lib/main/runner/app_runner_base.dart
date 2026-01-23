import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/main/runner/app_error_handlers.dart';

Future<void> runWithZoneAndErrorHandling(Future<void> Function() runner) async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  setupErrorHooks();

  await runner();
}
