import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_property.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

void main() {
  group('EmailExtension::hasReadReceipt:', () {
    late Email email;
    late Map<MailboxId, PresentationMailbox> mailboxMap;

    setUp(() {
      mailboxMap = {};
    });

    test('Should return true when the email contains a Disposition-Notification-To header, has no \$mdnsent keyword, and is not in the sent mailbox', () {
      email = Email(
        headers: {
          EmailHeader(
            EmailProperty.headerMdnKey,
            'user@example.com',
          ),
        },
        keywords: {},
        mailboxIds: {
          MailboxId(Id('inbox')): true
        }
      );
      mailboxMap[MailboxId(Id('inbox'))] = PresentationMailbox(
        MailboxId(Id('inbox')),
        role: PresentationMailbox.roleInbox,
      );

      expect(email.hasReadReceipt(mailboxMap), isTrue);
    });

    test('Should return false when the email contains the \$mdnsent keyword', () {
      email = Email(
        headers: {
          EmailHeader(
            EmailProperty.headerMdnKey,
            'user@example.com',
          ),
        },
        keywords: {
          KeyWordIdentifier.mdnSent: true,
        },
        mailboxIds: {
          MailboxId(Id('inbox')): true
        }
      );
      mailboxMap[MailboxId(Id('inbox'))] = PresentationMailbox(
        MailboxId(Id('inbox')),
        role: PresentationMailbox.roleInbox,
      );

      expect(email.hasReadReceipt(mailboxMap), isFalse);
    });

    test('Should return false when the email does not contain a Disposition-Notification-To header', () {
      email = Email(
        headers: {},
        keywords: {},
        mailboxIds: {
          MailboxId(Id('inbox')): true
        }
      );
      mailboxMap[MailboxId(Id('inbox'))] = PresentationMailbox(
        MailboxId(Id('inbox')),
        role: PresentationMailbox.roleInbox,
      );

      expect(email.hasReadReceipt(mailboxMap), isFalse);
    });

    test('Should return false when the email is in the sent mailbox', () {
      email = Email(
        headers: {
          EmailHeader(
            EmailProperty.headerMdnKey,
            'user@example.com',
          ),
        },
        keywords: {},
        mailboxIds: {
          MailboxId(Id('sent')): true
        }
      );
      mailboxMap[MailboxId(Id('sent'))] = PresentationMailbox(
        MailboxId(Id('sent')),
        role: PresentationMailbox.roleSent,
      );

      expect(email.hasReadReceipt(mailboxMap), isFalse);
    });

    test('Should return true when mailboxCurrent is null, the email contains a Disposition-Notification-To header, and has no \$mdnsent keyword', () {
      email = Email(
        headers: {
          EmailHeader(
            EmailProperty.headerMdnKey,
            'user@example.com',
          ),
        },
        keywords: {},
        mailboxIds: {},
      );
      mailboxMap = {};

      expect(email.hasReadReceipt(mailboxMap), isTrue);
    });
  });
}