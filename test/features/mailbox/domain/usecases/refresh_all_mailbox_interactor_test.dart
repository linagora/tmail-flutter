import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/mailbox_fixtures.dart';
import '../../../../fixtures/state_fixtures.dart';
import 'refresh_all_mailbox_interactor_test.mocks.dart';

@GenerateMocks([MailboxRepository])
void main() {
  late MailboxRepository mailboxRepository;
  late RefreshAllMailboxInteractor refreshAllMailboxInteractor;

  group('[RefreshAllMailboxInteractor]', () {

    setUp(() {
      mailboxRepository = MockMailboxRepository();
      refreshAllMailboxInteractor = RefreshAllMailboxInteractor(mailboxRepository);
    });

    test('refreshAllMailboxInteractor should execute to get all mailbox from cache and combine with network changed', () async {
      when(mailboxRepository.refresh(AccountFixtures.aliceAccountId, StateFixtures.currentMailboxState))
        .thenAnswer((_) => Stream.fromIterable({
          MailboxResponse(
            mailboxes: {
              MailboxFixtures.inboxMailbox,
              MailboxFixtures.sentMailbox,
              MailboxFixtures.folder1,
              MailboxFixtures.folder1_1
            }.toList(),
            state: jmap.State('s1'))
        }));

      final streamStates = refreshAllMailboxInteractor.execute(AccountFixtures.aliceAccountId, StateFixtures.currentMailboxState);

      final states = await streamStates.toList();

      expect(states.length, equals(2));
      expect(states, containsAllInOrder({
        Right(LoadingState()),
        Right(GetAllMailboxSuccess(
          defaultMailboxList: {
            MailboxFixtures.inboxMailbox.toPresentationMailbox(),
            MailboxFixtures.sentMailbox.toPresentationMailbox()
          }.toList(),
          folderMailboxList: {
            MailboxFixtures.folder1.toPresentationMailbox(),
            MailboxFixtures.folder1_1.toPresentationMailbox()
          }.toList(),
          currentMailboxState: jmap.State('s1'))
        )
      }));
    });
  });
}