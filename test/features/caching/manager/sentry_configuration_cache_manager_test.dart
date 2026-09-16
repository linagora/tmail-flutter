import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/caching/clients/sentry_configuration_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/sentry_user_cache_client.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_configuration_cache.dart';
import 'package:tmail_ui_user/features/caching/manager/sentry_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

import 'sentry_configuration_cache_manager_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SentryConfigurationCacheClient>(),
  MockSpec<SentryUserCacheClient>(),
])
void main() {
  const configKey = CachingConstants.sentryConfigurationCacheKeyName;
  final current = SentryConfigurationCache(
    dsn: 'https://public@example.com/1',
    environment: 'staging',
    release: '1.2.3',
    tracesSampleRate: 0.2,
    profilesSampleRate: 0.3,
    enableLogs: false,
    isDebug: true,
    attachScreenshot: true,
    isAvailable: true,
    sessionSampleRate: 0.4,
    onErrorSampleRate: 0.5,
    enableFramesTracking: false,
    dist: 'abc123',
    isReportingAllowed: true,
  );

  late MockSentryConfigurationCacheClient configurationClient;
  late MockSentryUserCacheClient userClient;
  late SentryConfigurationCacheManager manager;

  setUp(() {
    configurationClient = MockSentryConfigurationCacheClient();
    userClient = MockSentryUserCacheClient();
    manager = SentryConfigurationCacheManager(
      configurationClient,
      userClient,
    );
  });

  test('updates reporting consent without changing the rest of the cached config', () async {
    when(configurationClient.getItem(configKey))
        .thenAnswer((_) async => current);
    when(configurationClient.insertItem(configKey, any))
        .thenAnswer((_) async {});

    final result = await manager.updateSentryReportingAllowed(false);
    final inserted = verify(
      configurationClient.insertItem(configKey, captureAny),
    ).captured.single as SentryConfigurationCache;

    expect(result, inserted);
    expect(inserted.dsn, current.dsn);
    expect(inserted.environment, current.environment);
    expect(inserted.release, current.release);
    expect(inserted.tracesSampleRate, current.tracesSampleRate);
    expect(inserted.profilesSampleRate, current.profilesSampleRate);
    expect(inserted.enableLogs, current.enableLogs);
    expect(inserted.isDebug, current.isDebug);
    expect(inserted.attachScreenshot, current.attachScreenshot);
    expect(inserted.isAvailable, current.isAvailable);
    expect(inserted.sessionSampleRate, current.sessionSampleRate);
    expect(inserted.onErrorSampleRate, current.onErrorSampleRate);
    expect(inserted.enableFramesTracking, current.enableFramesTracking);
    expect(inserted.dist, current.dist);
    expect(inserted.isReportingAllowed, isFalse);
  });

  test('clears both caches when an opt-out cannot be saved', () async {
    when(configurationClient.getItem(configKey))
        .thenAnswer((_) async => current);
    when(configurationClient.insertItem(configKey, any))
        .thenThrow(StateError('write failed'));
    when(configurationClient.clearAllData())
        .thenAnswer((_) async {});
    when(userClient.clearAllData())
        .thenAnswer((_) async {});

    final result = await manager.updateSentryReportingAllowed(false);

    expect(result, isNull);
    verify(configurationClient.clearAllData()).called(1);
    verify(userClient.clearAllData()).called(1);
  });

  test('still clears the user cache when clearing the config cache fails', () async {
    when(configurationClient.getItem(configKey))
        .thenThrow(StateError('read failed'));
    when(configurationClient.clearAllData())
        .thenThrow(StateError('config clear failed'));
    when(userClient.clearAllData())
        .thenAnswer((_) async {});

    final result = await manager.updateSentryReportingAllowed(false);

    expect(result, isNull);
    verify(configurationClient.clearAllData()).called(1);
    verify(userClient.clearAllData()).called(1);
  });

  test('keeps the existing caches when an opt-in cannot be saved', () async {
    when(configurationClient.getItem(configKey))
        .thenThrow(StateError('read failed'));

    final result = await manager.updateSentryReportingAllowed(true);

    expect(result, isNull);
    verifyNever(configurationClient.clearAllData());
    verifyNever(userClient.clearAllData());
  });
}
