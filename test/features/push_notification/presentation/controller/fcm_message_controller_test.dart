import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_configuration_cache.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_user_cache.dart';
import 'package:tmail_ui_user/features/caching/manager/sentry_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_message_controller.dart';

class _FakeCacheManager implements SentryConfigurationCacheManager {
  _FakeCacheManager(this.configuration);

  final SentryConfigurationCache configuration;
  int userReads = 0;

  @override
  Future<SentryConfigurationCache> getSentryConfiguration() async =>
      configuration;

  @override
  Future<SentryUserCache> getSentryUser() async {
    userReads++;
    return SentryUserCache(
      id: 'account-a',
      name: '',
      username: '',
      email: '',
    );
  }

  @override
  Future<void> saveSentryConfiguration(
    SentryConfigurationCache sentryConfigurationCache,
  ) async {}

  @override
  Future<void> saveSentryUser(SentryUserCache sentryUserCache) async {}

  @override
  Future<SentryConfigurationCache?> updateSentryReportingAllowed(
    bool isReportingAllowed,
  ) async =>
      null;

  @override
  Future<void> clearSentryConfiguration() async {}
}

void main() {
  final sentryManager = SentryManager.instance;

  tearDown(() {
    Get.deleteAll();
    sentryManager.setSentryReportingConsent(null);
  });

  test('background isolate does not initialize Sentry without consent', () async {
    final cacheManager = _FakeCacheManager(SentryConfigurationCache(
      dsn: 'https://test@sentry.io/123',
      environment: 'test',
      release: '1.0.0',
      tracesSampleRate: 0.1,
      profilesSampleRate: 0.1,
      enableLogs: true,
      isDebug: false,
      attachScreenshot: false,
      isAvailable: true,
      sessionSampleRate: null,
      onErrorSampleRate: null,
      enableFramesTracking: true,
      dist: null,
      isReportingAllowed: false,
    ));
    Get.put<SentryConfigurationCacheManager>(cacheManager);
    sentryManager.setSentryReportingConsent(true);

    await FcmMessageController.instance.setUpSentryConfiguration();

    expect(sentryManager.isSentryReportingAllowed, isFalse);
    expect(cacheManager.userReads, 0);
  });
}
