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

    List<PresentationMailbox> createTeamChildrenNamedLikeSystemFolders(
      PresentationMailbox parent,
    ) =>
        ['Outbox', 'outbox', 'Drafts', 'Templates']
            .map((name) => createTeamChild(name, parent))
            .toList();

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
      final teamSystemFolders = createTeamChildrenNamedLikeSystemFolders(teamRoot);
      final mailboxMap = mapOf([teamRoot, ...teamSystemFolders]);

      expect(
        teamSystemFolders.any((mailbox) => mailbox.isValidRuleActionTarget(mailboxMap)),
        isFalse,
      );
    });

    test('should be true for nested team folders named Outbox, Drafts or Templates', () {
      final nestedFolders = createTeamChildrenNamedLikeSystemFolders(teamProject);
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

    test('should be false for subfolders of personal Outbox, Drafts and Templates', () {
      final systemFolders = [
        createMailbox(id: 'outbox', role: PresentationMailbox.roleOutbox),
        createMailbox(id: 'drafts', role: PresentationMailbox.roleDrafts),
        createMailbox(id: 'templates', role: PresentationMailbox.roleTemplates),
      ];
      final subfolders = systemFolders
          .map((folder) => createMailbox(
                id: '${folder.id.id.value}_child',
                name: 'Invoices',
                parentId: folder.id.id.value,
              ))
          .toList();
      final mailboxMap = mapOf([...systemFolders, ...subfolders]);

      expect(
        subfolders.where((mailbox) => mailbox.isValidRuleActionTarget(mailboxMap)),
        isEmpty,
      );
    });

    test('should be false for every level below a first-level team Drafts', () {
      final teamDrafts = createTeamChild('Drafts', teamRoot);
      final archive = createTeamChild('Archive', teamDrafts);
      final archive2026 = createTeamChild('2026', archive);
      final mailboxMap = mapOf([teamRoot, teamDrafts, archive, archive2026]);

      expect(archive.isValidRuleActionTarget(mailboxMap), isFalse);
      expect(archive2026.isValidRuleActionTarget(mailboxMap), isFalse);
    });

    test('should stop on a parent cycle instead of looping forever', () {
      final first = createMailbox(id: 'first', name: 'First', parentId: 'second');
      final second = createMailbox(id: 'second', name: 'Second', parentId: 'first');

      expect(first.isValidRuleActionTarget(mapOf([first, second])), isTrue);
    });
  });

  group('PresentationMailboxExtension - isTeamMailboxRoot', () {
    PresentationMailbox createMailbox({
      String? namespace,
      String? parentIdVal,
    }) {
      return PresentationMailbox(
        MailboxId(Id('mailbox')),
        namespace: namespace != null ? Namespace(namespace) : null,
        parentId: parentIdVal != null ? MailboxId(Id(parentIdVal)) : null,
      );
    }

    test('Should be true for a top-level mailbox in a TeamMailbox namespace', () {
      final mailbox = createMailbox(namespace: 'TeamMailbox[team@example.com]');

      expect(mailbox.isTeamMailboxRoot, isTrue);
    });

    test('Should be false for a child folder of a team mailbox', () {
      final mailbox = createMailbox(
        namespace: 'TeamMailbox[team@example.com]',
        parentIdVal: 'team-root',
      );

      expect(mailbox.isTeamMailboxRoot, isFalse);
    });

    test('Should be false for a top-level folder shared through ACL', () {
      final mailbox = createMailbox(namespace: 'Delegated[bob@example.com]');

      expect(mailbox.isTeamMailboxes, isTrue);
      expect(mailbox.isTeamMailboxRoot, isFalse);
    });

    test('Should be false for a personal mailbox', () {
      expect(createMailbox(namespace: 'Personal').isTeamMailboxRoot, isFalse);
    });

    test('Should be false for a mailbox without namespace', () {
      expect(createMailbox().isTeamMailboxRoot, isFalse);
    });
  });
}
