import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:labels/model/label.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/presentation_label_mailbox.dart';

void main() {
  group('PresentationMailboxExtension::isLabelMailboxRemovedFrom', () {
    final workLabel = Label(id: Id('work'), displayName: 'Work');
    final homeLabel = Label(id: Id('home'), displayName: 'Home');
    final workLabelMailbox = PresentationLabelMailbox.initial(workLabel);

    test('should return true when the selected label was deleted', () {
      expect(workLabelMailbox.isLabelMailboxRemovedFrom([homeLabel]), isTrue);
    });

    test('should return true when all labels were removed', () {
      expect(workLabelMailbox.isLabelMailboxRemovedFrom([]), isTrue);
    });

    test('should return false when the selected label still exists', () {
      expect(
        workLabelMailbox.isLabelMailboxRemovedFrom([homeLabel, workLabel]),
        isFalse,
      );
    });

    test('should return false when the selected label was renamed', () {
      final renamedWorkLabel = Label(id: Id('work'), displayName: 'Job');

      expect(
        workLabelMailbox.isLabelMailboxRemovedFrom([renamedWorkLabel]),
        isFalse,
      );
    });

    test('should return false for a regular mailbox', () {
      final inbox = PresentationMailbox(
        MailboxId(Id('inbox')),
        role: PresentationMailbox.roleInbox,
      );

      expect(inbox.isLabelMailboxRemovedFrom([]), isFalse);
    });
  });
}
