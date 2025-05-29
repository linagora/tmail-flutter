
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';

extension ToggleExpandFoldersExtension on MailboxController {
  void toggleExpandFolders() {
    final currentExpand = foldersExpandMode.value;
    if (currentExpand == ExpandMode.COLLAPSE) {
      foldersExpandMode.value = ExpandMode.EXPAND;
    } else {
      foldersExpandMode.value = ExpandMode.COLLAPSE;
    }
  }
}