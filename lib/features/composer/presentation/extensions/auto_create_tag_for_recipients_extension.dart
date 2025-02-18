
import 'package:core/utils/mail/mail_address.dart';
import 'package:flutter/cupertino.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/mail_address_extension.dart';

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
    final emailAddressRecord = _generateEmailAddressFromString(input);

    final emailList = _emailLists[type]!;
    final keyEditor = _emailEditors[type]!;

    final emailSet = emailList.toSet();
    if (emailSet.any((email) => email.email == emailAddressRecord.$1)) return;

    emailSet.add(emailAddressRecord.$2);
    emailList
      ..clear()
      ..addAll(emailSet);

    isInitialRecipient.value = true;
    isInitialRecipient.refresh();
    updateStatusEmailSendButton();

    keyEditor.currentState?.resetTextField();
    Future.delayed(
      const Duration(milliseconds: 300),
      keyEditor.currentState?.closeSuggestionBox,
    );
  }

  (String email, EmailAddress emailAddress) _generateEmailAddressFromString(String input) {
    try {
      final mailAddress = MailAddress.validateAddress(input);
      return (mailAddress.asEncodedString(), mailAddress.asEmailAddress());
    } catch (e) {
      return (input, EmailAddress(null, input));
    }
  }
}