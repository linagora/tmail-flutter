import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/domain/entity/workplace_action_config.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/entity/workplace_intent_config.dart';
import 'package:workplace/domain/entity/workplace_theme.dart';
import 'package:workplace/presentation/intent_fetcher/drive_intent_fetcher.dart';
import 'package:workplace/presentation/intent_fetcher/fallback_drive_intent_fetcher.dart';

class _FakeFetcher implements DriveIntentFetcher {
  @override
  final bool isAvailable;
  final WorkplaceIntent? intent;
  final Object? error;
  int calls = 0;

  _FakeFetcher({this.isAvailable = true, this.intent, this.error});

  @override
  Future<WorkplaceIntent> fetchIntent(Uri platformUrl, WorkplaceIntentConfig config) async {
    calls++;
    if (error != null) throw error!;
    return intent!;
  }
}

final _platformUrl = Uri.parse('https://platform.example.com');
const _config = WorkplaceIntentConfig(
  addAsLink: WorkplaceActionConfig(label: 'Link'),
  theme: WorkplaceTheme.light,
);
WorkplaceIntent _intent(String id) => WorkplaceIntent(
      intentId: id,
      intentUrl: Uri.parse('https://drive.example.com/$id'),
    );

void main() {
  group('FallbackDriveIntentFetcher::', () {
    test('isAvailable is true when any fetcher is available', () {
      final fetcher = FallbackDriveIntentFetcher([
        _FakeFetcher(isAvailable: false),
        _FakeFetcher(isAvailable: true, intent: _intent('b')),
      ]);
      expect(fetcher.isAvailable, isTrue);
    });

    test('isAvailable is false when no fetcher is available', () {
      final fetcher = FallbackDriveIntentFetcher([_FakeFetcher(isAvailable: false)]);
      expect(fetcher.isAvailable, isFalse);
    });

    test('returns from the first available fetcher without calling the next', () async {
      final first = _FakeFetcher(intent: _intent('first'));
      final second = _FakeFetcher(intent: _intent('second'));

      final result = await FallbackDriveIntentFetcher([first, second])
          .fetchIntent(_platformUrl, _config);

      expect(result.intentId, equals('first'));
      expect(second.calls, equals(0));
    });

    test('skips unavailable fetchers', () async {
      final unavailable = _FakeFetcher(isAvailable: false, intent: _intent('skip'));
      final second = _FakeFetcher(intent: _intent('second'));

      final result = await FallbackDriveIntentFetcher([unavailable, second])
          .fetchIntent(_platformUrl, _config);

      expect(result.intentId, equals('second'));
      expect(unavailable.calls, equals(0));
    });

    test('falls through to the next fetcher when one throws', () async {
      final failing = _FakeFetcher(error: StateError('boom'));
      final second = _FakeFetcher(intent: _intent('second'));

      final result = await FallbackDriveIntentFetcher([failing, second])
          .fetchIntent(_platformUrl, _config);

      expect(result.intentId, equals('second'));
      expect(failing.calls, equals(1));
    });

    test('propagates the last available fetcher error', () async {
      final failing = _FakeFetcher(error: StateError('first'));
      final last = _FakeFetcher(error: ArgumentError('last'));

      await expectLater(
        FallbackDriveIntentFetcher([failing, last]).fetchIntent(_platformUrl, _config),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws StateError when no fetcher is available', () async {
      await expectLater(
        FallbackDriveIntentFetcher([_FakeFetcher(isAvailable: false)])
            .fetchIntent(_platformUrl, _config),
        throwsA(isA<StateError>()),
      );
    });
  });
}
