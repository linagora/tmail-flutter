
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/email_address_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_create_new_rule_filter.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension HandleEditRecipientExtension on ComposerController {
  void onEditRecipient(
    BuildContext context,
    PrefixEmailAddress prefix,
    EmailAddress emailAddress,
    EmailAddressActionType emailAddressActionType,
  ) {
    _handleEmailAddressActionTypeClick(
      context,
      emailAddressActionType,
      prefix,
      emailAddress,
    );
  }

  void _handleEmailAddressActionTypeClick(
    BuildContext context,
    EmailAddressActionType actionType,
    PrefixEmailAddress prefix,
    EmailAddress emailAddress,
  ) {
    switch (actionType) {
      case EmailAddressActionType.copy:
        _copyEmailAddress(context, emailAddress);
        break;
      case EmailAddressActionType.edit:
        _modifyEmailAddress(prefix, emailAddress);
        break;
      case EmailAddressActionType.createRule:
        _createRuleFromEmailAddress(emailAddress);
        break;
    }
  }

  void _copyEmailAddress(BuildContext context, EmailAddress emailAddress) {
    Clipboard.setData(ClipboardData(text: emailAddress.emailAddress));
    appToast.showToastSuccessMessage(
      context,
      AppLocalizations.of(context).email_address_copied_to_clipboard,
    );
  }

  void _modifyEmailAddress(
    PrefixEmailAddress prefix,
    EmailAddress emailAddress,
  ) {
    switch(prefix) {
      case PrefixEmailAddress.to:
        listToEmailAddress.remove(emailAddress);
        toRecipientState.refresh();
        _setTextAndFocus(
          controller: toEmailAddressController,
          focusNode: toAddressFocusNode,
          text: emailAddress.emailAddress,
        );
        break;
      case PrefixEmailAddress.cc:
        listCcEmailAddress.remove(emailAddress);
        ccRecipientState.refresh();
        _setTextAndFocus(
          controller: ccEmailAddressController,
          focusNode: ccAddressFocusNode,
          text: emailAddress.emailAddress,
        );
        break;
      case PrefixEmailAddress.bcc:
        listBccEmailAddress.remove(emailAddress);
        bccRecipientState.refresh();
        _setTextAndFocus(
          controller: bccEmailAddressController,
          focusNode: bccAddressFocusNode,
          text: emailAddress.emailAddress,
        );
        break;
      case PrefixEmailAddress.replyTo:
        listReplyToEmailAddress.remove(emailAddress);
        replyToRecipientState.refresh();
        _setTextAndFocus(
          controller: replyToEmailAddressController,
          focusNode: replyToAddressFocusNode,
          text: emailAddress.emailAddress,
        );
        break;
      default:
        break;
    }
  }

  void _setTextAndFocus({
    required TextEditingController controller,
    required FocusNode? focusNode,
    required String text,
  }) {
    controller.text = text;
    controller.selection = const TextSelection.collapsed(offset: -1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode?.requestFocus();
      Future.delayed(const Duration(milliseconds: 150), () {
        controller.selection = TextSelection.collapsed(offset: text.length);
      },);
    });
  }

  Future<void> _createRuleFromEmailAddress(EmailAddress emailAddress) async {
    await mailboxDashBoardController.openCreateEmailRuleView(
      emailAddress: emailAddress,
    );
  }

  void onClearFocusAction() {
    if (PlatformInfo.isMobile) {
      htmlEditorApi?.unfocus();
    }
  }
}