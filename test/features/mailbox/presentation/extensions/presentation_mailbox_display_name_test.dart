import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_rights.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class _DistinctAppLocalizations extends AppLocalizations {
  @override
  String get inboxMailboxDisplayName => 'localized-inbox';

  @override
  String get draftsMailboxDisplayName => 'localized-drafts';

  @override
  String get outboxMailboxDisplayName => 'localized-outbox';

  @override
  String get sentMailboxDisplayName => 'localized-sent';

  @override
  String get trashMailboxDisplayName => 'localized-trash';

  @override
  String get templatesMailboxDisplayName => 'localized-templates';
}

void main() {
  final appLocalizations = _DistinctAppLocalizations();

  PresentationMailbox teamMailboxChild(String name, {required bool mayDelete}) =>
      PresentationMailbox(
        MailboxId(Id('team-$name')),
        name: MailboxName(name),
        parentId: MailboxId(Id('team-root')),
        namespace: Namespace('Delegated[team@example.com]'),
        myRights: MailboxRights(
          true, true, true, true, true, true, true, mayDelete, true),
      );

  group('PresentationMailboxExtension::getDisplayNameWithoutContext', () {
    test('localizes team mailbox system folders like personal ones', () {
      final expectations = <String, String>{
        'INBOX': 'localized-inbox',
        'Drafts': 'localized-drafts',
        'Outbox': 'localized-outbox',
        'Sent': 'localized-sent',
        'Trash': 'localized-trash',
        'Templates': 'localized-templates',
      };

      expectations.forEach((name, expected) {
        expect(
          teamMailboxChild(name, mayDelete: false)
              .getDisplayNameWithoutContext(appLocalizations),
          expected,
          reason: name,
        );
      });
    });

    test('keeps raw name for deletable team mailbox folders', () {
      expect(
        teamMailboxChild('INBOX', mayDelete: true)
            .getDisplayNameWithoutContext(appLocalizations),
        'INBOX',
      );
    });

    test('keeps raw name for undeletable team folders without system name', () {
      expect(
        teamMailboxChild('Projects', mayDelete: false)
            .getDisplayNameWithoutContext(appLocalizations),
        'Projects',
      );
    });

    test('localizes personal system folders by role', () {
      final inbox = PresentationMailbox(
        MailboxId(Id('inbox')),
        name: MailboxName('INBOX'),
        role: Role('inbox'),
      );

      expect(
        inbox.getDisplayNameWithoutContext(appLocalizations),
        'localized-inbox',
      );
    });
  });
}
