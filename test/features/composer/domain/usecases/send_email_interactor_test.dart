import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/forbidden_to_send_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/check_sending_allowed_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'send_email_interactor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<EmailRepository>(),
  MockSpec<CheckSendingAllowedInteractor>(),
])
void main() {
  final emailRepository = MockEmailRepository();
  final checkSendingAllowedInteractor = MockCheckSendingAllowedInteractor();
  final interactor = SendEmailInteractor(
    emailRepository,
    checkSendingAllowedInteractor,
  );
  final session = SessionFixtures.aliceSession;
  final accountId = AccountFixtures.aliceAccountId;

  EmailRequest buildEmailRequest({EmailId? emailIdDestroyed}) => EmailRequest(
        email: Email(),
        emailActionType: EmailActionType.compose,
        emailIdDestroyed: emailIdDestroyed,
      );

  Future<List<Either>> run(EmailRequest emailRequest) =>
      interactor.execute(session, accountId, emailRequest).toList();

  setUp(() {
    reset(emailRepository);
    reset(checkSendingAllowedInteractor);
  });

  group('SendEmailInteractor::execute', () {
    test(
      'SHOULD check that the account may send, then send and emit SendEmailSuccess '
      'WHEN sending is allowed',
    () async {
      final emailRequest = buildEmailRequest();

      final states = await run(emailRequest);

      expect(
        states.map((state) => state.fold((l) => l, (r) => r).runtimeType),
        [SendEmailLoading, SendEmailSuccess],
      );
      verifyInOrder([
        checkSendingAllowedInteractor.execute(session, accountId),
        emailRepository.sendEmail(
          session,
          accountId,
          emailRequest,
          mailboxRequest: anyNamed('mailboxRequest'),
        ),
      ]);
      verifyNever(emailRepository.deleteEmailPermanently(any, any, any));
    });

    test(
      'SHOULD delete the destroyed email after sending '
      'WHEN the request carries one',
    () async {
      final destroyed = EmailId(Id('draft-1'));

      await run(buildEmailRequest(emailIdDestroyed: destroyed));

      verify(emailRepository.deleteEmailPermanently(session, accountId, destroyed))
          .called(1);
    });

    test(
      'SHOULD emit SendEmailFailure with ForbiddenToSendException and its context, '
      'without sending, '
      'WHEN the account may not send',
    () async {
      final emailRequest = buildEmailRequest(
        emailIdDestroyed: EmailId(Id('draft-1')),
      );
      when(checkSendingAllowedInteractor.execute(any, any))
          .thenThrow(ForbiddenToSendException());

      final states = await run(emailRequest);

      final failure = states.last.fold((l) => l, (r) => r);
      expect(
        failure,
        isA<SendEmailFailure>()
            .having((f) => f.exception, 'exception', isA<ForbiddenToSendException>())
            .having((f) => f.session, 'session', session)
            .having((f) => f.accountId, 'accountId', accountId)
            .having((f) => f.emailRequest, 'emailRequest', emailRequest),
      );
      verifyNever(emailRepository.sendEmail(
        any,
        any,
        any,
        mailboxRequest: anyNamed('mailboxRequest'),
      ));
      verifyNever(emailRepository.deleteEmailPermanently(any, any, any));
    });

    test(
      'SHOULD emit SendEmailFailure with the server exception '
      'WHEN the server refuses the submission',
    () async {
      final exception = ForbiddenToSendException(
        createdEmailId: EmailId(Id('email-1')),
      );
      when(emailRepository.sendEmail(
        any,
        any,
        any,
        mailboxRequest: anyNamed('mailboxRequest'),
      )).thenThrow(exception);

      final states = await run(buildEmailRequest());

      expect(
        states.last.fold((l) => l, (r) => r),
        isA<SendEmailFailure>().having((f) => f.exception, 'exception', exception),
      );
    });
  });
}
