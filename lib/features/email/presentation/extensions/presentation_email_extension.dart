
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

extension PresentationEmailExtension on PresentationEmail {
  Tuple4<List<EmailAddress>, List<EmailAddress>, List<EmailAddress>, List<EmailAddress>> generateRecipientsEmailAddressForComposer({
    required EmailActionType emailActionType,
    bool isSender = false,
    String? userName,
    String? listPost,
  }) {
    final newFromAddress = from.removeDuplicateEmails();
    final newToAddress = to.removeDuplicateEmails();
    final newCcAddress = cc.removeDuplicateEmails();
    final newBccAddress = bcc.removeDuplicateEmails();
    final newReplyToAddress = replyTo.removeDuplicateEmails();

    switch (emailActionType) {
      case EmailActionType.reply:
        var listReplyAddress = <EmailAddress>[];
        if (newReplyToAddress.withoutMe(userName).isNotEmpty) {
          listReplyAddress = newReplyToAddress;
        } else if (isSender) {
          listReplyAddress = newToAddress;
        } else {
          listReplyAddress = newFromAddress;
        }

        final listReplyAddressWithoutUsername = listReplyAddress.withoutMe(userName);

        return Tuple4(listReplyAddressWithoutUsername, [], [], []);
      case EmailActionType.replyToList:
        final recipientRecord = EmailUtils.extractRecipientsFromListPost(listPost ?? '');

        final listToAddressWithoutUsername = recipientRecord.toMailAddresses
          .toSet()
          .removeDuplicateEmails()
          .withoutMe(userName);

        final listCcAddressWithoutUsername = recipientRecord.ccMailAddresses
          .toSet()
          .removeDuplicateEmails()
          .withoutMe(userName);

        final listBccAddressWithoutUsername = recipientRecord.bccMailAddresses
          .toSet()
          .removeDuplicateEmails()
          .withoutMe(userName);

        return Tuple4(
          listToAddressWithoutUsername,
          listCcAddressWithoutUsername,
          listBccAddressWithoutUsername,
          [],
        );
      case EmailActionType.replyAll:
        final recipientRecord = EmailUtils.extractRecipientsFromListPost(listPost ?? '');

        final listToAddress = recipientRecord.toMailAddresses
          + newReplyToAddress
          + newFromAddress
          + newToAddress;
        final listCcAddress = recipientRecord.ccMailAddresses + newCcAddress;
        final listBccAddress = recipientRecord.bccMailAddresses + newBccAddress;

        final listToAddressWithoutUsername = listToAddress
          .toSet()
          .removeDuplicateEmails()
          .withoutMe(userName);
        final listCcAddressWithoutUsername = listCcAddress
          .toSet()
          .removeDuplicateEmails()
          .withoutMe(userName);
        final listBccAddressWithoutUsername = listBccAddress
          .toSet()
          .removeDuplicateEmails()
          .withoutMe(userName);
        final listReplyToAddressWithoutUsername = newReplyToAddress
          .toSet()
          .removeDuplicateEmails()
          .withoutMe(userName);

        return Tuple4(
          listToAddressWithoutUsername,
          listCcAddressWithoutUsername,
          listBccAddressWithoutUsername,
          listReplyToAddressWithoutUsername,
        );
      default:
        final listToAddressWithoutUsername = newToAddress.withoutMe(userName);
        final listCcAddressWithoutUsername = newCcAddress.withoutMe(userName);
        final listBccAddressWithoutUsername = newBccAddress.withoutMe(userName);
        final listReplyToAddressWithoutUsername = newReplyToAddress.withoutMe(userName);

        return Tuple4(
          listToAddressWithoutUsername,
          listCcAddressWithoutUsername,
          listBccAddressWithoutUsername,
          listReplyToAddressWithoutUsername,
        );
    }
  }
}