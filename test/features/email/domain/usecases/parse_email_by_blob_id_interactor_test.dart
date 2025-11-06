import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/download/domain/state/parse_email_by_blob_id_state.dart';
import 'package:tmail_ui_user/features/download/domain/usecase/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/download/domain/repository/download_repository.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/email_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'parse_email_by_blob_id_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DownloadRepository>()])
void main() {
  group('ParseEmailByBlobIdInteractor::execute::', () {
    late MockDownloadRepository mockDownloadRepository;
    late ParseEmailByBlobIdInteractor parseEmailByBlobIdInteractor;

    setUp(() {
      mockDownloadRepository = MockDownloadRepository();
      parseEmailByBlobIdInteractor =
          ParseEmailByBlobIdInteractor(mockDownloadRepository);
    });

    final accountId = AccountFixtures.aliceAccountId;
    final session = SessionFixtures.aliceSession;
    final blobId = Id('blob-id');

    test(
        'should emit ParsingEmailByBlobId and ParseEmailByBlobIdSuccess\n'
        'when repository call succeeds', () async {
      // Arrange
      final parsedEmail = EmailFixtures.email1;

      when(mockDownloadRepository.parseEmailByBlobIds(accountId, {blobId}))
          .thenAnswer((_) async => [parsedEmail]);

      // Act
      final result = parseEmailByBlobIdInteractor.execute(
        accountId,
        session,
        session.getOwnEmailAddressOrEmpty(),
        blobId,
      );

      // Assert

      await expectLater(
        result,
        emitsInOrder([
          Right<Failure, Success>(ParsingEmailByBlobId()),
          Right<Failure, Success>(ParseEmailByBlobIdSuccess(
            email: parsedEmail,
            blobId: blobId,
            accountId: accountId,
            session: session,
            ownEmailAddress: session.getOwnEmailAddressOrEmpty(),
          )),
        ]),
      );

      verify(mockDownloadRepository.parseEmailByBlobIds(accountId, {blobId}))
          .called(1);
      verifyNoMoreInteractions(mockDownloadRepository);
    });

    test(
        'should emit ParsingEmailByBlobId and ParseEmailByBlobIdFailure\n'
        'when repository call throws exception', () async {
      // Arrange
      final exception = Exception('Failed to parse email');

      when(mockDownloadRepository.parseEmailByBlobIds(accountId, {blobId}))
          .thenThrow(exception);

      // Act
      final result = parseEmailByBlobIdInteractor.execute(
        accountId,
        session,
        session.getOwnEmailAddressOrEmpty(),
        blobId,
      );

      // Assert
      await expectLater(
        result,
        emitsInOrder([
          Right<Failure, Success>(ParsingEmailByBlobId()),
          Left<Failure, Success>(ParseEmailByBlobIdFailure(exception)),
        ]),
      );

      verify(mockDownloadRepository.parseEmailByBlobIds(accountId, {blobId}))
          .called(1);
      verifyNoMoreInteractions(mockDownloadRepository);
    });
  });
}
