import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'sentry_configuration_cache.g.dart';

@HiveType(typeId: CachingConstants.SENTRY_CONFIGURATION_CACHE_ID)
class SentryConfigurationCache extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String dsn;

  @HiveField(1)
  final String environment;

  @HiveField(2)
  final String release;

  @HiveField(3)
  final double tracesSampleRate;

  @HiveField(4)
  final double profilesSampleRate;

  @HiveField(5)
  final bool enableLogs;

  @HiveField(6)
  final bool isDebug;

  @HiveField(7)
  final bool attachScreenshot;

  @HiveField(8)
  final bool isAvailable;

  @HiveField(9)
  final double sessionSampleRate;

  @HiveField(10)
  final double onErrorSampleRate;

  @HiveField(11)
  final bool enableFramesTracking;

  SentryConfigurationCache({
    required this.dsn,
    required this.environment,
    required this.release,
    required this.tracesSampleRate,
    required this.profilesSampleRate,
    required this.enableLogs,
    required this.isDebug,
    required this.attachScreenshot,
    required this.isAvailable,
    required this.sessionSampleRate,
    required this.onErrorSampleRate,
    required this.enableFramesTracking,
  });

  @override
  List<Object?> get props => [
        dsn,
        environment,
        release,
        tracesSampleRate,
        profilesSampleRate,
        enableLogs,
        isDebug,
        attachScreenshot,
        isAvailable,
        sessionSampleRate,
        onErrorSampleRate,
        enableFramesTracking,
      ];
}
