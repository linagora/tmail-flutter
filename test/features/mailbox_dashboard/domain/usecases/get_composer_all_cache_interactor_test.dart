import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_all_composer_cache_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_composer_cache_interactor.dart';

import 'get_composer_local_cache_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ComposerCacheRepository>()])
void main() {
  final accountId = AccountId(Id('account-1'));
  final userName = UserName('user@example.com');

  late MockComposerCacheRepository mockRepository;
  late GetAllComposerCacheInteractor interactor;

  setUp(() {
    mockRepository = MockComposerCacheRepository();
    interactor = GetAllComposerCacheInteractor(mockRepository);
  });

  ComposerPersistentCache makeLocalCache({
    required int timestampMs,
    bool withEmail = true,
  }) =>
      ComposerPersistentCache(
        timestampMs: timestampMs,
        email: withEmail ? Email() : null,
      );

  int msAgo(int hours) =>
      DateTime.now().subtract(Duration(hours: hours)).millisecondsSinceEpoch;

  void expectSuccessWithCache(
    Either result,
    ComposerPersistentCache expectedCache,
  ) {
    result.fold(
      (_) => fail('expected Right'),
      (s) => expect((s as GetAllComposerCacheSuccess).listComposerCache,
          contains(expectedCache)),
    );
  }

  group('GetComposerLocalCacheInteractor', () {
    group('when repository returns a single local cache', () {
      test('returns success with that cache', () async {
        final cache = makeLocalCache(timestampMs: msAgo(1));
        when(mockRepository.getComposerCache(accountId, userName))
            .thenAnswer((_) async => [cache]);

        final result = await interactor.execute(accountId, userName).last;

        expectSuccessWithCache(result, cache);
      });
    });

    group('when repository returns multiple local caches', () {
      test('returns the most recent one by timestampMs', () async {
        final older = makeLocalCache(timestampMs: msAgo(3));
        final newer = makeLocalCache(timestampMs: msAgo(1));
        when(mockRepository.getComposerCache(accountId, userName))
            .thenAnswer((_) async => [older, newer]);

        final result = await interactor.execute(accountId, userName).last;

        expectSuccessWithCache(result, newer);
      });

      test(
          'ignores plain ComposerCache entries and picks newest ComposerPersistentCache',
          () async {
        final plainCache = ComposerCache(email: Email());
        final localCache = makeLocalCache(timestampMs: msAgo(1));
        when(mockRepository.getComposerCache(accountId, userName))
            .thenAnswer((_) async => [plainCache, localCache]);

        final result = await interactor.execute(accountId, userName).last;

        expectSuccessWithCache(result, localCache);
      });
    });

    group('error handling', () {
      test('wraps repository exception in GetComposerLocalCacheFailure',
          () async {
        final exception = Exception('db error');
        when(mockRepository.getComposerCache(accountId, userName))
            .thenThrow(exception);

        final result = await interactor.execute(accountId, userName).last;

        result.fold(
          (f) {
            expect(f, isA<GetAllComposerCacheFailure>());
            expect((f as GetAllComposerCacheFailure).exception, exception);
          },
          (_) => fail('expected Left'),
        );
      });
    });
  });
}
