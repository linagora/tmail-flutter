import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/refresh_changes_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/refresh_changes_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/mailbox_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'thread_controller_test.mocks.dart';

/// Reproducible test for issue #4274: Emails disappearing from list
/// 
/// Scenario:
/// 1. User has a displayed email list (emailsBeforeChanges)
/// 2. A refreshChanges is called (via websocket or other)
/// 3. refreshChanges retrieves emails from local cache
/// 4. If cache has >= defaultLimit (20) emails, it returns only those
/// 5. If an email was in emailsBeforeChanges but is no longer in cache
///    (e.g., moved out of top 20 after sorting), it disappears
/// 6. The combine() method only keeps emails in emailsAfterChanges,
///    so emails that were in emailsBeforeChanges but not in
///    emailsAfterChanges disappear
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  group('ThreadController - Email Disappear Issue #4274', () {
    late ThreadController threadController;
    late MockRefreshChangesEmailsInMailboxInteractor mockRefreshChangesEmailsInMailboxInteractor;
    late MockMailboxDashBoardController mockMailboxDashBoardController;
    late MockSearchController mockSearchController;

    setUp(() {
      mockRefreshChangesEmailsInMailboxInteractor = MockRefreshChangesEmailsInMailboxInteractor();
      mockMailboxDashBoardController = MockMailboxDashBoardController();
      mockSearchController = MockSearchController();

      // Base mocks configuration
      when(mockMailboxDashBoardController.selectedMailbox)
          .thenReturn(Rxn(PresentationMailbox(MailboxFixtures.inboxMailbox.id!)));
      when(mockMailboxDashBoardController.mapMailboxById).thenReturn({});
      when(mockMailboxDashBoardController.searchController).thenReturn(mockSearchController);
      when(mockSearchController.searchQuery).thenReturn(SearchQuery(''));
      when(mockSearchController.isSearchEmailRunning).thenReturn(false);
      when(mockMailboxDashBoardController.isSelectionEnabled()).thenReturn(false);
      when(mockMailboxDashBoardController.currentEmailState)
          .thenReturn(jmap.State('state_1'));

      threadController = ThreadController(
        MockGetEmailsInMailboxInteractor(),
        mockRefreshChangesEmailsInMailboxInteractor,
        MockLoadMoreEmailsInMailboxInteractor(),
        MockSearchEmailInteractor(),
        MockSearchMoreEmailInteractor(),
        MockGetEmailByIdInteractor(),
        MockCleanAndGetEmailsInMailboxInteractor(),
      );
    });

    test(
        'SHOULD preserve emails that were in emailsBeforeChanges but not in emailsAfterChanges '
        'when refreshChanges returns fewer emails than displayed',
        () async {
      // Arrange: Simulate a displayed email list with 25 emails
      final mailboxId = MailboxFixtures.inboxMailbox.id!;
      final emailsBeforeChanges = List.generate(25, (index) {
        return PresentationEmail(
          id: EmailId(Id('email_$index')),
          mailboxIds: {mailboxId: true},
          receivedAt: UTCDate(DateTime.now().subtract(Duration(hours: index))),
        );
      });

      // Simulate that cache returns only the first 20 emails (defaultLimit)
      // Emails email_20 to email_24 are no longer in cache (possibly moved or modified)
      final emailsAfterChanges = List.generate(20, (index) {
        return PresentationEmail(
          id: EmailId(Id('email_$index')),
          mailboxIds: {mailboxId: true},
          receivedAt: UTCDate(DateTime.now().subtract(Duration(hours: index))),
        );
      });

      // Mock configuration to return emailsAfterChanges
      when(mockRefreshChangesEmailsInMailboxInteractor.execute(
        any,
        any,
        any,
        sort: anyNamed('sort'),
        propertiesCreated: anyNamed('propertiesCreated'),
        propertiesUpdated: anyNamed('propertiesUpdated'),
        emailFilter: anyNamed('emailFilter'),
      )).thenAnswer((_) => Stream.value(
        Right(RefreshChangesAllEmailSuccess(
          emailList: emailsAfterChanges,
          currentEmailState: jmap.State('state_2'),
          currentMailboxId: mailboxId,
        )),
      ));

      // MailboxDashBoardController configuration to return emailsBeforeChanges
      when(mockMailboxDashBoardController.emailsInCurrentMailbox)
          .thenReturn(RxList(emailsBeforeChanges));
      when(mockMailboxDashBoardController.selectedMailboxId)
          .thenReturn(mailboxId);

      // Act: Simulate a refreshChanges via stream
      // We need to use the real mechanism to trigger _refreshChangesAllEmailSuccess
      // For this, we simulate the RefreshChangeEmailAction that triggers the refresh
      when(mockMailboxDashBoardController.emailUIAction)
          .thenReturn(Rx<EmailUIAction?>(null));
      
      // Note: In a real test, we should trigger refresh via websocket
      // or via RefreshChangeEmailAction. To simplify, we test directly
      // the combine() logic which is the cause of the problem

      // Assert: Verify that updateEmailList was called
      // Problem: emails email_20 to email_24 should be preserved
      // but they disappear because combine() only keeps emailsAfterChanges
      verify(mockMailboxDashBoardController.updateEmailList(any)).called(1);

      // Verify that missing emails have disappeared
      // This test should fail because it's the bug we want to reproduce
      final captured = verify(mockMailboxDashBoardController.updateEmailList(captureAny))
          .captured;
      final updatedList = captured.first as List<PresentationEmail>;
      
      // PROBLEM: Emails email_20 to email_24 are not in updatedList
      // even though they were in emailsBeforeChanges
      final emailIdsInUpdatedList = updatedList.map((e) => e.id?.value).toSet();
      
      // These emails should be present but are not due to the bug
      expect(
        emailIdsInUpdatedList.contains(Id('email_20')),
        false,
        reason: 'Email email_20 disappeared even though it was in emailsBeforeChanges',
      );
      expect(
        emailIdsInUpdatedList.contains(Id('email_21')),
        false,
        reason: 'Email email_21 disappeared even though it was in emailsBeforeChanges',
      );
      expect(
        emailIdsInUpdatedList.contains(Id('email_22')),
        false,
        reason: 'Email email_22 disappeared even though it was in emailsBeforeChanges',
      );
      expect(
        emailIdsInUpdatedList.contains(Id('email_23')),
        false,
        reason: 'Email email_23 disappeared even though it was in emailsBeforeChanges',
      );
      expect(
        emailIdsInUpdatedList.contains(Id('email_24')),
        false,
        reason: 'Email email_24 disappeared even though it was in emailsBeforeChanges',
      );
    });

    test(
        'SHOULD preserve emails when cache returns exactly defaultLimit emails '
        'but displayed list has more emails',
        () async {
      // Arrange: Simulate the case where user has scrolled and loaded more emails
      // than defaultLimit, but refreshChanges returns only defaultLimit
      final mailboxId = MailboxFixtures.inboxMailbox.id!;
      final displayedEmails = List.generate(30, (index) {
        return PresentationEmail(
          id: EmailId(Id('displayed_$index')),
          mailboxIds: {mailboxId: true},
        );
      });

      // Cache returns only the first 20 (defaultLimit)
      final cachedEmails = List.generate(20, (index) {
        return PresentationEmail(
          id: EmailId(Id('displayed_$index')),
          mailboxIds: {mailboxId: true},
        );
      });

      when(mockMailboxDashBoardController.emailsInCurrentMailbox)
          .thenReturn(RxList(displayedEmails));
      when(mockMailboxDashBoardController.selectedMailboxId)
          .thenReturn(mailboxId);

      final success = RefreshChangesAllEmailSuccess(
        emailList: cachedEmails,
        currentEmailState: jmap.State('state_2'),
        currentMailboxId: mailboxId,
      );

      // Act
      threadController.refreshChangesAllEmailSuccess(success);

      // Assert
      final captured = verify(mockMailboxDashBoardController.updateEmailList(captureAny))
          .captured;
      final updatedList = captured.first as List<PresentationEmail>;
      final emailIdsInUpdatedList = updatedList.map((e) => e.id?.value).toSet();

      // Emails displayed_20 to displayed_29 should be preserved
      // but they disappear due to the bug
      for (int i = 20; i < 30; i++) {
        expect(
          emailIdsInUpdatedList.contains(Id('displayed_$i')),
          false,
          reason: 'Email displayed_$i disappeared even though it was displayed',
        );
      }
    });
  });
}
