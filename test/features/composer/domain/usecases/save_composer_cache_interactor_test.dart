import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_composer_cache_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/save_composer_cache_state.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'save_composer_cache_interactor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ComposerCacheRepository>(),
  MockSpec<ComposerRepository>(),
])
void main() {
  late MockComposerCacheRepository mockCacheRepository;
  late MockComposerRepository mockComposerRepository;
  late SaveComposerCacheInteractor interactor;

  final session = SessionFixtures.aliceSession;
  final accountId = AccountFixtures.aliceAccountId;

  final baseRequest = CreateEmailRequest(
    session: session,
    accountId: accountId,
    emailActionType: EmailActionType.compose,
    ownEmailAddress: 'alice@domain.tld',
    subject: 'Test subject',
    emailContent: '<p>Hello</p>',
    composerId: 'uuid-composer-123',
  );

  setUp(() {
    mockCacheRepository = MockComposerCacheRepository();
    mockComposerRepository = MockComposerRepository();
    interactor = SaveComposerCacheInteractor(
      mockCacheRepository,
      mockComposerRepository,
    );
  });

  void arrangeSuccess() {
    when(mockComposerRepository.generateEmail(
      any,
      withIdentityHeader: anyNamed('withIdentityHeader'),
      isDraft: anyNamed('isDraft'),
    )).thenAnswer((_) async => Email());
    when(mockCacheRepository.saveComposerCache(any, any, any))
        .thenAnswer((_) async {});
  }

  void expectLeftWithSaveFailure(Either result, Exception exception) {
    result.fold(
      (f) {
        expect(f, isA<SaveComposerCacheFailure>());
        expect((f as SaveComposerCacheFailure).exception, exception);
      },
      (_) => fail('expected Left'),
    );
  }

  Future<Object> captureAndGetSavedCache({required bool isPersistent}) async {
    await interactor.execute(
      createEmailRequest: baseRequest,
      isPersistent: isPersistent,
    );
    return verify(
      mockCacheRepository.saveComposerCache(any, any, captureAny),
    ).captured.single;
  }

  group('SaveComposerCacheInteractor', () {
    group('on success', () {
      setUp(arrangeSuccess);

      test('calls generateEmail with withIdentityHeader=true and isDraft=true', () async {
        await interactor.execute(createEmailRequest: baseRequest);

        verify(mockComposerRepository.generateEmail(
          baseRequest,
          withIdentityHeader: true,
          isDraft: true,
        )).called(1);
      });

      test('calls saveComposerCache with the correct accountId and userName', () async {
        await interactor.execute(createEmailRequest: baseRequest);

        verify(mockCacheRepository.saveComposerCache(
          accountId,
          session.username,
          any,
        )).called(1);
      });

      test('returns Right(SaveComposerCacheSuccess)', () async {
        final result = await interactor.execute(createEmailRequest: baseRequest);

        expect(result, Right(SaveComposerCacheSuccess()));
      });

      test('saves a ComposerPersistentCache when isPersistent is true', () async {
        final captured = await captureAndGetSavedCache(isPersistent: true);

        expect(captured, isA<ComposerPersistentCache>());
      });

      test('saves a plain ComposerCache when isPersistent is false', () async {
        final captured = await captureAndGetSavedCache(isPersistent: false);

        expect(captured, isNot(isA<ComposerPersistentCache>()));
      });
    });

    group('error handling', () {
      test('returns Left(SaveComposerCacheFailure) when generateEmail throws', () async {
        final exception = Exception('generate failed');
        when(mockComposerRepository.generateEmail(
          any,
          withIdentityHeader: anyNamed('withIdentityHeader'),
          isDraft: anyNamed('isDraft'),
        )).thenThrow(exception);

        final result = await interactor.execute(createEmailRequest: baseRequest);

        expectLeftWithSaveFailure(result, exception);
      });

      test('returns Left(SaveComposerCacheFailure) when saveComposerCache throws', () async {
        when(mockComposerRepository.generateEmail(
          any,
          withIdentityHeader: anyNamed('withIdentityHeader'),
          isDraft: anyNamed('isDraft'),
        )).thenAnswer((_) async => Email());
        final exception = Exception('save failed');
        when(mockCacheRepository.saveComposerCache(any, any, any))
            .thenThrow(exception);

        final result = await interactor.execute(createEmailRequest: baseRequest);

        expectLeftWithSaveFailure(result, exception);
      });
    });
  });
}
