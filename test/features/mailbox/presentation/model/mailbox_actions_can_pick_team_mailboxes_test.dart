import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';

void main() {
  group('MailboxActionsExtension::canPickTeamMailboxes', () {
    test('should allow picking team mailboxes when selecting a folder for search', () {
      expect(MailboxActions.select.canPickTeamMailboxes(), isTrue);
    });

    test('should allow picking team mailboxes when moving emails', () {
      expect(MailboxActions.moveEmail.canPickTeamMailboxes(), isTrue);
      expect(MailboxActions.moveFolderContent.canPickTeamMailboxes(), isTrue);
    });

    test('should not allow picking team mailboxes for folder management actions', () {
      expect(MailboxActions.create.canPickTeamMailboxes(), isFalse);
      expect(MailboxActions.move.canPickTeamMailboxes(), isFalse);
      expect(MailboxActions.selectForRuleAction.canPickTeamMailboxes(), isFalse);
    });
  });

  group('MailboxActionsExtension::canPickMailbox', () {
    final teamNamespace = Namespace('TeamMailbox[team@example.com]');
    final teamMailboxRoot = PresentationMailbox(
      MailboxId(Id('team-root')),
      namespace: teamNamespace,
    );

    test('should not allow picking a team mailbox root as a search scope', () {
      expect(MailboxActions.select.canPickMailbox(teamMailboxRoot), isFalse);
    });

    test('should allow picking a team mailbox folder as a search scope', () {
      final teamMailboxInbox = PresentationMailbox(
        MailboxId(Id('team-inbox')),
        parentId: MailboxId(Id('team-root')),
        namespace: teamNamespace,
      );

      expect(MailboxActions.select.canPickMailbox(teamMailboxInbox), isTrue);
    });

    test('should allow picking a top-level folder shared through ACL as a search scope', () {
      final sharedTopLevelFolder = PresentationMailbox(
        MailboxId(Id('shared-folder')),
        namespace: Namespace('Delegated[bob@example.com]'),
      );

      expect(MailboxActions.select.canPickMailbox(sharedTopLevelFolder), isTrue);
    });

    test('should allow picking a personal folder as a search scope', () {
      final personalInbox = PresentationMailbox(MailboxId(Id('inbox')));

      expect(MailboxActions.select.canPickMailbox(personalInbox), isTrue);
    });

    test('should allow picking a team mailbox root when moving an email', () {
      expect(MailboxActions.moveEmail.canPickMailbox(teamMailboxRoot), isTrue);
    });
  });
}
