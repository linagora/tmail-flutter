import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/restore_mailbox_email_list_after_search_extension.dart';

import 'restore_mailbox_email_list_after_search_extension_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MailboxDashBoardController>(),
  MockSpec<SearchController>(),
])
void main() {
  final mailboxDashBoardController = MockMailboxDashBoardController();
  final searchController = MockSearchController();
  final inboxMailbox = PresentationMailbox(
    MailboxId(Id('inbox')),
    role: PresentationMailbox.roleInbox,
  );
  final otherMailbox = PresentationMailbox(MailboxId(Id('other')));

  setUp(() {
    when(mailboxDashBoardController.searchController)
        .thenReturn(searchController);
  });

  tearDown(() {
    reset(mailboxDashBoardController);
    reset(searchController);
  });

  group('shouldRestoreMailboxEmailListAfterSearch test:', () {
    test('returns true when the mailbox is selected and search is running', () {
      when(mailboxDashBoardController.selectedMailbox)
          .thenReturn(Rxn(inboxMailbox));
      when(searchController.isSearchEmailRunning).thenReturn(true);

      expect(
        mailboxDashBoardController
            .shouldRestoreMailboxEmailListAfterSearch(inboxMailbox),
        isTrue,
      );
    });

    test('returns false when another mailbox is selected', () {
      when(mailboxDashBoardController.selectedMailbox)
          .thenReturn(Rxn(otherMailbox));
      when(searchController.isSearchEmailRunning).thenReturn(true);

      expect(
        mailboxDashBoardController
            .shouldRestoreMailboxEmailListAfterSearch(inboxMailbox),
        isFalse,
      );
    });

    test('returns false when search is not running', () {
      when(mailboxDashBoardController.selectedMailbox)
          .thenReturn(Rxn(inboxMailbox));
      when(searchController.isSearchEmailRunning).thenReturn(false);

      expect(
        mailboxDashBoardController
            .shouldRestoreMailboxEmailListAfterSearch(inboxMailbox),
        isFalse,
      );
    });
  });

  group('restoreMailboxEmailListAfterSearch test:', () {
    test('dispatches a forced RestoreMailboxEmailListAfterSearchAction', () {
      mailboxDashBoardController.restoreMailboxEmailListAfterSearch();

      final action = verify(
        mailboxDashBoardController.dispatchAction(captureAny),
      ).captured.single;
      expect(action, isA<RestoreMailboxEmailListAfterSearchAction>());
      expect(
        (action as RestoreMailboxEmailListAfterSearchAction).force,
        isTrue,
      );
    });
  });
}
