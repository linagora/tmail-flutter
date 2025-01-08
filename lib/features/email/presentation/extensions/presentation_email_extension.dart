
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

extension PresentationEmailExtension on PresentationEmail {
  Tuple3<List<EmailAddress>, List<EmailAddress>, List<EmailAddress>> generateRecipientsEmailAddressForComposer({
    required EmailActionType emailActionType,
    Role? mailboxRole,
    String? listPost,
  }) {
    switch (emailActionType) {
      case EmailActionType.reply:
        if (mailboxRole == PresentationMailbox.roleSent) {
          return Tuple3(to.asList(), [], []);
        } else {
          final replyToAddress = replyTo.asList().isNotEmpty
            ? replyTo.asList()
            : from.asList();
          return Tuple3(replyToAddress, [], []);
        }
      case EmailActionType.replyToList:
        final listEmailAddress = EmailUtils.parsingListPost(listPost ?? '') ?? [];
        log('PresentationEmailExtension::generateRecipientsEmailAddressForComposer:listEmailAddress = $listEmailAddress');
        return Tuple3(listEmailAddress, [], []);
      case EmailActionType.replyAll:
        if (mailboxRole == PresentationMailbox.roleSent) {
          return Tuple3(to.asList(), cc.asList(), bcc.asList());
        } else {
          final senderReplyToAddress = replyTo.asList().isNotEmpty
            ? replyTo.asList()
            : from.asList();
          return Tuple3(
            to.asList() + senderReplyToAddress,
            cc.asList(),
            bcc.asList(),
          );
        }
      default:
        return Tuple3(to.asList(), cc.asList(), bcc.asList());
    }
  }
}