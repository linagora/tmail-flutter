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
    final dsn = ecosystemConfig.dsn?.trimmed;
    final env = ecosystemConfig.environment?.trimmed;
    final isValid = ecosystemConfig.enabled == true
        && (dsn?.isNotEmpty ?? false)
        && (env?.isNotEmpty ?? false);

    if (!isValid) {
      logWarning(
        'SentryEcosystemMixin::setUpSentry: config invalid '
        '(enabled=${ecosystemConfig.enabled}, dsn=${dsn?.isNotEmpty}, env=${env?.isNotEmpty})',
      );
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
