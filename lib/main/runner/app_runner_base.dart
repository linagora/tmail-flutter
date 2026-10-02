import 'dart:async';

import 'package:core/utils/logging/app_logger_registry.dart';
import 'package:core/utils/logging/formatters/log_formatter.dart';
import 'package:core/utils/logging/handlers/console_log_handler.dart';
import 'package:core/utils/logging/handlers/sentry_breadcrumb_handler.dart';
import 'package:core/utils/logging/handlers/sentry_event_handler.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/main/runner/app_error_handlers.dart';

Future<void> runAppGuarded(Future<void> Function() runner) async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  setupErrorHooks();

  await runner();
}

/// Registers all log handlers for the given platform.
///
/// Must be called once at app startup, before any log call is made.
/// Sentry handlers are registered early — they check [SentryManager.isSentryAvailable]
/// internally, so calls before Sentry initialises are safe no-ops.
void registerLogHandlers({required LogFormatter formatter}) {
  final sentry = SentryManager.instance;
  AppLoggerRegistry.instance
    ..registerHandler(ConsoleLogHandler(formatter: formatter))
    ..registerHandler(SentryBreadcrumbHandler(sentry))
    ..registerHandler(SentryEventHandler(sentry));
}
