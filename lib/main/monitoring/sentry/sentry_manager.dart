import 'package:tmail_ui_user/main/monitoring/sentry/sentry_initializer.dart';

/// For managing Sentry integration globally.
class SentryManager {
  SentryManager._();

  static final SentryManager instance = SentryManager._();

  /// Initializes Sentry SDK via SentryInitializer.
  Future<void> initialize(Future<void> Function() appRunner) async {
    try {
      await SentryInitializer.init(appRunner);
    } catch(_) {
      await appRunner();
    }
  }
}
