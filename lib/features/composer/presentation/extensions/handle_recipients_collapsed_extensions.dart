import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleRecipientsCollapsedExtensions on ComposerController {
  List<EmailAddress> get allListEmailAddress =>
      listToEmailAddress +
      listCcEmailAddress +
      listBccEmailAddress +
      listReplyToEmailAddress;

  List<EmailAddress> get allListEmailAddressWithoutReplyTo =>
      listToEmailAddress +
      listCcEmailAddress +
      listBccEmailAddress;

  bool get existEmailAddressInvalid => allListEmailAddress
      .any(
        (emailAddress) => !EmailUtils.isValidEmail(
          emailAddress.emailAddress,
        ),
      );

  bool get isRecipientsWithoutReplyToNotEmpty => listToEmailAddress.isNotEmpty ||
      listCcEmailAddress.isNotEmpty ||
      listBccEmailAddress.isNotEmpty;

  bool get isRecipientsEmptyExceptReplyTo => listToEmailAddress.isEmpty &&
      listCcEmailAddress.isEmpty &&
      listBccEmailAddress.isEmpty &&
      listReplyToEmailAddress.isNotEmpty;

  void showFullRecipients() {
    recipientsCollapsedState.value = PrefixRecipientState.disabled;

    if (listToEmailAddress.isNotEmpty) {
      toRecipientState.value = PrefixRecipientState.enabled;
    }

    if (listCcEmailAddress.isNotEmpty) {
      ccRecipientState.value = PrefixRecipientState.enabled;
    }

    if (listBccEmailAddress.isNotEmpty) {
      bccRecipientState.value = PrefixRecipientState.enabled;
    }

    if (listReplyToEmailAddress.isNotEmpty) {
      replyToRecipientState.value = PrefixRecipientState.enabled;
    }

    if (currentContext != null &&
        responsiveUtils.isMobile(currentContext!) &&
        isAllRecipientInputEnabled) {
      fromRecipientState.value = PrefixRecipientState.enabled;
    }

    updatePrefixRootState();
    requestFocusRecipientInput();
  }

  bool get isAllRecipientInputEnabled =>
      toRecipientState.value == PrefixRecipientState.enabled &&
      ccRecipientState.value == PrefixRecipientState.enabled &&
      bccRecipientState.value == PrefixRecipientState.enabled &&
      replyToRecipientState.value == PrefixRecipientState.enabled;

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

  void triggerHideRecipientsFieldsWhenUnfocus() {
    if (isRecipientsEmptyExceptReplyTo) {
      hideAllRecipientsFieldsExceptTo();
    } else if (isRecipientsWithoutReplyToNotEmpty) {
      hideAllRecipientsFields();
    }
  }

  void hideAllRecipientsFields() {
    fromRecipientState.value = PrefixRecipientState.disabled;
    toRecipientState.value = PrefixRecipientState.disabled;
    ccRecipientState.value = PrefixRecipientState.disabled;
    bccRecipientState.value = PrefixRecipientState.disabled;
    replyToRecipientState.value = PrefixRecipientState.disabled;
    recipientsCollapsedState.value = PrefixRecipientState.enabled;
  }

  void hideAllRecipientsFieldsExceptTo() {
    toRecipientState.value = PrefixRecipientState.enabled;
    fromRecipientState.value = PrefixRecipientState.disabled;
    ccRecipientState.value = PrefixRecipientState.disabled;
    bccRecipientState.value = PrefixRecipientState.disabled;
    replyToRecipientState.value = PrefixRecipientState.disabled;
    recipientsCollapsedState.value = PrefixRecipientState.disabled;
  }

  void handleEnableRecipientsInputOnMobileAction(bool isEnabled) {
    PrefixRecipientState from;
    PrefixRecipientState to;
    PrefixRecipientState cc;
    PrefixRecipientState bcc;
    PrefixRecipientState replyTo;

    if (!isEnabled) {
      from = PrefixRecipientState.enabled;
      to = PrefixRecipientState.enabled;
      cc = PrefixRecipientState.enabled;
      bcc = PrefixRecipientState.enabled;
      replyTo = PrefixRecipientState.enabled;
    } else if (listCcEmailAddress.isNotEmpty) {
      from = PrefixRecipientState.disabled;
      to = PrefixRecipientState.disabled;
      cc = PrefixRecipientState.enabled;
      bcc = PrefixRecipientState.disabled;
      replyTo = PrefixRecipientState.disabled;
    } else if (listBccEmailAddress.isNotEmpty) {
      from = PrefixRecipientState.disabled;
      to = PrefixRecipientState.disabled;
      cc = PrefixRecipientState.disabled;
      bcc = PrefixRecipientState.enabled;
      replyTo = PrefixRecipientState.disabled;
    } else {
      from = PrefixRecipientState.disabled;
      to = PrefixRecipientState.enabled;
      cc = PrefixRecipientState.disabled;
      bcc = PrefixRecipientState.disabled;
      replyTo = PrefixRecipientState.disabled;
    }

    fromRecipientState.value = from;
    toRecipientState.value = to;
    ccRecipientState.value = cc;
    bccRecipientState.value = bcc;
    replyToRecipientState.value = replyTo;
  }
}
