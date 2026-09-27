import 'package:flutter_test/flutter_test.dart';
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
}
