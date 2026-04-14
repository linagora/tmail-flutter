import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/features/caching/extensions/sentry_cache_extensions.dart';
import 'package:tmail_ui_user/features/caching/manager/sentry_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/sentry_config_linagora_ecosystem.dart';

class SentryEcosystem {
  final SentryConfigurationCacheManager? _cacheManager;

  SentryUser? _sentryUser;

  SentryEcosystem(this._cacheManager);

  void initUser(SentryUser? user) {
    _sentryUser = user;
  }

  Future<void> setUp(SentryConfigLinagoraEcosystem ecosystemConfig) async {
    final dsn = ecosystemConfig.dsn?.trimmed;
    final env = ecosystemConfig.environment?.trimmed;
    final isValid = ecosystemConfig.enabled == true
        && (dsn?.isNotEmpty ?? false)
        && (env?.isNotEmpty ?? false);

    if (!isValid) {
      logWarning(
        'SentryEcosystem::setUp: config invalid '
        '(enabled=${ecosystemConfig.enabled}, dsn=${dsn?.isNotEmpty}, env=${env?.isNotEmpty})',
      );
      return;
    }

    final sentryConfig = await ecosystemConfig.toSentryConfig();

    await SentryManager.instance.initializeWithSentryConfig(sentryConfig);

    _applyUser();

    await _cacheData(sentryConfig, _sentryUser);
  }

  void _applyUser() {
    if (_sentryUser == null) return;
    SentryManager.instance.setUser(_sentryUser!);
  }

  Future<void> _cacheData(SentryConfig sentryConfig, SentryUser? sentryUser) async {
    if (_cacheManager == null) return;
    try {
      await _cacheManager!.saveSentryConfiguration(sentryConfig.toSentryConfigurationCache());
      if (sentryUser != null) {
        await _cacheManager!.saveSentryUser(sentryUser.toSentryUserCache());
      }
    } catch (e, st) {
      logError(
        'SentryEcosystem::_cacheData: Cannot cache Sentry data',
        exception: e,
        stackTrace: st,
      );
      // Clear both caches to avoid stale/inconsistent state (e.g. new config + old user PII)
      await _cacheManager!.clearSentryConfiguration().catchError((_) {});
    }
  }
}
