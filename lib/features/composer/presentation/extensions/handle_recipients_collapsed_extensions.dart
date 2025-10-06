import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

extension HandleRecipientsCollapsedExtensions on ComposerController {
  List<EmailAddress> get allListEmailAddress =>
      listToEmailAddress +
      listCcEmailAddress +
      listBccEmailAddress +
      listReplyToEmailAddress;

  List<EmailAddress> get listEmailAddressInvalid => allListEmailAddress
      .where(
        (emailAddress) => !EmailUtils.isEmailAddressValid(
          emailAddress.emailAddress,
        ),
      )
      .toList();

  bool get isRecipientsNotEmpty => listToEmailAddress.isNotEmpty ||
      listCcEmailAddress.isNotEmpty ||
      listBccEmailAddress.isNotEmpty ||
      listReplyToEmailAddress.isNotEmpty;

  void showFullRecipients() {
    recipientsCollapsedState.value = PrefixRecipientState.disabled;

    if (listToEmailAddress.isNotEmpty) {
      toRecipientState.value = PrefixRecipientState.enabled;
      toAddressExpandMode.value = ExpandMode.EXPAND;
    }

    if (listCcEmailAddress.isNotEmpty) {
      ccRecipientState.value = PrefixRecipientState.enabled;
      ccAddressExpandMode.value = ExpandMode.EXPAND;
    }

    if (listBccEmailAddress.isNotEmpty) {
      bccRecipientState.value = PrefixRecipientState.enabled;
      bccAddressExpandMode.value = ExpandMode.EXPAND;
    }

    if (listReplyToEmailAddress.isNotEmpty) {
      replyToRecipientState.value = PrefixRecipientState.enabled;
      replyToAddressExpandMode.value = ExpandMode.EXPAND;
    }

    updatePrefixRootState();
    requestFocusRecipientInput();
  }

  void updatePrefixRootState() {
    if (toRecipientState.value == PrefixRecipientState.enabled) {
      prefixRootState.value = PrefixEmailAddress.to;
      return;
    }

    if (ccRecipientState.value == PrefixRecipientState.enabled) {
      prefixRootState.value = PrefixEmailAddress.cc;
      return;
    }

    if (bccRecipientState.value == PrefixRecipientState.enabled) {
      prefixRootState.value = PrefixEmailAddress.bcc;
      return;
    }

    if (replyToRecipientState.value == PrefixRecipientState.enabled) {
      prefixRootState.value = PrefixEmailAddress.replyTo;
    }
  }

  void requestFocusRecipientInput() {
    if (listToEmailAddress.isNotEmpty) {
      toAddressFocusNode?.requestFocus();
      return;
    }

    if (listCcEmailAddress.isNotEmpty) {
      ccAddressFocusNode?.requestFocus();
      return;
    }

    if (listBccEmailAddress.isNotEmpty) {
      bccAddressFocusNode?.requestFocus();
      return;
    }

    if (listReplyToEmailAddress.isNotEmpty) {
      replyToAddressFocusNode?.requestFocus();
    }
  }

  void hideAllRecipients() {
    toRecipientState.value = PrefixRecipientState.disabled;
    ccRecipientState.value = PrefixRecipientState.disabled;
    bccRecipientState.value = PrefixRecipientState.disabled;
    replyToRecipientState.value = PrefixRecipientState.disabled;
    recipientsCollapsedState.value = PrefixRecipientState.enabled;
  }
}
