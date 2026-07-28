import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/quick_search/email_quick_search_item_tile_widget.dart';

void main() {
  final sender = EmailAddress('Alice Sender', 'alice@example.com');
  final recipient = EmailAddress('Bob Recipient', 'bob@example.com');
  final email = PresentationEmail(
    id: EmailId(Id('email-1')),
    subject: 'Subject',
    from: {sender},
    to: {recipient},
  );

  PresentationMailbox mailboxWithRole(Role role) =>
      PresentationMailbox(MailboxId(Id(role.value)), role: role);

  // The tile keys off the currently-selected folder, not the email itself.
  Widget wrapTile(PresentationMailbox? selectedMailbox) {
    return MaterialApp(
      home: Scaffold(
        body: EmailQuickSearchItemTileWidget(email, selectedMailbox),
      ),
    );
  }

  Finder senderFinder() =>
      find.textContaining('Alice Sender', findRichText: true);
  Finder recipientFinder() =>
      find.textContaining('Bob Recipient', findRichText: true);

  setUp(() => Get.put(ImagePaths()));

  tearDown(Get.reset);

  for (final role in [
    PresentationMailbox.roleSent,
    PresentationMailbox.roleDrafts,
    PresentationMailbox.roleOutbox,
  ]) {
    testWidgets('shows recipients when an outgoing folder ($role) is selected',
        (tester) async {
      await tester.pumpWidget(wrapTile(mailboxWithRole(role)));

      expect(recipientFinder(), findsOneWidget);
      expect(senderFinder(), findsNothing);
    });
  }

  testWidgets('shows the sender when a received folder is selected',
      (tester) async {
    await tester.pumpWidget(wrapTile(mailboxWithRole(PresentationMailbox.roleInbox)));

    expect(senderFinder(), findsOneWidget);
    expect(recipientFinder(), findsNothing);
  });

  testWidgets('shows the sender when no folder is selected', (tester) async {
    await tester.pumpWidget(wrapTile(null));

    expect(senderFinder(), findsOneWidget);
  });
}
