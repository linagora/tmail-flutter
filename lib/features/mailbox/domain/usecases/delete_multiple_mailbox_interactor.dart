import 'dart:collection';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';

class DeleteMultipleMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  DeleteMultipleMailboxInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    List<MailboxId> selectedMailboxIds,
  ) async* {
    try {
      yield Right<Failure, Success>(LoadingDeleteMultipleMailboxAll());

      final currentMailboxState = await _mailboxRepository.getMailboxState(session, accountId);

      final mailboxResponses = await _mailboxRepository.getAllMailbox(session, accountId).toList();

      final Set<MailboxId> seenIds = {};
      final List<PresentationMailbox> allMailboxes = [];
      for (final response in mailboxResponses) {
        for (final mailbox in response.mailboxes) {
          final presentation = mailbox.toPresentationMailbox();
          if (seenIds.add(presentation.id)) {
            allMailboxes.add(presentation);
          }
        }
      }

      final deleteMap = _buildDeleteMap(selectedMailboxIds, allMailboxes);
      final mapMailboxIdToDelete = deleteMap.value1;
      final listMailboxIdToDelete = deleteMap.value2;

      final listResult = await Future.wait(
        mapMailboxIdToDelete.keys.map((mailboxId) {
          return _mailboxRepository.deleteMultipleMailbox(
            session,
            accountId,
            mapMailboxIdToDelete[mailboxId]!,
          );
        }),
      );

      final allSuccess = listResult.every((result) => result.isEmpty);
      final allFailed = listResult.every((result) => result.isNotEmpty);

      if (allSuccess) {
        yield Right<Failure, Success>(DeleteMultipleMailboxAllSuccess(
          listMailboxIdToDelete,
          currentMailboxState: currentMailboxState,
        ));
      } else if (allFailed) {
        yield Left<Failure, Success>(DeleteMultipleMailboxAllFailure());
      } else {
        yield Right<Failure, Success>(DeleteMultipleMailboxHasSomeSuccess(
          listMailboxIdToDelete,
          currentMailboxState: currentMailboxState,
        ));
      }
    } catch (e) {
      logWarning('DeleteMultipleMailboxInteractor::execute(): exception: $e');
      yield Left<Failure, Success>(DeleteMultipleMailboxFailure(e));
    }
  }

  /// Builds the map of [MailboxId] → ordered delete list for each selected root,
  /// plus a flat list of all IDs to delete.
  ///
  /// Uses [allMailboxes] (subscribed and unsubscribed) so hidden subfolders are
  /// automatically included — no separate unsubscribed-tree pass is needed.
  Tuple2<Map<MailboxId, List<MailboxId>>, List<MailboxId>> _buildDeleteMap(
    List<MailboxId> selectedMailboxIds,
    List<PresentationMailbox> allMailboxes,
  ) {
    final parentToChildren = _buildParentToChildrenMap(allMailboxes);
    final Map<MailboxId, List<MailboxId>> mapDescendantIds = {};
    final Set<MailboxId> processedIds = {};

    for (final mailboxId in selectedMailboxIds) {
      if (processedIds.contains(mailboxId)) continue;

      // Collect all descendants (pre-order DFS), then reverse so deepest children
      // come first — the server requires children to be deleted before parents.
      final descendants = _collectDescendantsPreOrder(mailboxId, parentToChildren);
      final deleteOrder = descendants.reversed.toList();

      mapDescendantIds[mailboxId] = deleteOrder;
      processedIds.addAll(deleteOrder);
    }

    final allMailboxIds = mapDescendantIds.values.expand((ids) => ids).toList();
    return Tuple2(mapDescendantIds, allMailboxIds);
  }

  Map<MailboxId, List<MailboxId>> _buildParentToChildrenMap(
    List<PresentationMailbox> mailboxes,
  ) {
    final Map<MailboxId, List<MailboxId>> parentToChildren = HashMap();
    for (final mailbox in mailboxes) {
      final parentId = mailbox.parentId;
      if (parentId != null) {
        parentToChildren.putIfAbsent(parentId, () => []).add(mailbox.id);
      }
    }
    return parentToChildren;
  }

  /// Pre-order DFS: root first, then children. Caller should reverse the result
  /// to get deepest-first deletion order.
  List<MailboxId> _collectDescendantsPreOrder(
    MailboxId rootId,
    Map<MailboxId, List<MailboxId>> parentToChildren,
  ) {
    final result = <MailboxId>[];
    final stack = ListQueue<MailboxId>()..addLast(rootId);

    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      result.add(current);
      final children = parentToChildren[current];
      if (children != null) {
        // Push in reverse so the first child is processed first (stack is LIFO).
        for (final child in children.reversed) {
          stack.addLast(child);
        }
      }
    }
    return result;
  }
}
