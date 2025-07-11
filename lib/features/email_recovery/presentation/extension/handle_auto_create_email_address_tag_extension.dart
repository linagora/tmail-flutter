
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/base/model/filter_filter.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/email_recovery_controller.dart';

extension AutoCreateEmailAddressTagExtension on EmailRecoveryController {
  void autoCreateTagForFilterField(FilterField field) {
    final currentText = _getCurrentTextInInputField(field);
    if (currentText.isEmpty) return;

    switch (field) {
      case FilterField.recipients:
        if (!listRecipients.isDuplicatedEmail(currentText)) {
          _synchronizeListEmailAddressInInputField(
            inputEmail: currentText,
            listEmailAddress: listRecipients,
            tagEditorFieldKey: recipientsFieldKey,
          );
        }
        break;
      case FilterField.sender:
        if (!listSenders.isDuplicatedEmail(currentText)) {
          _synchronizeListEmailAddressInInputField(
            inputEmail: currentText,
            listEmailAddress: listSenders,
            tagEditorFieldKey: senderFieldKey,
          );
        }
        break;
      default:
    }
  }

  void _synchronizeListEmailAddressInInputField({
    required String inputEmail,
    required GlobalKey<TagsEditorState> tagEditorFieldKey,
    required List<EmailAddress> listEmailAddress,
  }) {
    final emailAddress = EmailAddress(null, inputEmail);
    listEmailAddress.add(emailAddress);
    tagEditorFieldKey.currentState?.resetTextField();
    Future.delayed(
      const Duration(milliseconds: 300),
      tagEditorFieldKey.currentState?.closeSuggestionBox,
    );
  }

  String _getCurrentTextInInputField(FilterField field) {
    switch (field) {
      case FilterField.recipients:
        return recipientsFieldInputController.text;
      case FilterField.sender:
        return senderFieldInputController.text;
      default:
        return '';
    }
  }
}