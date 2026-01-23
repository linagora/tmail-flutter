import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/sentry_config_linagora_ecosystem.dart';

mixin SentryEcosystemMixin {
  SentryUser? _sentryUser;

  void initSentryUser(SentryUser? newSentryUser) {
    _sentryUser = newSentryUser;
  }

  Future<void> setUpSentry(
    SentryConfigLinagoraEcosystem ecosystemConfig,
  ) async {
    if (ecosystemConfig.enabled != true) {
      logWarning('SentryEcosystemMixin::setUpSentry: Sentry is disabled');
      return;
    }

    final dsn = ecosystemConfig.dsn?.trimmed;
    final env = ecosystemConfig.environment?.trimmed;

    if (dsn == null || dsn.isEmpty) {
      logWarning(
          'SentryEcosystemMixin::setUpSentry: Sentry DSN is invalid (null or empty)');
      return;
    }

    if (env == null || env.isEmpty) {
      logWarning(
          'SentryEcosystemMixin::setUpSentry: Sentry Environment is invalid (null or empty)');
      return;
    }

    final sentryConfig = await ecosystemConfig.toSentryConfig();

    await SentryManager.instance.initializeWithSentryConfig(sentryConfig);

    _setupSentryUser();
  }

  void _setupSentryUser() {
    if (_sentryUser == null) return;

    SentryManager.instance.setUser(_sentryUser!);
  }
}
