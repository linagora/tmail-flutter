import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/resolve_composer_cache_for_restore_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/resolve_composer_cache_for_restore_interactor.dart';

import 'resolve_composer_cache_for_restore_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ComposerCacheRepository>()])
void main() {
  final accountId = AccountId(Id('account-1'));
  final userName = UserName('user@example.com');

  late MockComposerCacheRepository mockRepository;
  late ResolveComposerCacheForRestoreInteractor interactor;

  setUp(() {
    mockRepository = MockComposerCacheRepository();
    interactor = ResolveComposerCacheForRestoreInteractor(mockRepository);
  });

  ComposerPersistentCache makeCache({
    bool? isCleanClose,
    int? timestampMs,
    bool withEmail = true,
  }) =>
      ComposerPersistentCache(
        isCleanClose: isCleanClose,
        timestampMs: timestampMs ?? DateTime.now().millisecondsSinceEpoch,
        email: withEmail ? Email() : null,
      );

  void expectRightWithNullCache(Object result) {
    (result as dynamic).fold(
      (_) => fail('expected Right'),
      (s) => expect((s as ResolveComposerCacheForRestoreSuccess).cache, isNull),
    );
  }

  void expectRightWithoutRemoveAll(
    Object result, {
    ComposerPersistentCache? expectedCache,
  }) {
    verifyNever(mockRepository.removeAllComposerCache(any, any));
    (result as dynamic).fold(
      (_) => fail('expected Right'),
      (s) {
        expect(s, isA<ResolveComposerCacheForRestoreSuccess>());
        expect(
          (s as ResolveComposerCacheForRestoreSuccess).cache,
          expectedCache == null ? isNull : same(expectedCache),
        );
      },
    );
  }

  group('ResolveComposerCacheForRestoreInteractor', () {
    group('when no cache entry exists', () {
      test('returns Right with null cache and does not call removeAll', () async {
        when(mockRepository.getComposerCache(accountId, userName))
            .thenAnswer((_) async => []);

        final result = await interactor.execute(accountId, userName);

        expectRightWithoutRemoveAll(result);
      });
    });

    group('when cache is not restorable', () {
      setUp(() {
        when(mockRepository.removeAllComposerCache(accountId, userName))
            .thenAnswer((_) async {});
      });

      final testCases = [
        (
          description: 'isCleanClose is true',
          makeCache: () => ComposerPersistentCache(
            isCleanClose: true,
            timestampMs: DateTime.now().millisecondsSinceEpoch,
            email: Email(),
          ),
        ),
        (
          description: 'cache is expired',
          makeCache: () => ComposerPersistentCache(
            timestampMs: DateTime.now()
                .subtract(const Duration(hours: 25))
                .millisecondsSinceEpoch,
            email: Email(),
          ),
        ),
        (
          description: 'email is null (empty snapshot)',
          makeCache: () => ComposerPersistentCache(
            timestampMs: DateTime.now().millisecondsSinceEpoch,
          ),
        ),
      ];

      for (final tc in testCases) {
        test('removes all and returns null when ${tc.description}', () async {
          when(mockRepository.getComposerCache(accountId, userName))
              .thenAnswer((_) async => [tc.makeCache()]);

          final result = await interactor.execute(accountId, userName);

          verify(mockRepository.removeAllComposerCache(accountId, userName)).called(1);
          expectRightWithNullCache(result);
        });
      }
    });

    group('when cache is restorable', () {
      test('returns the cache without calling removeAll', () async {
        final cache = makeCache(isCleanClose: false);
        when(mockRepository.getComposerCache(accountId, userName))
            .thenAnswer((_) async => [cache]);

        final result = await interactor.execute(accountId, userName);

        expectRightWithoutRemoveAll(result, expectedCache: cache);
      });

      test('returns the newest cache when multiple entries exist', () async {
        final older = makeCache(
          isCleanClose: false,
          timestampMs: DateTime.now()
              .subtract(const Duration(hours: 1))
              .millisecondsSinceEpoch,
        );
        final newer = makeCache(
          isCleanClose: false,
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        );
        when(mockRepository.getComposerCache(accountId, userName))
            .thenAnswer((_) async => [older, newer]);

        final result = await interactor.execute(accountId, userName);

        result.fold(
          (_) => fail('expected Right'),
          (s) => expect(
            (s as ResolveComposerCacheForRestoreSuccess).cache,
            same(newer),
          ),
        );
      });
    });

    group('error handling', () {
      test('returns Left(ResolveComposerCacheForRestoreFailure) when repository throws', () async {
        final exception = Exception('db error');
        when(mockRepository.getComposerCache(accountId, userName))
            .thenThrow(exception);

        final result = await interactor.execute(accountId, userName);

        result.fold(
          (f) {
            expect(f, isA<ResolveComposerCacheForRestoreFailure>());
            expect(
              (f as ResolveComposerCacheForRestoreFailure).exception,
              exception,
            );
          },
          (_) => fail('expected Left'),
        );
      });
    });

    test('returns the cache when isCleanClose is null (crash snapshot)', () async {
      final cache = makeCache(isCleanClose: null);  // null means clean-close was never written
      when(mockRepository.getComposerCache(accountId, userName))
          .thenAnswer((_) async => [cache]);

      final result = await interactor.execute(accountId, userName);

      expectRightWithoutRemoveAll(result, expectedCache: cache);
    });
  });
}
