import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/apply_to_visible_email_list_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/delete_emails_in_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_emails_with_new_mailbox_id_extension.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

import 'update_current_emails_flags_extension_test.mocks.dart';

class _DesktopResponsiveUtils extends ResponsiveUtils {
  @override
  bool isWebDesktop(BuildContext context) => true;
}

void main() {
  late MockMailboxDashBoardController mailboxDashBoardController;
  late MockSearchController searchController;
  late MailboxId sourceMailboxId;
  late MailboxId archiveMailboxId;
  late List<EmailId> emailIds;
  late List<PresentationEmail> mailboxEmails;

  PresentationEmail email(EmailId id, MailboxId mailboxId) =>
      PresentationEmail(
        id: id,
        mailboxIds: {mailboxId: true},
        mailboxContain: PresentationMailbox(mailboxId),
      );

  void setSearchResults(List<PresentationEmail> emails) {
    appProviderContainer
        .read(searchEmailPresentationProvider.notifier)
        .setSearchIsRunning(true);
    appProviderContainer
        .read(searchEmailPresentationProvider.notifier)
        .setResultSearches(emails);
  }

  setUp(() {
    appProviderContainer.invalidate(searchEmailPresentationProvider);
    mailboxDashBoardController = MockMailboxDashBoardController();
    searchController = MockSearchController();
    sourceMailboxId = MailboxId(Id('source'));
    archiveMailboxId = MailboxId(Id('archive'));
    emailIds = List.generate(
      3,
      (index) => EmailId(Id('email-$index')),
    );
    mailboxEmails = emailIds
        .map((emailId) => email(emailId, sourceMailboxId))
        .toList();

    when(mailboxDashBoardController.searchController).thenReturn(searchController);
    when(searchController.isSearchEmailRunning).thenReturn(true);
    when(mailboxDashBoardController.mapMailboxById).thenReturn({
      archiveMailboxId: PresentationMailbox(archiveMailboxId),
    });
    when(mailboxDashBoardController.emailsInCurrentMailbox)
        .thenReturn(List<PresentationEmail>.from(mailboxEmails).obs);
  });

  tearDown(() {
    appProviderContainer.invalidate(searchEmailPresentationProvider);
  });

  group('visible email list reconciliation', () {
    test('publishes a transformed Search result list without changing the mailbox list', () {
      setSearchResults(mailboxEmails);

      mailboxDashBoardController.applyToVisibleEmailList(
        (emails) => emails.where((email) => email.id != emailIds.first).toList(),
      );

      final results = appProviderContainer
          .read(searchEmailPresentationProvider)
          .listResultSearch;
      expect(results.map((email) => email.id), emailIds.sublist(1));
      expect(mailboxDashBoardController.emailsInCurrentMailbox.length, 3);
      verifyNever(mailboxDashBoardController.updateEmailList(any));
    });

    test('publishes a transformed mailbox list when Search is inactive', () {
      when(searchController.isSearchEmailRunning).thenReturn(false);

      mailboxDashBoardController.applyToVisibleEmailList(
        (emails) => emails.where((email) => email.id != emailIds.first).toList(),
      );

      final updatedEmails = verify(
        mailboxDashBoardController.updateEmailList(captureAny),
      ).captured.single as List<PresentationEmail>;
      expect(updatedEmails.map((email) => email.id), emailIds.sublist(1));
    });

    test('does not transform the mailbox list when its action guard rejects it', () {
      when(searchController.isSearchEmailRunning).thenReturn(false);
      var wasTransformed = false;

      mailboxDashBoardController.applyToVisibleEmailList(
        (emails) {
          wasTransformed = true;
          return emails;
        },
        shouldApplyToMailboxList: () => false,
      );

      expect(wasTransformed, isFalse);
      verifyNever(mailboxDashBoardController.updateEmailList(any));
    });
  });

  group('search result mailbox move reconciliation', () {
    test('updates only successfully moved emails in the Riverpod result list', () {
      setSearchResults(mailboxEmails);

      mailboxDashBoardController.handleUpdateEmailsWithNewMailboxId(
        originalMailboxIdsWithEmailIds: {
          sourceMailboxId: [emailIds[1]],
        },
        destinationMailboxId: archiveMailboxId,
      );

      final results = appProviderContainer
          .read(searchEmailPresentationProvider)
          .listResultSearch;
      expect(results[0].mailboxIds, {sourceMailboxId: true});
      expect(results[1].mailboxIds, {archiveMailboxId: true});
      expect(results[1].mailboxContain?.id, archiveMailboxId);
      expect(results[2].mailboxIds, {sourceMailboxId: true});
      expect(mailboxDashBoardController.emailsInCurrentMailbox[1].mailboxIds,
          {sourceMailboxId: true});
    });

    test('combines successful ids from every source mailbox without changing failed emails', () {
      final secondSourceMailboxId = MailboxId(Id('second-source'));
      final results = [
        email(emailIds[0], sourceMailboxId),
        email(emailIds[1], secondSourceMailboxId),
        email(emailIds[2], sourceMailboxId),
      ];
      setSearchResults(results);

      mailboxDashBoardController.handleUpdateEmailsWithNewMailboxId(
        originalMailboxIdsWithEmailIds: {
          sourceMailboxId: [emailIds[0]],
          secondSourceMailboxId: [emailIds[1]],
        },
        destinationMailboxId: archiveMailboxId,
      );

      final updatedResults = appProviderContainer
          .read(searchEmailPresentationProvider)
          .listResultSearch;
      expect(updatedResults[0].mailboxIds, {archiveMailboxId: true});
      expect(updatedResults[1].mailboxIds, {archiveMailboxId: true});
      expect(updatedResults[2].mailboxIds, {sourceMailboxId: true});
    });

    test('does not update the Riverpod list when the responsive search presentation is inactive', () {
      appProviderContainer
          .read(searchEmailPresentationProvider.notifier)
          .setResultSearches(mailboxEmails);
      when(searchController.isSearchEmailRunning).thenReturn(false);

      mailboxDashBoardController.handleUpdateEmailsWithNewMailboxId(
        originalMailboxIdsWithEmailIds: {
          sourceMailboxId: [emailIds[0]],
        },
        destinationMailboxId: archiveMailboxId,
      );

      final results = appProviderContainer
          .read(searchEmailPresentationProvider)
          .listResultSearch;
      expect(results[0].mailboxIds, {sourceMailboxId: true});
      verify(mailboxDashBoardController.updateEmailList(any)).called(1);
    });

    testWidgets('keeps Riverpod results untouched for a web desktop search layout', (tester) async {
      PlatformInfo.isTestingForWeb = true;
      addTearDown(() => PlatformInfo.isTestingForWeb = false);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      when(mailboxDashBoardController.responsiveUtils)
          .thenReturn(_DesktopResponsiveUtils());
      await tester.pumpWidget(const GetMaterialApp(home: SizedBox()));
      setSearchResults(mailboxEmails);

      mailboxDashBoardController.handleUpdateEmailsWithNewMailboxId(
        originalMailboxIdsWithEmailIds: {
          sourceMailboxId: [emailIds[0]],
        },
        destinationMailboxId: archiveMailboxId,
      );

      final results = appProviderContainer
          .read(searchEmailPresentationProvider)
          .listResultSearch;
      expect(results[0].mailboxIds, {sourceMailboxId: true});
      verify(mailboxDashBoardController.updateEmailList(any)).called(1);
    });
  });

  group('search result permanent-delete reconciliation', () {
    test('removes successful deletion ids from Riverpod results regardless of the selected mailbox', () {
      setSearchResults(mailboxEmails);

      mailboxDashBoardController.handleDeleteEmailsInMailbox(
        emailIds: [emailIds[0], emailIds[2]],
        affectedMailboxId: MailboxId(Id('another-mailbox')),
      );

      final results = appProviderContainer
          .read(searchEmailPresentationProvider)
          .listResultSearch;
      expect(results.map((email) => email.id), [emailIds[1]]);
      expect(mailboxDashBoardController.emailsInCurrentMailbox.length, 3);
    });

    test('does not publish a new result list when no email was deleted', () {
      setSearchResults(mailboxEmails);
      final initialState = appProviderContainer.read(searchEmailPresentationProvider);

      mailboxDashBoardController.handleDeleteEmailsInMailbox(
        emailIds: const [],
        affectedMailboxId: sourceMailboxId,
      );

      expect(appProviderContainer.read(searchEmailPresentationProvider), initialState);
    });

    test('removes only emails from the cleared mailbox in Riverpod results', () {
      final otherMailboxId = MailboxId(Id('other'));
      setSearchResults([
        email(emailIds[0], sourceMailboxId),
        email(emailIds[1], otherMailboxId),
        email(emailIds[2], sourceMailboxId),
      ]);

      mailboxDashBoardController.handleClearAllEmailsInMailbox(sourceMailboxId);

      final results = appProviderContainer
          .read(searchEmailPresentationProvider)
          .listResultSearch;
      expect(results.map((email) => email.id), [emailIds[1]]);
    });
  });
}
