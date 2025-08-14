import 'package:core/utils/app_logger.dart';
import 'package:core/utils/string_convert.dart';
import 'package:flutter/cupertino.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/list_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/list_named_address_extension.dart';

extension AutoCreateTagForRecipientsExtension on ComposerController {

  void autoCreateEmailTag() {
    final emailInputs = {
      PrefixEmailAddress.to: toEmailAddressController.text,
      PrefixEmailAddress.cc: ccEmailAddressController.text,
      PrefixEmailAddress.bcc: bccEmailAddressController.text,
      PrefixEmailAddress.replyTo: replyToEmailAddressController.text,
    };

    emailInputs.forEach((prefix, input) {
      if (input.trim().isNotEmpty) {
        autoCreateEmailTagForType(prefix, input);
      }
    });
  }

  Map<PrefixEmailAddress, List<EmailAddress>> get _emailLists => {
    PrefixEmailAddress.to: listToEmailAddress,
    PrefixEmailAddress.cc: listCcEmailAddress,
    PrefixEmailAddress.bcc: listBccEmailAddress,
    PrefixEmailAddress.replyTo: listReplyToEmailAddress,
  };

  Map<PrefixEmailAddress, GlobalKey<TagsEditorState>> get _emailEditors => {
    PrefixEmailAddress.to: keyToEmailTagEditor,
    PrefixEmailAddress.cc: keyCcEmailTagEditor,
    PrefixEmailAddress.bcc: keyBccEmailTagEditor,
    PrefixEmailAddress.replyTo: keyReplyToEmailTagEditor,
  };

  void autoCreateEmailTagForType(PrefixEmailAddress type, String input) {
    final namedAddresses = StringConvert.extractNamedAddresses(input);
    List<EmailAddress> newListEmailAddress = [];
    final existingEmailList = _emailLists[type]!;

    if (namedAddresses.isNotEmpty) {
      final emailAddressListFromNamed = namedAddresses
          .toFilteredEmailAddressList(existingEmailList);
      log('$runtimeType::autoCreateEmailTagForType: Create email tag from named address list with length ${emailAddressListFromNamed.length}');
      newListEmailAddress = emailAddressListFromNamed;
    }

    if (newListEmailAddress.isEmpty) {
      List<String> addresses = StringConvert.extractEmailAddress(input);
      final emailAddressListFromAddress =
          addresses.toFilteredEmailAddressList(existingEmailList);
      log('$runtimeType::autoCreateEmailTagForType: Create email tag from address list with length ${emailAddressListFromAddress.length}');
      newListEmailAddress = emailAddressListFromAddress;
    }

    if (newListEmailAddress.isEmpty) return;

    existingEmailList.addAll(newListEmailAddress);

    if (!isInitialRecipient.value) {
      isInitialRecipient.value = true;
      isInitialRecipient.refresh();
    }

    updateStatusEmailSendButton();

    final keyEditor = _emailEditors[type]!;
    keyEditor.currentState?.resetTextField();
    Future.delayed(
      const Duration(milliseconds: 300),
      keyEditor.currentState?.closeSuggestionBox,
    );
  }
}