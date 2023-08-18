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
          currentEmailState: jmap.State('s1'))
        ),
        Right(GetAllEmailSuccess(
          emailList: {
            EmailFixtures.email1.toPresentationEmail(),
            EmailFixtures.email2.toPresentationEmail(),
            EmailFixtures.email3.toPresentationEmail(),
            EmailFixtures.email4.toPresentationEmail(),
            EmailFixtures.email5.toPresentationEmail(),
          }.toList(),
          currentEmailState: jmap.State('s1'))
        )
      }));
    });
  });
}