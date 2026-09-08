import 'package:core/utils/app_logger.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/entity/workplace_intent_config.dart';
import 'package:workplace/presentation/intent_fetcher/drive_intent_fetcher.dart';

/// Tries [fetchers] in order; a failing one hands over to the next available.
/// Only the last available fetcher's error reaches the caller.
class FallbackDriveIntentFetcher implements DriveIntentFetcher {
  final List<DriveIntentFetcher> fetchers;

  const FallbackDriveIntentFetcher(this.fetchers);

  @override
  bool get isAvailable => fetchers.any((fetcher) => fetcher.isAvailable);

  @override
  Future<WorkplaceIntent> fetchIntent(
    Uri platformUrl,
    WorkplaceIntentConfig config,
  ) async {
    final candidates = fetchers.where((fetcher) => fetcher.isAvailable).toList();
    if (candidates.isEmpty) {
      throw StateError('No Drive intent fetcher is available');
    }
    for (final fetcher in candidates.take(candidates.length - 1)) {
      try {
        return await fetcher.fetchIntent(platformUrl, config);
      } catch (e) {
        logWarning(
          'FallbackDriveIntentFetcher::fetchIntent: ${fetcher.runtimeType} failed, trying next fetcher: $e',
          webConsoleEnabled: true,
        );
      }
    }
    return candidates.last.fetchIntent(platformUrl, config);
  }
}
