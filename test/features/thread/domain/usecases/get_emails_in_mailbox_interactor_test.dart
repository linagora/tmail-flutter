import 'dart:async';

import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:model/model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/email_fixtures.dart';
import '../../../../fixtures/mailbox_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'get_emails_in_mailbox_interactor_test.mocks.dart';

@GenerateMocks([ThreadRepository])
void main() {
  late ThreadRepository threadRepository;
  late GetEmailsInMailboxInteractor getEmailsInMailboxInteractor;

  group('[GetEmailsInMailboxInteractor]', () {

    setUp(() {
      threadRepository = MockThreadRepository();
      getEmailsInMailboxInteractor = GetEmailsInMailboxInteractor(threadRepository);
    });

    test('getEmailsInMailboxInteractor should execute to get all email from cache and network', () async {
      when(threadRepository.getAllEmail(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          limit: UnsignedInt(20),
          sort: {}..add(EmailComparator(EmailComparatorProperty.sentAt)..setIsAscending(false)),
          emailFilter: EmailFilter(
            filter: EmailFilterCondition(inMailbox: MailboxFixtures.inboxMailbox.id),
            mailboxId: MailboxFixtures.inboxMailbox.id,
          ),
          propertiesCreated: ThreadConstants.propertiesDefault,
          propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
      )).thenAnswer((_) => Stream.fromIterable({
          EmailsResponse(
            emailList: {
              EmailFixtures.email1,
              EmailFixtures.email2
            }.toList(),
            state: jmap.State('s1')),
          EmailsResponse(
            emailList: {
              EmailFixtures.email1,
              EmailFixtures.email2,
              EmailFixtures.email3,
              EmailFixtures.email4,
              EmailFixtures.email5,
            }.toList(),
            state: jmap.State('s1'))
        }));

      final streamStates = getEmailsInMailboxInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: UnsignedInt(20),
        sort: {}..add(EmailComparator(EmailComparatorProperty.sentAt)..setIsAscending(false)),
        emailFilter: EmailFilter(
          filter: EmailFilterCondition(inMailbox: MailboxFixtures.inboxMailbox.id),
          mailboxId: MailboxFixtures.inboxMailbox.id,
        ),
        propertiesCreated: ThreadConstants.propertiesDefault,
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault);

      final states = await streamStates.toList();

      expect(states.length, equals(3));
      expect(states, containsAllInOrder({
        Right(GetAllEmailLoading()),
        Right(GetAllEmailSuccess(
          emailList: {
            EmailFixtures.email1.toPresentationEmail(),
            EmailFixtures.email2.toPresentationEmail()
          }.toList(),
          currentEmailState: jmap.State('s1'),
          currentMailboxId: MailboxFixtures.inboxMailbox.id)
        ),
        Right(GetAllEmailSuccess(
          emailList: {
            EmailFixtures.email1.toPresentationEmail(),
            EmailFixtures.email2.toPresentationEmail(),
            EmailFixtures.email3.toPresentationEmail(),
            EmailFixtures.email4.toPresentationEmail(),
            EmailFixtures.email5.toPresentationEmail(),
          }.toList(),
          currentEmailState: jmap.State('s1'),
          currentMailboxId: MailboxFixtures.inboxMailbox.id)
        )
      }));
    });

    test('should use forceQueryAllEmailsForWeb when forceEmailQuery = true',
        () async {
      final sort = <EmailComparator>{
        EmailComparator(EmailComparatorProperty.sentAt)..setIsAscending(false),
      };

      final emailFilter = EmailFilter(
        filter: EmailFilterCondition(
          inMailbox: MailboxFixtures.inboxMailbox.id,
        ),
        mailboxId: MailboxFixtures.inboxMailbox.id,
      );

      when(threadRepository.forceQueryAllEmailsForWeb(
        session: SessionFixtures.aliceSession,
        accountId: AccountFixtures.aliceAccountId,
        limit: UnsignedInt(20),
        sort: sort,
        emailFilter: emailFilter,
        propertiesCreated: ThreadConstants.propertiesDefault,
      )).thenAnswer(
        (_) => Stream<EmailsResponse>.fromIterable([
          EmailsResponse(
            emailList: [
              EmailFixtures.email1,
            ],
            state: jmap.State('s_cached'),
          ),
          EmailsResponse(
            emailList: [
              EmailFixtures.email1,
              EmailFixtures.email2,
              EmailFixtures.email3,
            ],
            state: jmap.State('s_cached'),
          ),
        ]),
      );

      final resultStream = getEmailsInMailboxInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: UnsignedInt(20),
        sort: sort,
        emailFilter: emailFilter,
        propertiesCreated: ThreadConstants.propertiesDefault,
        forceEmailQuery: true,
      );

      final states = await resultStream.toList();

      expect(states.length, 3);

      expect(states[0], Right(GetAllEmailLoading()));

      expect(
        states[1],
        Right(
          GetAllEmailSuccess(
            emailList: [
              EmailFixtures.email1.toPresentationEmail(),
            ],
            currentEmailState: jmap.State('s_cached'),
            currentMailboxId: MailboxFixtures.inboxMailbox.id,
          ),
        ),
      );

      expect(
        states[2],
        Right(
          GetAllEmailSuccess(
            emailList: [
              EmailFixtures.email1.toPresentationEmail(),
              EmailFixtures.email2.toPresentationEmail(),
              EmailFixtures.email3.toPresentationEmail(),
            ],
            currentEmailState: jmap.State('s_cached'),
            currentMailboxId: MailboxFixtures.inboxMailbox.id,
          ),
        ),
      );

      verify(threadRepository.forceQueryAllEmailsForWeb(
        session: SessionFixtures.aliceSession,
        accountId: AccountFixtures.aliceAccountId,
        limit: UnsignedInt(20),
        sort: sort,
        emailFilter: emailFilter,
        propertiesCreated: ThreadConstants.propertiesDefault,
      )).called(1);

      verifyNever(threadRepository.getAllEmail(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
        emailFilter: anyNamed('emailFilter'),
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
      ));
    });

    test(
        'forceEmailQuery = true, should continue when cache throws error and still return server emails',
        () async {
      final sort = <EmailComparator>{
        EmailComparator(EmailComparatorProperty.sentAt)..setIsAscending(false),
      };

      final emailFilter = EmailFilter(
        filter: EmailFilterCondition(
          inMailbox: MailboxFixtures.inboxMailbox.id,
        ),
        mailboxId: MailboxFixtures.inboxMailbox.id,
      );

      when(threadRepository.forceQueryAllEmailsForWeb(
        session: SessionFixtures.aliceSession,
        accountId: AccountFixtures.aliceAccountId,
        limit: UnsignedInt(20),
        sort: sort,
        emailFilter: emailFilter,
        propertiesCreated: ThreadConstants.propertiesDefault,
      )).thenAnswer(
        (_) => Stream<EmailsResponse>.fromIterable([
          const EmailsResponse(
            emailList: null,
            state: null,
          ),
          EmailsResponse(
            emailList: [
              EmailFixtures.email1,
              EmailFixtures.email2,
            ],
            state: jmap.State('server_1'),
          ),
        ]),
      );

      final resultStream = getEmailsInMailboxInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: UnsignedInt(20),
        sort: sort,
        emailFilter: emailFilter,
        propertiesCreated: ThreadConstants.propertiesDefault,
        forceEmailQuery: true,
      );

      final states = await resultStream.toList();

      expect(states.length, 2 + 1);

      expect(states[0], Right(GetAllEmailLoading()));

      expect(
        states[1],
        Right(
          GetAllEmailSuccess(
            emailList: const [],
            currentEmailState: null,
            currentMailboxId: MailboxFixtures.inboxMailbox.id,
          ),
        ),
      );

      expect(
        states[2],
        Right(
          GetAllEmailSuccess(
            emailList: [
              EmailFixtures.email1.toPresentationEmail(),
              EmailFixtures.email2.toPresentationEmail(),
            ],
            currentEmailState: jmap.State('server_1'),
            currentMailboxId: MailboxFixtures.inboxMailbox.id,
          ),
        ),
      );
    });

    test(
        'forceEmailQuery = true, should emit Failure when forceQueryAllEmailsForWeb throws exception',
        () async {
      final sort = <EmailComparator>{
        EmailComparator(EmailComparatorProperty.sentAt)..setIsAscending(false),
      };

      final emailFilter = EmailFilter(
        filter: EmailFilterCondition(
          inMailbox: MailboxFixtures.inboxMailbox.id,
        ),
        mailboxId: MailboxFixtures.inboxMailbox.id,
      );

      when(threadRepository.forceQueryAllEmailsForWeb(
        session: SessionFixtures.aliceSession,
        accountId: AccountFixtures.aliceAccountId,
        limit: UnsignedInt(20),
        sort: sort,
        emailFilter: emailFilter,
        propertiesCreated: ThreadConstants.propertiesDefault,
      )).thenThrow(Exception('server_failed'));

      final resultStream = getEmailsInMailboxInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: UnsignedInt(20),
        sort: sort,
        emailFilter: emailFilter,
        propertiesCreated: ThreadConstants.propertiesDefault,
        forceEmailQuery: true,
      );

      final states = await resultStream.toList();

      expect(states[0], Right(GetAllEmailLoading()));
      expect(states[1].isLeft(), true);

      states[1].fold(
        (failure) => expect(failure, isA<GetAllEmailFailure>()),
        (_) => fail('Should not produce success'),
      );
    });

    test(
        'forceEmailQuery = false, should call getAllEmail() and not call forceQueryAllEmailsForWeb()',
        () async {
      final sort = <EmailComparator>{
        EmailComparator(EmailComparatorProperty.sentAt)..setIsAscending(false),
      };

      final emailFilter = EmailFilter(
        filter: EmailFilterCondition(
          inMailbox: MailboxFixtures.inboxMailbox.id,
        ),
        mailboxId: MailboxFixtures.inboxMailbox.id,
      );

      when(threadRepository.getAllEmail(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: UnsignedInt(20),
        sort: sort,
        emailFilter: emailFilter,
        propertiesCreated: ThreadConstants.propertiesDefault,
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
        getLatestChanges: true,
      )).thenAnswer(
        (_) => Stream<EmailsResponse>.fromIterable([
          EmailsResponse(
            emailList: [
              EmailFixtures.email1,
            ],
            state: jmap.State('s1'),
          ),
          EmailsResponse(
            emailList: [
              EmailFixtures.email1,
              EmailFixtures.email2,
              EmailFixtures.email3,
            ],
            state: jmap.State('s1'),
          ),
        ]),
      );

      final resultStream = getEmailsInMailboxInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: UnsignedInt(20),
        sort: sort,
        emailFilter: emailFilter,
        propertiesCreated: ThreadConstants.propertiesDefault,
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
        forceEmailQuery: false,
      );

      final states = await resultStream.toList();

      expect(states.length, 3);

      expect(states[0], Right(GetAllEmailLoading()));

      expect(
        states[1],
        Right(
          GetAllEmailSuccess(
            emailList: [
              EmailFixtures.email1.toPresentationEmail(),
            ],
            currentEmailState: jmap.State('s1'),
            currentMailboxId: MailboxFixtures.inboxMailbox.id,
          ),
        ),
      );

      expect(
        states[2],
        Right(
          GetAllEmailSuccess(
            emailList: [
              EmailFixtures.email1.toPresentationEmail(),
              EmailFixtures.email2.toPresentationEmail(),
              EmailFixtures.email3.toPresentationEmail(),
            ],
            currentEmailState: jmap.State('s1'),
            currentMailboxId: MailboxFixtures.inboxMailbox.id,
          ),
        ),
      );

      verify(threadRepository.getAllEmail(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        limit: UnsignedInt(20),
        sort: sort,
        emailFilter: emailFilter,
        propertiesCreated: ThreadConstants.propertiesDefault,
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
        getLatestChanges: true,
      )).called(1);

      verifyNever(threadRepository.forceQueryAllEmailsForWeb(
        session: SessionFixtures.aliceSession,
        accountId: AccountFixtures.aliceAccountId,
        limit: anyNamed('limit'),
        sort: anyNamed('sort'),
        emailFilter: anyNamed('emailFilter'),
        propertiesCreated: anyNamed('propertiesCreated'),
      ));
    });
  });
}