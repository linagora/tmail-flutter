import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

void main() {
  group('PresentationMailboxExtension - isValidRuleActionTarget', () {
    final teamNamespace = Namespace('Delegated[team@example.com]');

    PresentationMailbox createMailbox({
      String id = 'mailbox_id',
      Role? role,
      String? name,
      String? parentId,
      Namespace? namespace,
    }) {
      return PresentationMailbox(
        MailboxId(Id(id)),
        role: role,
        name: name != null ? MailboxName(name) : null,
        parentId: parentId != null ? MailboxId(Id(parentId)) : null,
        namespace: namespace,
      );
    }

    final teamRoot = createMailbox(
      id: 'team_root',
      name: 'Team',
      namespace: teamNamespace,
    );
    final teamProject = createMailbox(
      id: 'team_project',
      name: 'Project',
      parentId: teamRoot.id.id.value,
      namespace: teamNamespace,
    );

    PresentationMailbox createTeamChild(String name, PresentationMailbox parent) {
      return createMailbox(
        id: 'team_$name',
        name: name,
        parentId: parent.id.id.value,
        namespace: teamNamespace,
      );
    }

    Map<MailboxId, PresentationMailbox> mapOf(List<PresentationMailbox> mailboxes) =>
        {for (final mailbox in mailboxes) mailbox.id: mailbox};

    test('should be false for Outbox', () {
      expect(
        createMailbox(role: PresentationMailbox.roleOutbox).isValidRuleActionTarget({}),
        isFalse,
      );
    });

    test('should be false for Outbox identified by name', () {
      expect(
        createMailbox(name: PresentationMailbox.outboxRole).isValidRuleActionTarget({}),
        isFalse,
      );
    });

    test('should be false for Drafts', () {
      expect(
        createMailbox(role: PresentationMailbox.roleDrafts).isValidRuleActionTarget({}),
        isFalse,
      );
    });

    test('should be false for Templates', () {
      expect(
        createMailbox(role: PresentationMailbox.roleTemplates).isValidRuleActionTarget({}),
        isFalse,
      );
    });

    test('should be true for Inbox, Archive, Trash and custom folders', () {
      final validMailboxes = [
        createMailbox(role: PresentationMailbox.roleInbox),
        createMailbox(role: PresentationMailbox.roleArchive),
        createMailbox(role: PresentationMailbox.roleTrash),
        createMailbox(name: 'Custom folder'),
      ];

      expect(
        validMailboxes.every((mailbox) => mailbox.isValidRuleActionTarget({})),
        isTrue,
      );
    });

    test('should be false for first-level team Outbox, Drafts and Templates regardless of case', () {
      final teamSystemFolders = ['Outbox', 'outbox', 'Drafts', 'Templates']
          .map((name) => createTeamChild(name, teamRoot))
          .toList();
      final mailboxMap = mapOf([teamRoot, ...teamSystemFolders]);

      expect(
        teamSystemFolders.any((mailbox) => mailbox.isValidRuleActionTarget(mailboxMap)),
        isFalse,
      );
    });

    test('should be true for nested team folders named Outbox, Drafts or Templates', () {
      final nestedFolders = ['Outbox', 'outbox', 'Drafts', 'Templates']
          .map((name) => createTeamChild(name, teamProject))
          .toList();
      final mailboxMap = mapOf([teamRoot, teamProject, ...nestedFolders]);

      expect(
        nestedFolders.every((mailbox) => mailbox.isValidRuleActionTarget(mailboxMap)),
        isTrue,
      );
    });

    test('should be true for team root and team custom folders', () {
      final mailboxMap = mapOf([teamRoot, teamProject]);

      expect(
        [teamRoot, teamProject].every((mailbox) => mailbox.isValidRuleActionTarget(mailboxMap)),
        isTrue,
      );
    });
  });
}
