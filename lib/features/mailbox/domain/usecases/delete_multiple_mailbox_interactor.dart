import 'dart:collection';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_utils.dart';

class DeleteMultipleMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  DeleteMultipleMailboxInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(
      Session session,
      AccountId accountId,
      List<PresentationMailbox> listMailboxToDelete
  ) async* {
    try {
      yield Right<Failure, Success>(LoadingDeleteMultipleMailboxAll());

      final currentMailboxState = await _mailboxRepository.getMailboxState(session, accountId);

      final mailboxResponse = await _mailboxRepository.getAllMailbox(session, accountId).last;

      final listAllMailbox = mailboxResponse.mailboxes
        .map((mailbox) => mailbox.toPresentationMailbox())
        .toList();

      final mailboxTree = buildMailboxTree(listAllMailbox);
      final defaultMailboxTree = mailboxTree.value1;
      final personalMailboxTree = mailboxTree.value2;

      final mapDescendant = MailboxUtils.generateMapDescendantIdsAndMailboxIdList(
        listMailboxToDelete,
        defaultMailboxTree,
        personalMailboxTree
      );

      final mapMailboxIdToDelete = mapDescendant.value1;
      final listMailboxIdToDelete = mapDescendant.value2;

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

  Tuple2<MailboxTree, MailboxTree> buildMailboxTree(
    List<PresentationMailbox> mailboxList,
  ) {
    Map<MailboxId, MailboxNode> mailboxDictionary = HashMap();
    final defaultTree = MailboxTree(MailboxNode.root());
    final personalTree = MailboxTree(MailboxNode.root());
    final teamMailboxes = MailboxTree(MailboxNode.root());

    for (var mailbox in mailboxList) {
      mailboxDictionary[mailbox.id] = MailboxNode(mailbox);
    }

    for (var mailbox in mailboxList) {
      final parentId = mailbox.parentId;
      final parentNode = mailboxDictionary[parentId];
      final node = mailboxDictionary[mailbox.id];
      if (node != null) {
        if (parentNode != null) {
          parentNode.addChildNode(node);
        } else if (parentId == null) {
          MailboxTree tree;
          if (mailbox.hasRole()) {
            tree = defaultTree;
          } else if (mailbox.isPersonal) {
            tree = personalTree;
          } else {
            tree = teamMailboxes;
          }

          tree.root.addChildNode(node);
        }
      }
    }

    return Tuple2(defaultTree, personalTree);
  }
}