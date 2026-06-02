import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/providers/delete_trash_subfolders_provider.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';

extension ExecuteDeleteTrashSubfoldersExtension on MailboxDashBoardController {
  void emptyTrashWithSubfolders(
    BuildContext context,
    MailboxId trashMailboxId,
    WidgetRef ref,
  ) {
    deleteSelectionEmailsPermanently(
      context,
      DeleteActionType.all,
      onConfirm: () => executeDeleteTrashSubfolders(trashMailboxId, ref),
    );
  }

  void executeDeleteTrashSubfolders(MailboxId trashMailboxId, WidgetRef ref) {
    final session = sessionCurrent;
    final currentAccountId = accountId.value;
    if (session == null || currentAccountId == null) return;

    final childIds = mapMailboxById.values
        .where((m) => m.parentId == trashMailboxId)
        .map((m) => m.id)
        .toList();

    ref
        .read(deleteTrashSubfoldersProvider.notifier)
        .execute(session, currentAccountId, childIds);
  }
}
