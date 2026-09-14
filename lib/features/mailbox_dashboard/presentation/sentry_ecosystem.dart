import 'dart:async';

import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/features/caching/extensions/sentry_cache_extensions.dart';
import 'package:tmail_ui_user/features/caching/manager/sentry_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/sentry_config_linagora_ecosystem.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

typedef InitializeSentry = Future<void> Function(SentryConfig sentryConfig);

void applySentryReportingConsent(
  SentryEcosystem? sentryEcosystem,
  bool? consent,
) {
  if (sentryEcosystem != null) {
    unawaited(sentryEcosystem.updateReportingConsent(consent));
    return;
  }
  SentryManager.instance.setSentryReportingConsent(consent);
}

class SentryEcosystem {
  final SentryConfigurationCacheManager? _cacheManager;
  final IOSSharingManager? _iosSharingManager;
  final InitializeSentry _initializeSentry;

  SentryUser? _sentryUser;
  SentryConfig? _sentryConfig;
  Future<void> _pendingConsentPersistence = Future.value();

  SentryEcosystem(
    this._cacheManager,
    this._iosSharingManager, {
    InitializeSentry? initializeSentry,
  }) : _initializeSentry = initializeSentry ??
            SentryManager.instance.initializeWithSentryConfig;

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

    SentryManager.instance
        .setSentryReportingDefault(ecosystemConfig.isUserOptedInByDefault);

    final sentryConfig = await ecosystemConfig.toSentryConfig(
      isReportingAllowed:
          SentryManager.instance.isSentryReportingAllowed,
    );

    await _initializeSentry(sentryConfig);

    _applyUser();

    final configToPersist = sentryConfig.withReportingAllowed(
      SentryManager.instance.isSentryReportingAllowed,
    );
    _sentryConfig = configToPersist;
    _pendingConsentPersistence = _pendingConsentPersistence.then((_) async {
      await _cacheData(configToPersist, _sentryUser);
      if (PlatformInfo.isIOS) {
        await _saveSentryConfigToKeychain(configToPersist);
      }
    });
    await _pendingConsentPersistence;
  }

  void _applyUser() {
    if (_sentryUser == null) return;
    SentryManager.instance.setUser(_sentryUser!);
  }

  Future<void> updateReportingConsent(bool? consent) {
    SentryManager.instance.setSentryReportingConsent(consent);
    final isReportingAllowed =
        SentryManager.instance.isSentryReportingAllowed;
    _pendingConsentPersistence = _pendingConsentPersistence.then(
      (_) => _persistReportingConsent(isReportingAllowed),
    );
    return _pendingConsentPersistence;
  }

  Future<void> _persistReportingConsent(bool isReportingAllowed) async {
    // Before setUp completes, the cache still belongs to the previous account.
    // Leave its fail-closed value untouched; setUp will publish this account's
    // config and identity together.
    if (_sentryConfig == null) return;

    final updatedCache = await _cacheManager
        ?.updateSentryReportingAllowed(isReportingAllowed);
    final updatedConfig = updatedCache?.toSentryConfig() ??
        _sentryConfig?.withReportingAllowed(isReportingAllowed);
    if (updatedConfig == null) return;

    _sentryConfig = updatedConfig;
    if (PlatformInfo.isIOS) {
      await _saveSentryConfigToKeychain(updatedConfig);
    }
  }

  Future<void> _cacheData(SentryConfig sentryConfig, SentryUser? sentryUser) async {
    if (_cacheManager == null) return;
    try {
      // Treat the allowed config as the commit marker. During an account
      // switch, background workers must see reporting denied until the new
      // identity and its effective consent are both cached.
      await _cacheManager.saveSentryConfiguration(
        sentryConfig
            .withReportingAllowed(false)
            .toSentryConfigurationCache(),
      );
      if (sentryUser != null) {
        await _cacheManager.saveSentryUser(sentryUser.toSentryUserCache());
      }
      if (sentryConfig.isReportingAllowed) {
        await _cacheManager.saveSentryConfiguration(
          sentryConfig.toSentryConfigurationCache(),
        );
      }
    } catch (e, st) {
      logError(
        'SentryEcosystem::_cacheData: Cannot cache Sentry data',
        exception: e,
        stackTrace: st,
      );
      // Clear both caches to avoid stale/inconsistent state (e.g. new config + old user PII)
      await _cacheManager.clearSentryConfiguration().catchError((_) {});
    }
  }

  Future<void> _saveSentryConfigToKeychain(SentryConfig sentryConfig) async {
    await _iosSharingManager?.saveSentryConfigToKeychain(sentryConfig);
  }
}
