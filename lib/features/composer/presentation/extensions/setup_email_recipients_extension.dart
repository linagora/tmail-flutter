
import 'package:model/email/email_action_type.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';

extension SetupEmailRecipientsExtension on ComposerController {

  void setupEmailRecipients(ComposerArguments arguments) {
    switch(currentEmailActionType) {
      case EmailActionType.editAsNewEmail:
      case EmailActionType.editDraft:
      case EmailActionType.reopenComposerBrowser:
        initEmailAddress(
          presentationEmail: arguments.presentationEmail!,
          actionType: currentEmailActionType!,
        );
        break;
      case EmailActionType.editSendingEmail:
        initEmailAddress(
          presentationEmail: arguments.sendingEmail!.presentationEmail,
          actionType: currentEmailActionType!,
        );
        break;
      case EmailActionType.composeFromEmailAddress:
      case EmailActionType.composeFromUnsubscribeMailtoLink:
        final emailAddressOfTo = arguments.listEmailAddress ?? [];
        if (emailAddressOfTo.isNotEmpty) {
          listToEmailAddress.addAll(emailAddressOfTo);
          isInitialRecipient.value = true;
          toAddressExpandMode.value = ExpandMode.COLLAPSE;
        }
        break;
      case EmailActionType.composeFromMailtoUri:
        final emailAddressOfTo = arguments.listEmailAddress ?? [];
        final emailAddressOfCc = arguments.cc ?? [];
        final emailAddressOfBc = arguments.bcc ?? [];

        if (emailAddressOfTo.isNotEmpty) {
          listToEmailAddress.addAll(emailAddressOfTo);
          isInitialRecipient.value = true;
          toAddressExpandMode.value = ExpandMode.COLLAPSE;
        }

        if (emailAddressOfCc.isNotEmpty) {
          listCcEmailAddress = emailAddressOfCc;
          ccRecipientState.value = PrefixRecipientState.enabled;
          ccAddressExpandMode.value = ExpandMode.COLLAPSE;
        }

        if (emailAddressOfBc.isNotEmpty) {
          listBccEmailAddress = emailAddressOfBc;
          bccRecipientState.value = PrefixRecipientState.enabled;
          bccAddressExpandMode.value = ExpandMode.COLLAPSE;
        }
        break;
      case EmailActionType.reply:
      case EmailActionType.replyToList:
      case EmailActionType.replyAll:
        initEmailAddress(
          presentationEmail: arguments.presentationEmail!,
          actionType: currentEmailActionType!,
          listPost: arguments.listPost,
        );
        break;
      default:
        break;
    }

    updateStatusEmailSendButton();
  }
}