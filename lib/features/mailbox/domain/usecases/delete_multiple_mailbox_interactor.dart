import 'dart:collection';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/list_presentation_mailbox_extension.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/list_mailbox_node_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';

class DeleteMultipleMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  DeleteMultipleMailboxInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(
      Session session,
      AccountId accountId,
      Map<MailboxId, List<MailboxId>> mapMailboxIdToDelete,
      List<MailboxId> listMailboxIdToDelete
  ) async* {
    try {
      yield Right<Failure, Success>(LoadingDeleteMultipleMailboxAll());

      final currentMailboxState = await _mailboxRepository.getMailboxState(session, accountId);

      final mailboxResponses = await _mailboxRepository.getAllMailbox(session, accountId).toList();

      final listUnsubscribedMailbox = mailboxResponses.expand((mailboxResponse) {
        final presentationMailboxes = mailboxResponse.mailboxes
          ?.map((mailbox) => mailbox.toPresentationMailbox()).toList()
          ?? List<PresentationMailbox>.empty();
        return presentationMailboxes.listUnsubscribedMailboxes;
      }).toSet();

      if (listUnsubscribedMailbox.isNotEmpty) {
        final unsubscribedTree = buildUnsubscribedMailboxTree(listUnsubscribedMailbox);
        mapMailboxIdToDelete = addUnsubscribedSubFolderToDelete(
          mapMailboxIdToDelete,
          listMailboxIdToDelete,
          unsubscribedTree
        );
      }

      final listResult = await Future.wait(
          mapMailboxIdToDelete.keys.map((mailboxId) {
            final mailboxIdsToDelete = mapMailboxIdToDelete[mailboxId]!;
            return _mailboxRepository.deleteMultipleMailbox(
                session,
                accountId,
                mailboxIdsToDelete);
          })
      );

      final allSuccess = listResult.every((result) => result.isEmpty);
      final allFailed = listResult.every((result) => result.isNotEmpty);

      if (allSuccess) {
        yield Right<Failure, Success>(DeleteMultipleMailboxAllSuccess(
            listMailboxIdToDelete,
            currentMailboxState: currentMailboxState));
      } else if (allFailed) {
        yield Left<Failure, Success>(DeleteMultipleMailboxAllFailure());
      } else {
        yield Right<Failure, Success>(DeleteMultipleMailboxHasSomeSuccess(
            listMailboxIdToDelete,
            currentMailboxState: currentMailboxState));
      }
    } catch (e) {
      logError('DeleteMultipleMailboxInteractor::execute(): exception: $e');
      yield Left<Failure, Success>(DeleteMultipleMailboxFailure(e));
    }
  }

  MailboxTree buildUnsubscribedMailboxTree(
    Set<PresentationMailbox> listUnsubscribedMailbox,
  ) {
    Map<MailboxId, MailboxNode> mailboxDictionary = HashMap();
    final unsubscribedTree = MailboxTree(MailboxNode.root());

    for (var mailbox in listUnsubscribedMailbox) {
      if (mailbox.parentId != null) {
        mailboxDictionary[mailbox.id] = MailboxNode(mailbox);
      }
    }

    for (var mailbox in listUnsubscribedMailbox) {
      final parentId = mailbox.parentId;
      if (parentId != null) {
        final parentNode = mailboxDictionary[parentId];
        final node = mailboxDictionary[mailbox.id];
        if (node != null) {
          if (parentNode != null) {
            parentNode.addChildNode(node);
          } else {
            mailboxDictionary[parentId] = MailboxNode(PresentationMailbox(parentId));
            unsubscribedTree.root.addChildNode(mailboxDictionary[parentId]!);
            mailboxDictionary[parentId]!.addChildNode(node);
          }
        }
      }
    }

    return unsubscribedTree;
  }

  Map<MailboxId, List<MailboxId>> addUnsubscribedSubFolderToDelete(
    Map<MailboxId, List<MailboxId>> mapMailboxIdToDelete,
    List<MailboxId> listMailboxIdToDelete,
    MailboxTree unsubscribedTree,
  ) {
    List<MailboxId> visitedUnsubscribedMailboxIds = [];

    for (var mailboxId in listMailboxIdToDelete) {
      if (visitedUnsubscribedMailboxIds.contains(mailboxId)) {
        continue;
      } else {
        final matchedNode = unsubscribedTree.findNode((node) => node.item.id == mailboxId);

        if (matchedNode != null) {
          final descendantIds = matchedNode.descendantsAsList().mailboxIds;
          final descendantIdsReversed = descendantIds.reversed.toList();
          descendantIdsReversed.removeLast();

          if (mapMailboxIdToDelete.containsKey(mailboxId)) {
            mapMailboxIdToDelete[mailboxId]!.insertAll(mapMailboxIdToDelete[mailboxId]!.length - 1, descendantIdsReversed);
          } else {
            for (var listIdToDelete in mapMailboxIdToDelete.values) {
              if (listIdToDelete.contains(mailboxId)) {
                listIdToDelete.insertAll(listIdToDelete.indexOf(mailboxId), descendantIdsReversed);
              }
            }
          }
          visitedUnsubscribedMailboxIds.addAll(descendantIdsReversed);
        }
      }
    }

    return mapMailboxIdToDelete;
  }
}