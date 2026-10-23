import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/get_trash_mailbox_id_and_path_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleActionTypeForEmailSelection on MailboxDashBoardController {
  void moveEmailsToFolder(
    List<PresentationEmail> emails,
    EmailActionType actionType,
    {MailboxId? selectedMailboxId, String? destinationFolderPath}
  ) {
    final isInSearchOrVirtualFolder =
        searchController.isSearchEmailRunning ||
        selectedMailbox.value?.isVirtualFolder == true;

    // In search / virtual-folder mode the selected mailbox does not represent
    // the emails' actual home namespace, so trash must be resolved per email.
    if (actionType == EmailActionType.moveToTrash && isInSearchOrVirtualFolder) {
      _moveEmailsToTrashAcrossNamespaces(emails);
      return;
    }

    MailboxId? destinationMailboxId;

    if (actionType == EmailActionType.moveToMailbox) {
      destinationMailboxId = selectedMailboxId;
    } else if (actionType == EmailActionType.moveToSpam) {
      destinationMailboxId = spamMailboxId;
    } else if (actionType == EmailActionType.moveToTrash) {
      if (selectedMailbox.value?.isChildOfTeamMailboxes == true) {
        final (:trashId, :trashPath) =
            getTrashMailboxIdAndPath(selectedMailbox.value!);
        destinationMailboxId = trashId;
        destinationFolderPath = trashPath;
      } else {
        destinationMailboxId =
            getMailboxIdByRole(PresentationMailbox.roleTrash);
      }
    } else if (actionType == EmailActionType.archiveMessage) {
      destinationMailboxId = getMailboxIdByRole(PresentationMailbox.roleArchive);
    }

    if (activeAccountId == null ||
        destinationMailboxId == null ||
        sessionCurrent == null) {
      consumeState(
        Stream.value(Left(MoveMultipleEmailToMailboxFailure(
          actionType,
          MoveAction.moving,
          ParametersIsNullException(),
        ))),
      );
      return;
    }

    final mapEmailIdsByMailboxId = <MailboxId, List<EmailId>>{};

    if (isInSearchOrVirtualFolder) {
      for (final email in emails) {
        final mailboxId = email.firstMailboxIdAvailable;
        final emailId = email.id;

        if (mailboxId == null ||
            mailboxId == destinationMailboxId ||
            emailId == null) {
          continue;
        }

        mapEmailIdsByMailboxId.putIfAbsent(mailboxId, () => []).add(emailId);
      }
    } else {
      final selectedId = selectedMailbox.value?.id;
      if (selectedId != null) {
        mapEmailIdsByMailboxId[selectedId] = emails.listEmailIds;
      }
    }

    log('$runtimeType::moveEmailsToFolder: MapEmailIdsByMailboxId = $mapEmailIdsByMailboxId');
    if (mapEmailIdsByMailboxId.isEmpty) {
      consumeState(
        Stream.value(Left(MoveMultipleEmailToMailboxFailure(
          actionType,
          MoveAction.moving,
          ParametersIsNullException(),
        ))),
      );
      return;
    }

    final emailIdsWithReadStatus = Map.fromEntries(
      emails
          .where((email) => email.id != null)
          .map((email) => MapEntry(email.id!, email.hasRead)),
    );

    final destinationPath = destinationFolderPath ??
        (currentContext != null
            ? destinationFolderPath ?? mapMailboxById[destinationMailboxId]?.getDisplayName(currentContext!)
            : null);

    moveSelectedEmailMultipleToMailboxAction(
      sessionCurrent!,
      activeAccountId!,
      MoveToMailboxRequest(
        mapEmailIdsByMailboxId,
        destinationMailboxId,
        MoveAction.moving,
        actionType,
        destinationPath: destinationPath,
      ),
      emailIdsWithReadStatus,
    );
  }

  void _moveEmailsToTrashAcrossNamespaces(List<PresentationEmail> emails) {
    if (activeAccountId == null || sessionCurrent == null) {
      consumeState(Stream.value(Left(MoveMultipleEmailToMailboxFailure(
        EmailActionType.moveToTrash,
        MoveAction.moving,
        ParametersIsNullException(),
      ))));
      return;
    }

    // Group emails by resolved trash destination: trashId → (path, sourceId → [emailIds])
    final groups = <MailboxId,
        ({String? trashPath, Map<MailboxId, List<EmailId>> sourceToEmails})>{};

    for (final email in emails) {
      final sourceMailboxId = email.firstMailboxIdAvailable;
      final emailId = email.id;
      if (sourceMailboxId == null || emailId == null) continue;

      final sourceMailbox = mapMailboxById[sourceMailboxId];
      if (sourceMailbox == null) continue;

      final (:trashId, :trashPath) = getTrashMailboxIdAndPath(sourceMailbox);
      if (trashId == null || sourceMailboxId == trashId) continue;

      groups
          .putIfAbsent(trashId, () => (trashPath: trashPath, sourceToEmails: {}))
          .sourceToEmails
          .putIfAbsent(sourceMailboxId, () => [])
          .add(emailId);
    }

    if (groups.isEmpty) {
      consumeState(Stream.value(Left(MoveMultipleEmailToMailboxFailure(
        EmailActionType.moveToTrash,
        MoveAction.moving,
        ParametersIsNullException(),
      ))));
      return;
    }

    final emailIdsWithReadStatus = Map.fromEntries(
      emails
          .where((e) => e.id != null)
          .map((e) => MapEntry(e.id!, e.hasRead)),
    );

    for (final entry in groups.entries) {
      final trashId = entry.key;
      final resolvedPath = entry.value.trashPath ??
          (currentContext != null
              ? mapMailboxById[trashId]?.getDisplayName(currentContext!)
              : null);

      log('$runtimeType::_moveEmailsToTrashAcrossNamespaces: trashId=$trashId sources=${entry.value.sourceToEmails.keys}');
      moveSelectedEmailMultipleToMailboxAction(
        sessionCurrent!,
        activeAccountId!,
        MoveToMailboxRequest(
          entry.value.sourceToEmails,
          trashId,
          MoveAction.moving,
          EmailActionType.moveToTrash,
          destinationPath: resolvedPath,
        ),
        emailIdsWithReadStatus,
      );
    }
  }
}
