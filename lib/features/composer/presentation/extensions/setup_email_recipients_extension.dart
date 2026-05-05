
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';

extension SetupEmailRecipientsExtension on ComposerController {

  void setupEmailRecipients(ComposerArguments arguments) {
    if (_isDraftLikeRecipientsAction) {
      initEmailAddress(
        presentationEmail: arguments.presentationEmail!,
        actionType: currentEmailActionType!,
      );
    } else if (currentEmailActionType == EmailActionType.editSendingEmail) {
      initEmailAddress(
        presentationEmail: arguments.sendingEmail!.presentationEmail,
        actionType: currentEmailActionType!,
      );
    } else if (_isDirectToAddressAction) {
      _setupToAddressOnly(arguments);
    } else if (_isFullAddressAction) {
      _setupFullAddressRecipients(arguments);
    } else if (_isReplyLikeRecipientsAction) {
      initEmailAddress(
        presentationEmail: arguments.presentationEmail!,
        actionType: currentEmailActionType!,
        listPost: arguments.listPost,
      );
    }

    updateStatusEmailSendButton();
  }

  bool get _isDraftLikeRecipientsAction => const {
    EmailActionType.editAsNewEmail,
    EmailActionType.editDraft,
    EmailActionType.reopenComposerBrowser,
  }.contains(currentEmailActionType);

  bool get _isDirectToAddressAction => const {
    EmailActionType.composeFromEmailAddress,
    EmailActionType.composeFromUnsubscribeMailtoLink,
  }.contains(currentEmailActionType);

  bool get _isFullAddressAction => const {
    EmailActionType.composeFromMailtoUri,
  }.contains(currentEmailActionType);

  bool get _isReplyLikeRecipientsAction => const {
    EmailActionType.reply,
    EmailActionType.replyToList,
    EmailActionType.replyAll,
  }.contains(currentEmailActionType);

  void _setupToAddressOnly(ComposerArguments arguments) {
    final emailAddressOfTo = arguments.listEmailAddress ?? [];
    if (emailAddressOfTo.isNotEmpty) {
      listToEmailAddress.addAll(emailAddressOfTo);
      isInitialRecipient.value = true;
    }
  }

  void _setupFullAddressRecipients(ComposerArguments arguments) {
    final emailAddressOfTo = arguments.listEmailAddress ?? [];
    final emailAddressOfCc = arguments.cc ?? [];
    final emailAddressOfBcc = arguments.bcc ?? [];

    if (emailAddressOfTo.isNotEmpty) {
      listToEmailAddress.addAll(emailAddressOfTo);
      isInitialRecipient.value = true;
    }
    if (emailAddressOfCc.isNotEmpty) {
      listCcEmailAddress = List.from(emailAddressOfCc);
      ccRecipientState.value = PrefixRecipientState.enabled;
    }
    if (emailAddressOfBcc.isNotEmpty) {
      listBccEmailAddress = List.from(emailAddressOfBcc);
      bccRecipientState.value = PrefixRecipientState.enabled;
    }
  }
}
