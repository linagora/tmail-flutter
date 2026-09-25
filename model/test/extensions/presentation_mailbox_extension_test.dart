import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

void main() {
  group('PresentationMailboxExtension - isValidRuleActionTarget', () {
    PresentationMailbox createMailbox({Role? role, String? name}) {
      return PresentationMailbox(
        MailboxId(Id('mailbox_id')),
        role: role,
        name: name != null ? MailboxName(name) : null,
      );
    }

    test('should be false for Outbox', () {
      expect(
        createMailbox(role: PresentationMailbox.roleOutbox).isValidRuleActionTarget,
        isFalse,
      );
    });

    test('should be false for Outbox identified by name', () {
      expect(
        createMailbox(name: PresentationMailbox.outboxRole).isValidRuleActionTarget,
        isFalse,
      );
    });

    test('should be false for Drafts', () {
      expect(
        createMailbox(role: PresentationMailbox.roleDrafts).isValidRuleActionTarget,
        isFalse,
      );
    });

    test('should be false for Templates', () {
      expect(
        createMailbox(role: PresentationMailbox.roleTemplates).isValidRuleActionTarget,
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
        validMailboxes.every((mailbox) => mailbox.isValidRuleActionTarget),
        isTrue,
      );
    });
  });
}
