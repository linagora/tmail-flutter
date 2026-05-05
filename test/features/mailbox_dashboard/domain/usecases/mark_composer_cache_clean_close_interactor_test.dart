import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/mark_composer_cache_clean_close_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/mark_composer_cache_clean_close_interactor.dart';

import 'mark_composer_local_cache_clean_close_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ComposerCacheRepository>()])
void main() {
  final accountId = AccountId(Id('account-1'));
  final userName = UserName('user@example.com');

  late MockComposerCacheRepository mockRepository;
  late MarkComposerCacheCleanCloseInteractor interactor;

  setUp(() {
    mockRepository = MockComposerCacheRepository();
    interactor = MarkComposerCacheCleanCloseInteractor(mockRepository);
  });

  ComposerPersistentCache makeLocalCache(
          {bool? isCleanClose, int? timestampMs}) =>
      ComposerPersistentCache(
        isCleanClose: isCleanClose,
        timestampMs: timestampMs ?? DateTime.now().millisecondsSinceEpoch,
        email: Email(),
      );

  group('MarkComposerCacheCleanCloseInteractor', () {
    group('normal flow', () {
      test('marks newest cache with isCleanClose=true then removes all',
          () async {
        final cache = makeLocalCache(isCleanClose: false);
        when(mockRepository.getComposerCache(accountId, userName))
            .thenAnswer((_) async => [cache]);
        when(mockRepository.saveComposerCache(
          accountId,
          userName,
          anyNamed('composerCache'),
        )).thenAnswer((_) async {});
        when(mockRepository.removeAllComposerCache(accountId, userName))
            .thenAnswer((_) async {});

        final result = await interactor.execute(accountId, userName);

        expect(result, Right(MarkComposerCacheCleanCloseSuccess()));

        final captured = verify(mockRepository.saveComposerCache(
          accountId,
          userName,
          captureAnyNamed('composerCache'),
        )).captured.single as ComposerPersistentCache;
        expect(captured.isCleanClose, isTrue);

        verify(mockRepository.removeAllComposerCache(accountId, userName))
            .called(1);
      });

      test('picks newest by timestampMs when multiple entries exist', () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        final older = makeLocalCache(timestampMs: now - 5000);
        final newer = makeLocalCache(timestampMs: now);
        when(mockRepository.getComposerCache(accountId, userName))
            .thenAnswer((_) async => [older, newer]);
        when(mockRepository.saveComposerCache(
          accountId,
          userName,
          anyNamed('composerCache'),
        )).thenAnswer((_) async {});
        when(mockRepository.removeAllComposerCache(accountId, userName))
            .thenAnswer((_) async {});

        await interactor.execute(accountId, userName);

        final captured = verify(mockRepository.saveComposerCache(
          accountId,
          userName,
          captureAnyNamed('composerCache'),
        )).captured.single as ComposerPersistentCache;
        expect(captured.timestampMs, newer.timestampMs);
      });
    });

    group('best-effort mark: save failure does not block removal', () {
      test('still removes all when mark write throws', () async {
        final cache = makeLocalCache();
        when(mockRepository.getComposerCache(accountId, userName))
            .thenAnswer((_) async => [cache]);
        when(mockRepository.saveComposerCache(
          accountId,
          userName,
          anyNamed('composerCache'),
        )).thenThrow(Exception('write failed'));
        when(mockRepository.removeAllComposerCache(accountId, userName))
            .thenAnswer((_) async {});

        final result = await interactor.execute(accountId, userName);

        expect(result, Right(MarkComposerCacheCleanCloseSuccess()));
        verify(mockRepository.removeAllComposerCache(accountId, userName))
            .called(1);
      });
    });

    group('when no cache exists', () {
      test('skips mark step and still removes all', () async {
        when(mockRepository.getComposerCache(accountId, userName))
            .thenAnswer((_) async => []);
        when(mockRepository.removeAllComposerCache(accountId, userName))
            .thenAnswer((_) async {});

        final result = await interactor.execute(accountId, userName);

        expect(result, Right(MarkComposerCacheCleanCloseSuccess()));
        verifyNever(mockRepository.saveComposerCache(
          anyNamed('accountId'),
          anyNamed('userName'),
          anyNamed('composerCache'),
        ));
        verify(mockRepository.removeAllComposerCache(accountId, userName))
            .called(1);
      });
    });

    group('error handling', () {
      test('returns failure when getComposerCache throws', () async {
        final exception = Exception('db error');
        when(mockRepository.getComposerCache(accountId, userName))
            .thenThrow(exception);

        final result = await interactor.execute(accountId, userName);

        result.fold(
          (f) {
            expect(f, isA<MarkComposerCacheCleanCloseFailure>());
            expect(
                (f as MarkComposerCacheCleanCloseFailure).exception, exception);
          },
          (_) => fail('expected Left'),
        );
      });

      test('returns failure when removeAllComposerCache throws', () async {
        final cache = makeLocalCache();
        when(mockRepository.getComposerCache(accountId, userName))
            .thenAnswer((_) async => [cache]);
        when(mockRepository.saveComposerCache(
          accountId,
          userName,
          anyNamed('composerCache'),
        )).thenAnswer((_) async {});
        when(mockRepository.removeAllComposerCache(accountId, userName))
            .thenThrow(Exception('remove failed'));

        final result = await interactor.execute(accountId, userName);

        verify(mockRepository.saveComposerCache(
          accountId,
          userName,
          anyNamed('composerCache'),
        )).called(1);
        result.fold(
          (f) {
            expect(f, isA<MarkComposerCacheCleanCloseFailure>());
            expect((f as MarkComposerCacheCleanCloseFailure).exception,
                isA<Exception>());
          },
          (_) => fail('expected Left'),
        );
      });
    });
  });
}
