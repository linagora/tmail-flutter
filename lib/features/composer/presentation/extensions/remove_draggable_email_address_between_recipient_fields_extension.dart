
import 'package:model/email/prefix_email_address.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draggable_email_address.dart';

extension RemoveDraggableEmailAddressBetweenRecipientFieldsExtension on ComposerController {
  void removeDraggableEmailAddress(DraggableEmailAddress draggableEmailAddress) {
    if (composerId == null || composerId == draggableEmailAddress.composerId) {
      removeDraggableEmailAddressByComposerController(
        controller: this,
        draggableEmailAddress: draggableEmailAddress,
      );
    } else if (draggableEmailAddress.composerId != null) {
      final composerManager = mailboxDashBoardController.composerManager;
      if (!composerManager.composers.containsKey(composerId)) return;

      final draggableComposerController = composerManager
        .getComposerView(draggableEmailAddress.composerId!)
        .controller;

      removeDraggableEmailAddressByComposerController(
        controller: draggableComposerController,
        draggableEmailAddress: draggableEmailAddress,
      );
    }
  }

  void removeDraggableEmailAddressByComposerController({
    required ComposerController controller,
    required DraggableEmailAddress draggableEmailAddress,
  }) {
    switch(draggableEmailAddress.prefix) {
      case PrefixEmailAddress.to:
        controller.listToEmailAddress.remove(draggableEmailAddress.emailAddress);
        controller.toAddressExpandMode.value = ExpandMode.EXPAND;
        break;
      case PrefixEmailAddress.cc:
        controller.listCcEmailAddress.remove(draggableEmailAddress.emailAddress);
        controller.ccAddressExpandMode.value = ExpandMode.EXPAND;
        break;
      case PrefixEmailAddress.bcc:
        controller.listBccEmailAddress.remove(draggableEmailAddress.emailAddress);
        controller.bccAddressExpandMode.value = ExpandMode.EXPAND;
        break;
      case PrefixEmailAddress.replyTo:
        controller.listReplyToEmailAddress.remove(draggableEmailAddress.emailAddress);
        controller.replyToAddressExpandMode.value = ExpandMode.EXPAND;
        break;
      default:
        break;
    }
    controller.isInitialRecipient.value = true;
    controller.isInitialRecipient.refresh();
    controller.updateStatusEmailSendButton();
  }
}