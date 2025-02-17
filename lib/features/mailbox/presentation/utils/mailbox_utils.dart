import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:email_recovery/email_recovery/capability_deleted_messages_vault.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/list_mailbox_node_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class MailboxUtils {

  static Tuple2<Map<MailboxId, List<MailboxId>>, List<MailboxId>> generateMapDescendantIdsAndMailboxIdList(
      List<PresentationMailbox> selectedMailboxList,
      MailboxTree defaultMailboxTree,
      MailboxTree folderMailboxTree,
  ) {
    Map<MailboxId, List<MailboxId>> mapDescendantIds = {};
    List<MailboxId> allMailboxIds = [];

    for (var mailbox in selectedMailboxList) {
      final currentMailboxId = mailbox.id;

      if (allMailboxIds.contains(currentMailboxId)) {
        continue;
      } else {
        final matchedNode = defaultMailboxTree.findNode((node) => node.item.id == currentMailboxId)
            ?? folderMailboxTree.findNode((node) => node.item.id == currentMailboxId);

        if (matchedNode != null)  {
          final descendantIds = matchedNode.descendantsAsList().mailboxIds;
          final descendantIdsReversed = descendantIds.reversed.toList();

          mapDescendantIds[currentMailboxId] = descendantIdsReversed;
          allMailboxIds.addAll(descendantIdsReversed);
        }
      }
    }
    log('MailboxUtils::generateMapDescendantIdsAndMailboxIdList(): mapDescendantIds: $mapDescendantIds');
    return Tuple2(mapDescendantIds, allMailboxIds);
  }

  static EdgeInsets getPaddingListViewMailboxSearched(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsets.only(left: 16, right: 16, bottom: 16);
    } else {
      if (responsiveUtils.isScreenWithShortestSide(context)) {
        return const EdgeInsets.all(16);
      } else {
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
      }
    }
  }

  static bool isDeletedMessageVaultSupported(Session? session, AccountId? accountId) {
    if (session == null || accountId == null) {
      return false;
    }
    return capabilityDeletedMessagesVault.isSupported(session, accountId);
  }
}