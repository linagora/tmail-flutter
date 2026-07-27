import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/get_email_request.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/load_more_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/load_more_emails_in_mailbox_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';

import 'load_more_emails_in_mailbox_interactor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ThreadRepository>(),
])
void main() {
  late MockThreadRepository mockThreadRepository;
  late LoadMoreEmailsInMailboxInteractor interactor;

  setUp(() {
    mockThreadRepository = MockThreadRepository();
    interactor = LoadMoreEmailsInMailboxInteractor(mockThreadRepository);
  });

  final request = GetEmailRequest(
    SessionFixtures.aliceSession,
    AccountFixtures.aliceAccountId,
  );

  group('LoadMoreEmailsInMailboxInteractor serverEmailCount:', () {
    test(
      'GIVEN repo returns EmailsResponse with serverEmailCount set '
      'WHEN interactor maps to LoadMoreEmailsSuccess '
      'THEN serverEmailCount SHOULD equal the repo value',
    () async {
      final serverEmails = List.generate(
        ThreadConstants.maxCountEmails,
        (i) => Email(id: EmailId(Id('e$i'))),
      );

      when(mockThreadRepository.loadMoreEmails(request))
          .thenAnswer((_) => Stream.value(EmailsResponse(
            emailList: serverEmails,
            serverEmailCount: ThreadConstants.maxCountEmails,
          )));

      final states = await interactor.execute(request).toList();

      final success = states
          .whereType<Right>()
          .map((r) => r.value)
          .whereType<LoadMoreEmailsSuccess>()
          .first;

      expect(success.serverEmailCount, ThreadConstants.maxCountEmails);
      expect(success.emailList.length, ThreadConstants.maxCountEmails);
    });

    test(
      'GIVEN repo returns EmailsResponse with serverEmailCount > emailList.length '
      '(anchor was stripped) '
      'WHEN interactor maps to LoadMoreEmailsSuccess '
      'THEN serverEmailCount SHOULD reflect the pre-strip count, not the stripped count',
    () async {
      final strippedEmails = List.generate(
        ThreadConstants.maxCountEmails - 1,
        (i) => Email(id: EmailId(Id('e$i'))),
      );

      when(mockThreadRepository.loadMoreEmails(request))
          .thenAnswer((_) => Stream.value(EmailsResponse(
            emailList: strippedEmails,
            serverEmailCount: ThreadConstants.maxCountEmails,
          )));

      final states = await interactor.execute(request).toList();

      final success = states
          .whereType<Right>()
          .map((r) => r.value)
          .whereType<LoadMoreEmailsSuccess>()
          .first;

      expect(success.serverEmailCount, ThreadConstants.maxCountEmails);
      expect(success.emailList.length, ThreadConstants.maxCountEmails - 1);
    });

    test(
      'GIVEN repo returns EmailsResponse with serverEmailCount null '
      'WHEN interactor maps to LoadMoreEmailsSuccess '
      'THEN serverEmailCount SHOULD fall back to emailList.length',
    () async {
      final emails = List.generate(
        5,
        (i) => Email(id: EmailId(Id('e$i'))),
      );

      when(mockThreadRepository.loadMoreEmails(request))
          .thenAnswer((_) => Stream.value(EmailsResponse(
            emailList: emails,
          )));

      final states = await interactor.execute(request).toList();

      final success = states
          .whereType<Right>()
          .map((r) => r.value)
          .whereType<LoadMoreEmailsSuccess>()
          .first;

      expect(success.serverEmailCount, emails.length);
    });
  });

  group('LoadMoreEmailsInMailboxInteractor stream error:', () {
    test(
      'GIVEN repo stream emits a value then raises an error '
      'WHEN interactor executes '
      'THEN it SHOULD emit the mapped success AND a LoadMoreEmailsFailure '
      'rather than letting the error tear down the stream',
    () async {
      final exception = StateError('connection reset');
      final emails = [Email(id: EmailId(Id('e0')))];

      when(mockThreadRepository.loadMoreEmails(request)).thenAnswer((_) async* {
        yield EmailsResponse(emailList: emails);
        throw exception;
      });

      final states = await interactor.execute(request).toList();

      expect(
        states
            .whereType<Right>()
            .map((r) => r.value)
            .whereType<LoadMoreEmailsSuccess>()
            .length,
        1,
      );

      final failure = states
          .whereType<Left>()
          .map((l) => l.value)
          .whereType<LoadMoreEmailsFailure>()
          .single;

      expect(failure.exception, exception);
    });

    test(
      'GIVEN repo stream raises an error before emitting anything '
      'WHEN interactor executes '
      'THEN it SHOULD complete with a LoadMoreEmailsFailure',
    () async {
      final exception = StateError('network down');

      when(mockThreadRepository.loadMoreEmails(request))
          .thenAnswer((_) => Stream<EmailsResponse>.error(exception));

      final states = await interactor.execute(request).toList();

      final failure = states
          .whereType<Left>()
          .map((l) => l.value)
          .whereType<LoadMoreEmailsFailure>()
          .single;

      expect(failure.exception, exception);
    });
  });
}
