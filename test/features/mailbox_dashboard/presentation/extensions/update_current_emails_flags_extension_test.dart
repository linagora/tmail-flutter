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
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_current_emails_flags_extension.dart';

import 'update_current_emails_flags_extension_test.mocks.dart';

@GenerateNiceMocks([MockSpec<MailboxDashBoardController>()])
void main() {
  const numberOfEmails = 3;
  late List<EmailId> emailIds;
  final mailboxDashBoardController = MockMailboxDashBoardController();

  setUp(() {
    emailIds = List.generate(
      numberOfEmails,
      (index) => EmailId(Id('email-id-$index')),
    );
  });

  group('updateEmailFlagByEmailIds test:', () {
    test(
      'should mark emails as read',
    () {
      // arrange
      final readEmailIds = emailIds.sublist(1);
      when(mailboxDashBoardController.emailsInCurrentMailbox).thenReturn(
        emailIds.map((emailId) => PresentationEmail(
          id: emailId,
          keywords: {},
        )).toList().obs,
      );
      expect(
        mailboxDashBoardController.emailsInCurrentMailbox.every(
          (presentationEmail) => !presentationEmail.hasRead,
        ),
        true,
      );
      
      // act
      mailboxDashBoardController.updateEmailFlagByEmailIds(
        readEmailIds,
        readAction: ReadActions.markAsRead,
      );
      
      // assert
      expect(mailboxDashBoardController.emailsInCurrentMailbox[0].hasRead, false);
      expect(mailboxDashBoardController.emailsInCurrentMailbox[1].hasRead, true);
      expect(mailboxDashBoardController.emailsInCurrentMailbox[2].hasRead, true);
    });

    test(
      'should mark emails as unread',
    () {
      // arrange
      final unreadEmailIds = emailIds.sublist(1);
      when(mailboxDashBoardController.emailsInCurrentMailbox).thenReturn(
        emailIds.map((emailId) => PresentationEmail(
          id: emailId,
          keywords: {KeyWordIdentifier.emailSeen: true},
        )).toList().obs,
      );
      expect(
        mailboxDashBoardController.emailsInCurrentMailbox.every(
          (presentationEmail) => presentationEmail.hasRead,
        ),
        true,
      );
      
      // act
      mailboxDashBoardController.updateEmailFlagByEmailIds(
        unreadEmailIds,
        readAction: ReadActions.markAsUnread,
      );
      
      // assert
      expect(mailboxDashBoardController.emailsInCurrentMailbox[0].hasRead, true);
      expect(mailboxDashBoardController.emailsInCurrentMailbox[1].hasRead, false);
      expect(mailboxDashBoardController.emailsInCurrentMailbox[2].hasRead, false);
    });

    test(
      'should mark emails as starred',
    () {
      // arrange
      final starredEmailIds = emailIds.sublist(1);
      when(mailboxDashBoardController.emailsInCurrentMailbox).thenReturn(
        emailIds.map((emailId) => PresentationEmail(
          id: emailId,
          keywords: {},
        )).toList().obs,
      );
      expect(
        mailboxDashBoardController.emailsInCurrentMailbox.every(
          (presentationEmail) => !presentationEmail.hasStarred,
        ),
        true,
      );
      
      // act
      mailboxDashBoardController.updateEmailFlagByEmailIds(
        starredEmailIds,
        markStarAction: MarkStarAction.markStar,
      );
      
      // assert
      expect(mailboxDashBoardController.emailsInCurrentMailbox[0].hasStarred, false);
      expect(mailboxDashBoardController.emailsInCurrentMailbox[1].hasStarred, true);
      expect(mailboxDashBoardController.emailsInCurrentMailbox[2].hasStarred, true);
    });

    test(
      'should mark emails as unstarred',
    () {
      // arrange
      final unstarredEmailIds = emailIds.sublist(1);
      when(mailboxDashBoardController.emailsInCurrentMailbox).thenReturn(
        emailIds.map((emailId) => PresentationEmail(
          id: emailId,
          keywords: {KeyWordIdentifier.emailFlagged: true},
        )).toList().obs,
      );
      expect(
        mailboxDashBoardController.emailsInCurrentMailbox.every(
          (presentationEmail) => presentationEmail.hasStarred,
        ),
        true,
      );
      
      // act
      mailboxDashBoardController.updateEmailFlagByEmailIds(
        unstarredEmailIds,
        markStarAction: MarkStarAction.unMarkStar,
      );
      
      // assert
      expect(mailboxDashBoardController.emailsInCurrentMailbox[0].hasStarred, true);
      expect(mailboxDashBoardController.emailsInCurrentMailbox[1].hasStarred, false);
      expect(mailboxDashBoardController.emailsInCurrentMailbox[2].hasStarred, false);
    });
  });
}