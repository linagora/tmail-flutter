import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/sentry_config_linagora_ecosystem.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

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
      await clearSentryConfiguration();
      return;
    }

    final dsn = ecosystemConfig.dsn?.trimmed;
    final env = ecosystemConfig.environment?.trimmed;

    if (dsn == null || dsn.isEmpty) {
      logWarning(
          'SentryEcosystemMixin::setUpSentry: Sentry DSN is invalid (null or empty)');
      await clearSentryConfiguration();
      return;
    }

    if (env == null || env.isEmpty) {
      logWarning(
          'SentryEcosystemMixin::setUpSentry: Sentry Environment is invalid (null or empty)');
      await clearSentryConfiguration();
      return;
    }

    final sentryConfig = await ecosystemConfig.toSentryConfig();

    await SentryManager.instance.initializeWithSentryConfig(sentryConfig);

    _setupSentryUser();

    await _saveSentryConfiguration(
      sentryConfig: sentryConfig,
      sentryUser: _sentryUser,
    );

    if (PlatformInfo.isIOS) {
      _saveSentryConfigToKeychain(sentryConfig);
    }
  }

  void _setupSentryUser() {
    if (_sentryUser == null) return;

    SentryManager.instance.setUser(_sentryUser!);
  }

  Future<void> _saveSentryConfiguration({
    required SentryConfig sentryConfig,
    SentryUser? sentryUser,
  }) async {
    final cachingManager = getBinding<CachingManager>();
    if (cachingManager != null) {
      await cachingManager.saveSentryConfiguration(sentryConfig);

      if (sentryUser != null) {
        await cachingManager.saveSentryUser(sentryUser);
      }
    } else {
      logTrace(
          'SentryEcosystemMixin::saveSentryConfiguration: CachingManager is null');
    }
  }

  Future<void> clearSentryConfiguration() async {
    final cachingManager = getBinding<CachingManager>();
    if (cachingManager != null) {
      await cachingManager.clearSentryConfiguration();
    } else {
      logTrace(
          'SentryEcosystemMixin::clearSentryConfiguration: CachingManager is null');
    }
  }

  void _saveSentryConfigToKeychain(SentryConfig sentryConfig) {
    final iOSSharingManager = getBinding<IOSSharingManager>();
    iOSSharingManager?.saveSentryConfigToKeychain(sentryConfig);
  }
}
