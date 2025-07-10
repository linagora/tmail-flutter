
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/base/model/filter_filter.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draggable_email_address.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/email_recovery_controller.dart';

extension HandleDragEmailTagBetweenFieldExtension on EmailRecoveryController {
  void removeDraggableEmailAddress(DraggableEmailAddress draggableEmailAddress) {
    switch(draggableEmailAddress.filterField) {
      case FilterField.recipients:
        listRecipients.remove(draggableEmailAddress.emailAddress);
        recipientsExpandMode.value = ExpandMode.EXPAND;
        recipientsExpandMode.refresh();
        break;
      case FilterField.sender:
        listSenders.remove(draggableEmailAddress.emailAddress);
        senderExpandMode.value = ExpandMode.EXPAND;
        senderExpandMode.refresh();
        break;
      default:
        break;
    }
  }
}