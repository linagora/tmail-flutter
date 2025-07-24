
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/context_item_email_address_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/email_address_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_create_new_rule_filter.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleEditRecipientExtension on ComposerController {
  void onEditRecipient(
    BuildContext context,
    PrefixEmailAddress prefix,
    EmailAddress emailAddress,
    EmailAddressActionType emailAddressActionType,
  ) {
    if (PlatformInfo.isMobile) {
      clearFocus(context);

      final contextMenuActions = EmailAddressActionType.values
        .map((action) => ContextItemEmailAddressActionType(
          action,
          AppLocalizations.of(context),
          imagePaths
        ))
        .toList();

      openBottomSheetContextMenuAction(
        context: context,
        itemActions: contextMenuActions,
        onContextMenuActionClick: (menuAction) {
          popBack();
          _handleEmailAddressActionTypeClick(
            context,
            menuAction.action,
            prefix,
            emailAddress,
          );
        },
      );
    } else {
      _handleEmailAddressActionTypeClick(
        context,
        emailAddressActionType,
        prefix,
        emailAddress,
      );
    }
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
      case EmailAddressActionType.modify:
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
        toAddressExpandMode.value = ExpandMode.EXPAND;
        toAddressExpandMode.refresh();

        toEmailAddressController.text = emailAddress.emailAddress;
        toEmailAddressController.value = toEmailAddressController.value.copyWith(
          text: emailAddress.emailAddress,
          selection: TextSelection(
            baseOffset: emailAddress.emailAddress.length,
            extentOffset: emailAddress.emailAddress.length,
          ),
          composing: TextRange.empty,
        );
        toAddressFocusNode?.requestFocus();
        break;
      case PrefixEmailAddress.cc:
        listCcEmailAddress.remove(emailAddress);
        ccAddressExpandMode.value = ExpandMode.EXPAND;
        ccAddressExpandMode.refresh();

        ccEmailAddressController.text = emailAddress.emailAddress;
        ccEmailAddressController.value = ccEmailAddressController.value.copyWith(
          text: emailAddress.emailAddress,
          selection: TextSelection(
            baseOffset: emailAddress.emailAddress.length,
            extentOffset: emailAddress.emailAddress.length,
          ),
          composing: TextRange.empty,
        );
        ccAddressFocusNode?.requestFocus();
        break;
      case PrefixEmailAddress.bcc:
        listBccEmailAddress.remove(emailAddress);
        bccAddressExpandMode.value = ExpandMode.EXPAND;
        bccAddressExpandMode.refresh();

        bccEmailAddressController.text = emailAddress.emailAddress;
        bccEmailAddressController.value = bccEmailAddressController.value.copyWith(
          text: emailAddress.emailAddress,
          selection: TextSelection(
            baseOffset: emailAddress.emailAddress.length,
            extentOffset: emailAddress.emailAddress.length,
          ),
          composing: TextRange.empty,
        );
        bccAddressFocusNode?.requestFocus();
        break;
      case PrefixEmailAddress.replyTo:
        listReplyToEmailAddress.remove(emailAddress);
        replyToAddressExpandMode.value = ExpandMode.EXPAND;
        replyToAddressExpandMode.refresh();

        replyToEmailAddressController.text = emailAddress.emailAddress;
        replyToEmailAddressController.value = replyToEmailAddressController.value.copyWith(
          text: emailAddress.emailAddress,
          selection: TextSelection(
            baseOffset: emailAddress.emailAddress.length,
            extentOffset: emailAddress.emailAddress.length,
          ),
          composing: TextRange.empty,
        );
        replyToAddressFocusNode?.requestFocus();
        break;
      default:
        break;
    }
  }

  Future<void> _createRuleFromEmailAddress(EmailAddress emailAddress) async {
    await mailboxDashBoardController.openCreateEmailRuleView(
      emailAddress: emailAddress,
    );
  }
}