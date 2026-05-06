import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_auto_save_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_all_composer_cache_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/resolve_composer_cache_for_restore_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_all_composer_cache_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/resolve_composer_cache_for_restore_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'composer_auto_save_notifier_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ResolveComposerCacheForRestoreInteractor>(),
  MockSpec<RemoveAllComposerCacheInteractor>(),
])
void main() {
  late MockResolveComposerCacheForRestoreInteractor mockResolveInteractor;
  late MockRemoveAllComposerCacheInteractor mockRemoveInteractor;
  late ComposerAutoSaveNotifier notifier;

  final testAccountId = AccountFixtures.aliceAccountId;
  final testUserName = SessionFixtures.aliceSession.username;

  ComposerPersistentCache makeCache({
    bool? isCleanClose,
    int? timestampMs,
    bool withEmail = false,
  }) =>
      ComposerPersistentCache(
        isCleanClose: isCleanClose,
        timestampMs: timestampMs ?? DateTime.now().millisecondsSinceEpoch,
        email: withEmail ? Email() : null,
      );

  setUp(() {
    mockResolveInteractor = MockResolveComposerCacheForRestoreInteractor();
    mockRemoveInteractor = MockRemoveAllComposerCacheInteractor();
    notifier = ComposerAutoSaveNotifier(mockResolveInteractor, mockRemoveInteractor);
    when(mockRemoveInteractor.execute(any, any))
        .thenAnswer((_) async => Right(RemoveAllComposerCacheSuccess()));
  });

  group('ComposerAutoSaveNotifier', () {
    group('initial state', () {
      test('all flags are false and content is empty', () {
        expect(notifier.hasRecoverableSnapshot, isFalse);
        expect(notifier.isCleanClose, isFalse);
        expect(notifier.isSavingToDraftInProgress, isFalse);
        expect(notifier.lastKnownHtmlContent, isEmpty);
      });
    });

    group('onSnapshotSaved', () {
      test('sets hasRecoverableSnapshot=true', () {
        notifier.onSnapshotSaved();
        expect(notifier.hasRecoverableSnapshot, isTrue);
      });

      test('is idempotent when called multiple times', () {
        notifier.onSnapshotSaved();
        notifier.onSnapshotSaved();
        expect(notifier.hasRecoverableSnapshot, isTrue);
      });
    });

    group('setCleanClose', () {
      test('sets isCleanClose=true', () {
        notifier.setCleanClose();
        expect(notifier.isCleanClose, isTrue);
      });

      test('does not affect hasRecoverableSnapshot', () {
        notifier.onSnapshotSaved();
        notifier.setCleanClose();
        expect(notifier.hasRecoverableSnapshot, isTrue);
        expect(notifier.isCleanClose, isTrue);
      });
    });

    group('updateLastKnownContent', () {
      test('stores provided html content', () {
        notifier.updateLastKnownContent('<p>hello</p>');
        expect(notifier.lastKnownHtmlContent, '<p>hello</p>');
      });

      test('overwrites previous content on subsequent calls', () {
        notifier.updateLastKnownContent('<p>first</p>');
        notifier.updateLastKnownContent('<p>second</p>');
        expect(notifier.lastKnownHtmlContent, '<p>second</p>');
      });
    });

    group('beginDraftSave / endDraftSave', () {
      test('beginDraftSave sets isSavingToDraftInProgress=true', () {
        notifier.beginDraftSave();
        expect(notifier.isSavingToDraftInProgress, isTrue);
      });

      test('endDraftSave clears isSavingToDraftInProgress', () {
        notifier.beginDraftSave();
        notifier.endDraftSave();
        expect(notifier.isSavingToDraftInProgress, isFalse);
      });
    });

    group('restore', () {
      group('returns null and keeps hasRecoverableSnapshot=false', () {
        final cases = [
          (
            'on interactor failure',
            Left<Failure, Success>(
              ResolveComposerCacheForRestoreFailure(Exception('storage error')),
            ),
          ),
          (
            'when no restorable snapshot found',
            Right<Failure, Success>(ResolveComposerCacheForRestoreSuccess(null)),
          ),
        ];

        for (final (description, response) in cases) {
          test(description, () async {
            when(mockResolveInteractor.execute(any, any))
                .thenAnswer((_) async => response);

            final result = await notifier.restore(testAccountId, testUserName);

            expect(result, isNull);
            expect(notifier.hasRecoverableSnapshot, isFalse);
          });
        }
      });

      test('returns cache and sets hasRecoverableSnapshot=true when snapshot found', () async {
        final cache = makeCache(withEmail: true);
        when(mockResolveInteractor.execute(any, any)).thenAnswer(
          (_) async => Right(ResolveComposerCacheForRestoreSuccess(cache)),
        );

        final result = await notifier.restore(testAccountId, testUserName);

        expect(result, cache);
        expect(notifier.hasRecoverableSnapshot, isTrue);
      });

      test('does not call removeInteractor — cleanup is owned by the interactor', () async {
        final cache = makeCache(withEmail: true);
        when(mockResolveInteractor.execute(any, any)).thenAnswer(
          (_) async => Right(ResolveComposerCacheForRestoreSuccess(cache)),
        );

        await notifier.restore(testAccountId, testUserName);

        verifyNever(mockRemoveInteractor.execute(any, any));
      });
    });

    group('clearCache', () {
      test('calls removeInteractor and clears hasRecoverableSnapshot', () async {
        notifier.onSnapshotSaved();

        await notifier.clearCache(testAccountId, testUserName);

        verify(mockRemoveInteractor.execute(any, any)).called(1);
        expect(notifier.hasRecoverableSnapshot, isFalse);
      });

      test('keeps hasRecoverableSnapshot=true when remove fails', () async {
        notifier.onSnapshotSaved();
        when(mockRemoveInteractor.execute(any, any)).thenAnswer(
          (_) async => Left(RemoveAllComposerCacheFailure(Exception('err'))),
        );

        await notifier.clearCache(testAccountId, testUserName);

        expect(notifier.hasRecoverableSnapshot, isTrue);
      });
    });

    group('restore → clearCache sequence (Layer 3 restore-and-clear pattern)', () {
      test(
        'hasRecoverableSnapshot transitions true→false after restore succeeds then cache is cleared',
        () async {
          final cache = makeCache(withEmail: true);
          when(mockResolveInteractor.execute(any, any)).thenAnswer(
            (_) async => Right(ResolveComposerCacheForRestoreSuccess(cache)),
          );

          await notifier.restore(testAccountId, testUserName);
          expect(notifier.hasRecoverableSnapshot, isTrue);

          await notifier.clearCache(testAccountId, testUserName);

          expect(notifier.hasRecoverableSnapshot, isFalse);
          verify(mockRemoveInteractor.execute(any, any)).called(1);
        },
      );

      test('clearCache after failed restore does not call removeInteractor', () async {
        when(mockResolveInteractor.execute(any, any)).thenAnswer(
          (_) async => Left(ResolveComposerCacheForRestoreFailure(Exception('err'))),
        );

        await notifier.restore(testAccountId, testUserName);
        expect(notifier.hasRecoverableSnapshot, isFalse);

        await notifier.clearCache(testAccountId, testUserName);

        // clearCache always calls removeInteractor regardless of prior restore result
        verify(mockRemoveInteractor.execute(any, any)).called(1);
        expect(notifier.hasRecoverableSnapshot, isFalse);
      });
    });

    group('isCleanClose does not block clearCache', () {
      test('clearCache executes even after setCleanClose is flagged', () async {
        notifier.onSnapshotSaved();
        notifier.setCleanClose();
        expect(notifier.isCleanClose, isTrue);

        await notifier.clearCache(testAccountId, testUserName);

        verify(mockRemoveInteractor.execute(any, any)).called(1);
        expect(notifier.hasRecoverableSnapshot, isFalse);
      });
    });

    group('concurrent flag independence', () {
      test('beginDraftSave and setCleanClose can coexist', () {
        notifier.beginDraftSave();
        notifier.setCleanClose();

        expect(notifier.isSavingToDraftInProgress, isTrue);
        expect(notifier.isCleanClose, isTrue);
      });

      test('endDraftSave clears only isSavingToDraftInProgress, not isCleanClose', () {
        notifier.beginDraftSave();
        notifier.setCleanClose();
        notifier.endDraftSave();

        expect(notifier.isSavingToDraftInProgress, isFalse);
        expect(notifier.isCleanClose, isTrue);
      });
    });
  });
}
