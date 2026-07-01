import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/keyword_identifier_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_current_emails_flags_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';

import 'update_current_emails_flags_extension_test.mocks.dart';

@GenerateNiceMocks([MockSpec<MailboxDashBoardController>()])
void main() {
  const numberOfEmails = 3;
  late List<EmailId> emailIds;
  final mailboxDashBoardController = MockMailboxDashBoardController();

  /// Stubs `emailsInCurrentMailbox` with one email per id, each seeded with its
  /// own copy of [keywords] (independent maps so in-place flag updates on one
  /// email never leak into another).
  void stubEmails([Map<KeyWordIdentifier, bool> keywords = const {}]) {
    when(mailboxDashBoardController.emailsInCurrentMailbox).thenReturn(
      emailIds
          .map((emailId) => PresentationEmail(id: emailId, keywords: {...keywords}))
          .toList()
          .obs,
    );
  }

  /// Asserts [flag] evaluated over the current list emails equals [expected],
  /// position by position.
  void expectFlagPerEmail(
    bool Function(PresentationEmail email) flag,
    List<bool> expected,
  ) {
    final actual =
        mailboxDashBoardController.emailsInCurrentMailbox.map(flag).toList();
    expect(actual, expected);
  }

  void dismissWarning(EmailId emailId, {int index = 0, bool dismissed = true}) {
    mailboxDashBoardController.updateEmailTwpWarningDismissed(
      emailId,
      index,
      dismissed: dismissed,
    );
  }

  setUp(() {
    emailIds = List.generate(
      numberOfEmails,
      (index) => EmailId(Id('email-id-$index')),
    );
    when(mailboxDashBoardController.dashboardRoute)
        .thenReturn(DashboardRoutes.thread.obs);
  });

  group('updateEmailFlagByEmailIds test:', () {
    test('should mark emails as read', () {
      stubEmails();

      mailboxDashBoardController.updateEmailFlagByEmailIds(
        emailIds.sublist(1),
        readAction: ReadActions.markAsRead,
      );

      expectFlagPerEmail((email) => email.hasRead, [false, true, true]);
    });

    test('should mark emails as unread', () {
      stubEmails({KeyWordIdentifier.emailSeen: true});

      mailboxDashBoardController.updateEmailFlagByEmailIds(
        emailIds.sublist(1),
        readAction: ReadActions.markAsUnread,
      );

      expectFlagPerEmail((email) => email.hasRead, [true, false, false]);
    });

    test('should mark emails as starred', () {
      stubEmails();

      mailboxDashBoardController.updateEmailFlagByEmailIds(
        emailIds.sublist(1),
        markStarAction: MarkStarAction.markStar,
      );

      expectFlagPerEmail((email) => email.hasStarred, [false, true, true]);
    });

    test('should mark emails as unstarred', () {
      stubEmails({KeyWordIdentifier.emailFlagged: true});

      mailboxDashBoardController.updateEmailFlagByEmailIds(
        emailIds.sublist(1),
        markStarAction: MarkStarAction.unMarkStar,
      );

      expectFlagPerEmail((email) => email.hasStarred, [true, false, false]);
    });
  });

  group('updateEmailTwpWarningDismissed test:', () {
    test('should add the dismissed keyword to the matching list email', () {
      stubEmails();

      dismissWarning(emailIds[1]);

      expectFlagPerEmail(
        (email) => email.isTwpWarningDismissed(0),
        [false, true, false],
      );
    });

    test('should remove the dismissed keyword when dismissed is false', () {
      stubEmails({KeyWordIdentifierExtension.twpWarningDismissed(0): true});

      dismissWarning(emailIds[1], dismissed: false);

      expectFlagPerEmail(
        (email) => email.isTwpWarningDismissed(0),
        [true, false, true],
      );
    });

    test('should keep other warning indexes untouched', () {
      stubEmails({KeyWordIdentifierExtension.twpWarningDismissed(1): true});

      dismissWarning(emailIds[1]);

      expectFlagPerEmail(
        (email) => email.isTwpWarningDismissed(0),
        [false, true, false],
      );
      expectFlagPerEmail(
        (email) => email.isTwpWarningDismissed(1),
        [true, true, true],
      );
    });

    test('should do nothing when no list email matches the id', () {
      stubEmails();

      dismissWarning(EmailId(Id('not-in-list')));

      expectFlagPerEmail(
        (email) => email.isTwpWarningDismissed(0),
        [false, false, false],
      );
    });
  });
}
