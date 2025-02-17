
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
        return _handleReply(
          isSender: isSender,
          newToAddress: newToAddress,
          newFromAddress: newFromAddress,
          newReplyToAddress: newReplyToAddress,
          userName: userName,
        );

      case EmailActionType.replyToList:
        return _handleReplyToList(listPost, userName);

      case EmailActionType.replyAll:
        return _handleReplyAll(
          isSender: isSender,
          newToAddress: newToAddress,
          newCcAddress: newCcAddress,
          newBccAddress: newBccAddress,
          newReplyToAddress: newReplyToAddress,
          newFromAddress: newFromAddress,
          userName: userName,
        );

      default:
        return Tuple4(newToAddress, newCcAddress, newBccAddress, newReplyToAddress);
    }
  }

  Tuple4<List<EmailAddress>, List<EmailAddress>, List<EmailAddress>, List<EmailAddress>> _handleReply({
    required bool isSender,
    required List<EmailAddress> newToAddress,
    required List<EmailAddress> newFromAddress,
    required List<EmailAddress> newReplyToAddress,
    String? userName,
  }) {
    if (isSender) {
      return Tuple4(newToAddress, [], [], newReplyToAddress);
    }
    final listToAddress = newReplyToAddress.isNotEmpty
        ? newReplyToAddress.withoutMe(userName)
        : newFromAddress.withoutMe(userName);
    return Tuple4(listToAddress, [], [], []);
  }

  Tuple4<List<EmailAddress>, List<EmailAddress>, List<EmailAddress>, List<EmailAddress>> _handleReplyToList(String? listPost, String? userName) {
    final recipientRecord = EmailUtils.extractRecipientsFromListPost(listPost ?? '');

    return Tuple4(
      recipientRecord.toMailAddresses.removeDuplicateEmails().withoutMe(userName),
      recipientRecord.ccMailAddresses.removeDuplicateEmails().withoutMe(userName),
      recipientRecord.bccMailAddresses.removeDuplicateEmails().withoutMe(userName),
      [],
    );
  }

  Tuple4<List<EmailAddress>, List<EmailAddress>, List<EmailAddress>, List<EmailAddress>> _handleReplyAll({
    required bool isSender,
    required List<EmailAddress> newToAddress,
    required List<EmailAddress> newCcAddress,
    required List<EmailAddress> newBccAddress,
    required List<EmailAddress> newReplyToAddress,
    required List<EmailAddress> newFromAddress,
    String? userName,
  }) {
    if (isSender) {
      return Tuple4(newToAddress, newCcAddress, newBccAddress, newReplyToAddress);
    }

    final listToAddress = {
      ...(newReplyToAddress.isNotEmpty ? newReplyToAddress : newFromAddress),
      ...newToAddress,
    }.removeDuplicateEmails().withoutMe(userName);

    return Tuple4(
      listToAddress,
      newCcAddress.withoutMe(userName),
      newBccAddress.withoutMe(userName),
      [],
    );
  }

}