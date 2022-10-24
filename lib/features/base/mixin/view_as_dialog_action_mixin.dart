
import 'package:flutter/material.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_bindings.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/destination_picker_view.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin ViewAsDialogActionMixin {

  void showDialogDestinationPicker({
    required BuildContext context,
    required DestinationPickerArguments arguments,
    required Function(PresentationMailbox) onSelectedMailbox
  }) {
    DestinationPickerBindings().dependencies();

    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) {
          return DestinationPickerView.fromArguments(
              arguments,
              onDismissCallback: () {
                DestinationPickerBindings().dispose();
                popBack();
              },
              onSelectedMailboxCallback: (destinationMailbox) {
                DestinationPickerBindings().dispose();
                popBack();

                if (destinationMailbox is PresentationMailbox) {
                  onSelectedMailbox.call(destinationMailbox);
                }
              });
        });
  }
}