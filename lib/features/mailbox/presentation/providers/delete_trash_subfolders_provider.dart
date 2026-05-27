import 'package:core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';

enum DeleteTrashSubfoldersStatus { idle, loading, success, partialSuccess, failed }

class DeleteTrashSubfoldersNotifier extends StateNotifier<DeleteTrashSubfoldersStatus> {
  final DeleteMultipleMailboxInteractor _interactor;

  DeleteTrashSubfoldersNotifier(this._interactor) : super(DeleteTrashSubfoldersStatus.idle);

  bool get isLoading => state == DeleteTrashSubfoldersStatus.loading;

  Future<void> execute(
    MailboxId trashMailboxId,
    Map<MailboxId, PresentationMailbox> mailboxMap,
    Session session,
    AccountId accountId,
  ) async {
    if (isLoading) return;

    final childIds = mailboxMap.values
        .where((m) => m.parentId == trashMailboxId)
        .map((m) => m.id)
        .toList();

    if (childIds.isEmpty) {
      state = DeleteTrashSubfoldersStatus.idle;
      return;
    }

    state = DeleteTrashSubfoldersStatus.loading;

    try {
      final result = await _interactor
          .execute(session, accountId, childIds)
          .last;

      state = result.fold(
        (_) => DeleteTrashSubfoldersStatus.failed,
        (success) {
          if (success is DeleteMultipleMailboxAllSuccess) {
            return DeleteTrashSubfoldersStatus.success;
          } else if (success is DeleteMultipleMailboxHasSomeSuccess) {
            return DeleteTrashSubfoldersStatus.partialSuccess;
          }
          return DeleteTrashSubfoldersStatus.failed;
        },
      );
    } catch (e) {
      logError('DeleteTrashSubfoldersNotifier::execute: $e');
      state = DeleteTrashSubfoldersStatus.failed;
    }
  }
}

final deleteTrashSubfoldersProvider =
    StateNotifierProvider<DeleteTrashSubfoldersNotifier, DeleteTrashSubfoldersStatus>(
  (ref) => DeleteTrashSubfoldersNotifier(Get.find<DeleteMultipleMailboxInteractor>()),
);
