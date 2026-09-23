import 'dart:async';

import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/sentry/sentry_config.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/features/base/sentry_session_cleanup.dart';
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

class SentryEcosystem implements SentrySessionCleanup {
  final SentryConfigurationCacheManager? _cacheManager;
  final IOSSharingManager? _iosSharingManager;
  final InitializeSentry _initializeSentry;

  SentryUser? _sentryUser;
  SentryConfig? _sentryConfig;
  Future<void> _pendingConsentPersistence = Future.value();
  int _configurationGeneration = 0;

  SentryEcosystem(
    this._cacheManager,
    this._iosSharingManager, {
    InitializeSentry? initializeSentry,
  }) : _initializeSentry = initializeSentry ??
            SentryManager.instance.initializeWithSentryConfig;

  void initUser(SentryUser? user) {
    _configurationGeneration++;
    _sentryUser = user;
  }

  Future<void> setUp(SentryConfigLinagoraEcosystem ecosystemConfig) async {
    final configurationGeneration = ++_configurationGeneration;
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
      await clear(clearUser: false);
      return;
    }

    final sentryUser = _sentryUser;
    final sentryConfig = await ecosystemConfig.toSentryConfig();
    if (!_isCurrentConfiguration(configurationGeneration)) return;

    await _initializeSentry(sentryConfig);
    if (!_isCurrentConfiguration(configurationGeneration)) return;

    _applyUser(sentryUser);

    final configToPersist = sentryConfig.withReportingAllowed(
      SentryManager.instance.isSentryReportingAllowed,
    );
    _sentryConfig = configToPersist;
    final pendingPersistence = _pendingConsentPersistence.then(
      (_) => _persistSetupConfiguration(
        configToPersist,
        sentryUser,
        configurationGeneration,
      ),
    );
    _pendingConsentPersistence = pendingPersistence.catchError((_) {});
    await pendingPersistence;
  }

  void _applyUser(SentryUser? sentryUser) {
    if (sentryUser == null) return;
    SentryManager.instance.setUser(sentryUser);
  }

  Future<void> updateReportingConsent(bool? consent) async {
    SentryManager.instance.setSentryReportingConsent(consent);
    final pendingLifecycle = SentryManager.instance.pendingLifecycleTransition;
    final isReportingAllowed = SentryManager.instance.isSentryReportingAllowed;
    final configurationGeneration = _configurationGeneration;
    final pendingPersistence = _pendingConsentPersistence.then(
      (_) => _persistReportingConsent(
        isReportingAllowed,
        configurationGeneration,
      ),
    );
    _pendingConsentPersistence = pendingPersistence.catchError((_) {});
    await Future.wait([pendingLifecycle, pendingPersistence]);
  }

  Future<void> _persistReportingConsent(
    bool isReportingAllowed,
    int configurationGeneration,
  ) async {
    if (!_isCurrentConfiguration(configurationGeneration)) return;
    // Before setUp completes, the cache still belongs to the previous account.
    // Leave its fail-closed value untouched; setUp will publish this account's
    // config and identity together.
    if (_sentryConfig == null) return;

    final currentConfig = _sentryConfig!;
    SentryConfig updatedConfig;
    try {
      final updatedCache = await _cacheManager
          ?.updateSentryReportingAllowed(isReportingAllowed);
      updatedConfig = updatedCache?.toSentryConfig() ??
          currentConfig.withReportingAllowed(false);
    } catch (e, st) {
      logError(
        'SentryEcosystem::_persistReportingConsent: Cannot update cached reporting consent',
        exception: e,
        stackTrace: st,
      );
      final configToShare = currentConfig.withReportingAllowed(false);
      await _publishSentryConfig(
        configToShare,
        configurationGeneration,
      );
      rethrow;
    }

    if (!_isCurrentConfiguration(configurationGeneration)) return;
    final configToShare = _withLiveReportingConsent(updatedConfig);
    await _publishSentryConfig(
      configToShare,
      configurationGeneration,
    );
  }

  Future<void> _persistSetupConfiguration(
    SentryConfig configToPersist,
    SentryUser? sentryUser,
    int configurationGeneration,
  ) async {
    if (!_isCurrentConfiguration(configurationGeneration)) return;
    bool isReportingAllowedPersisted;
    try {
      isReportingAllowedPersisted =
          await _cacheData(configToPersist, sentryUser);
    } catch (_) {
      await _publishSentryConfig(
        configToPersist.withReportingAllowed(false),
        configurationGeneration,
      );
      rethrow;
    }

    if (!_isCurrentConfiguration(configurationGeneration)) return;
    final configToShare = _withLiveReportingConsent(
      configToPersist.withReportingAllowed(isReportingAllowedPersisted),
    );
    await _publishSentryConfig(
      configToShare,
      configurationGeneration,
    );
  }

  Future<bool> _cacheData(SentryConfig sentryConfig, SentryUser? sentryUser) async {
    if (_cacheManager == null) return false;
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
      if (sentryConfig.isReportingAllowed &&
          SentryManager.instance.isSentryReportingAllowed) {
        await _cacheManager.saveSentryConfiguration(
          sentryConfig.toSentryConfigurationCache(),
        );
        return true;
      }
    } catch (e, st) {
      logError(
        'SentryEcosystem::_cacheData: Cannot cache Sentry data',
        exception: e,
        stackTrace: st,
      );
      // Clear both caches to avoid stale/inconsistent state (e.g. new config + old user PII)
      await _cacheManager.clearSentryConfiguration();
    }
    return false;
  }

  SentryConfig _withLiveReportingConsent(SentryConfig sentryConfig) {
    return sentryConfig.withReportingAllowed(
      sentryConfig.isReportingAllowed &&
          SentryManager.instance.isSentryReportingAllowed,
    );
  }

  bool _isCurrentConfiguration(int configurationGeneration) =>
      configurationGeneration == _configurationGeneration;

  Future<void> _publishSentryConfig(
    SentryConfig sentryConfig,
    int configurationGeneration,
  ) async {
    if (!_isCurrentConfiguration(configurationGeneration)) return;
    if (PlatformInfo.isIOS) {
      await _saveSentryConfigToKeychain(sentryConfig);
    }
    if (_isCurrentConfiguration(configurationGeneration)) {
      _sentryConfig = sentryConfig;
    }
  }

  Future<void> _saveSentryConfigToKeychain(SentryConfig sentryConfig) async {
    await _iosSharingManager?.saveSentryConfigToKeychain(sentryConfig);
  }

  Future<void> clear({bool clearUser = true}) {
    _configurationGeneration++;
    _sentryConfig = null;
    if (clearUser) {
      _sentryUser = null;
    }

    final pendingClear = _pendingConsentPersistence.then((_) async {
      if (PlatformInfo.isIOS) {
        await _iosSharingManager?.deleteSentryConfigFromKeychain();
      }
    });
    _pendingConsentPersistence = pendingClear.catchError((_) {});
    return pendingClear;
  }

  @override
  Future<void> clearForSessionEnd() async {
    await Future.wait([
      SentryManager.instance.clearSessionContext(),
      clear(),
    ]);
  }
}
