import 'dart:async';

import 'package:core/utils/logging/app_logger_registry.dart';
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

/// Registers Sentry log handlers shared across all platforms.
///
/// Safe to call before Sentry initialises — [SentryManager] guards
/// each call with [SentryManager.isSentryAvailable], so early calls
/// are no-ops until Sentry is ready.
void registerSentryLogHandlers() {
  final sentry = SentryManager.instance;
  AppLoggerRegistry.instance
    ..registerHandler(SentryBreadcrumbHandler(sentry))
    ..registerHandler(SentryEventHandler(sentry));
}
