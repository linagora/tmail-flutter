import 'dart:async';

import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:model/model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/refresh_changes_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/refresh_changes_emails_in_mailbox_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/email_fixtures.dart';
import '../../../../fixtures/mailbox_fixtures.dart';
import '../../../../fixtures/state_fixtures.dart';
import 'refresh_changes_emails_in_mailbox_interactor_test.mocks.dart';

@GenerateMocks([ThreadRepository])
void main() {
  late ThreadRepository threadRepository;
  late RefreshChangesEmailsInMailboxInteractor refreshChangesEmailsInMailboxInteractor;

  group('[RefreshChangesEmailsInMailboxInteractor]', () {

    setUp(() {
      threadRepository = MockThreadRepository();
      refreshChangesEmailsInMailboxInteractor = RefreshChangesEmailsInMailboxInteractor(threadRepository);
    });

    test('refreshChangesEmailsInMailboxInteractor should execute to get changes email from cache and network', () async {
      when(threadRepository.refreshChanges(
          AccountFixtures.aliceAccountId,
          StateFixtures.currentEmailState,
          sort: Set()..add(EmailComparator(EmailComparatorProperty.sentAt)..setIsAscending(false)),
          propertiesCreated: ThreadConstants.propertiesDefault,
          propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
          emailFilter: EmailFilter(
            mailboxId: MailboxFixtures.inboxMailbox.id)
      )).thenAnswer((_) => Stream.fromIterable({
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

      final streamStates = refreshChangesEmailsInMailboxInteractor.execute(
        AccountFixtures.aliceAccountId,
        StateFixtures.currentEmailState,
        sort: Set()..add(EmailComparator(EmailComparatorProperty.sentAt)..setIsAscending(false)),
        propertiesCreated: ThreadConstants.propertiesDefault,
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
        emailFilter: EmailFilter(
          mailboxId: MailboxFixtures.inboxMailbox.id),
      );

      final states = await streamStates.toList();

      expect(states.length, equals(2));
      expect(states, containsAllInOrder({
        Right(RefreshingState()),
        Right(RefreshChangesAllEmailSuccess(
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