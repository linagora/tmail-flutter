import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_email_by_blob_id_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_email_by_blob_id_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/email_fixtures.dart';

import 'parse_email_by_blob_id_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<EmailRepository>()])
void main() {
  group('ParseEmailByBlobIdInteractor::execute::', () {
    late MockEmailRepository mockEmailRepository;
    late ParseEmailByBlobIdInteractor parseEmailByBlobIdInteractor;

    setUp(() {
      mockEmailRepository = MockEmailRepository();
      parseEmailByBlobIdInteractor =
          ParseEmailByBlobIdInteractor(mockEmailRepository);
    });

    final accountId = AccountFixtures.aliceAccountId;
    final blobId = Id('blob-id');

    test(
        'should emit ParsingEmailByBlobId and ParseEmailByBlobIdSuccess\n'
        'when repository call succeeds', () async {
      // Arrange
      final parsedEmail = EmailFixtures.email1;

      when(mockEmailRepository.parseEmailByBlobIds(accountId, {blobId}))
          .thenAnswer((_) async => [parsedEmail]);

      // Act
      final result = parseEmailByBlobIdInteractor.execute(accountId, blobId);

      // Assert

      await expectLater(
        result,
        emitsInOrder([
          Right<Failure, Success>(ParsingEmailByBlobId()),
          Right<Failure, Success>(ParseEmailByBlobIdSuccess(parsedEmail, blobId)),
        ]),
      );

      verify(mockEmailRepository.parseEmailByBlobIds(accountId, {blobId}))
          .called(1);
      verifyNoMoreInteractions(mockEmailRepository);
    });

    test(
        'should emit ParsingEmailByBlobId and ParseEmailByBlobIdFailure\n'
        'when repository call throws exception', () async {
      // Arrange
      final exception = Exception('Failed to parse email');

      when(mockEmailRepository.parseEmailByBlobIds(accountId, {blobId}))
          .thenThrow(exception);

      // Act
      final result = parseEmailByBlobIdInteractor.execute(accountId, blobId);

      // Assert
      await expectLater(
        result,
        emitsInOrder([
          Right<Failure, Success>(ParsingEmailByBlobId()),
          Left<Failure, Success>(ParseEmailByBlobIdFailure(exception)),
        ]),
      );

      verify(mockEmailRepository.parseEmailByBlobIds(accountId, {blobId}))
          .called(1);
      verifyNoMoreInteractions(mockEmailRepository);
    });
  });
}
