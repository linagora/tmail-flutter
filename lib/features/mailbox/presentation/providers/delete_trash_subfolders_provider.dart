import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

part 'delete_trash_subfolders_provider.g.dart';

sealed class DeleteTrashSubfoldersState {
  const DeleteTrashSubfoldersState();
}

class DeleteTrashSubfoldersIdle extends DeleteTrashSubfoldersState {
  const DeleteTrashSubfoldersIdle();
}

class DeleteTrashSubfoldersLoading extends DeleteTrashSubfoldersState {
  const DeleteTrashSubfoldersLoading();
}

class DeleteTrashSubfoldersSuccess extends DeleteTrashSubfoldersState {
  const DeleteTrashSubfoldersSuccess();
}

class DeleteTrashSubfoldersPartialSuccess extends DeleteTrashSubfoldersState {
  const DeleteTrashSubfoldersPartialSuccess();
}

class DeleteTrashSubfoldersFailed extends DeleteTrashSubfoldersState {
  final Object? exception;

  const DeleteTrashSubfoldersFailed({this.exception});
}

@riverpod
class DeleteTrashSubfoldersNotifier extends _$DeleteTrashSubfoldersNotifier {
  @override
  DeleteTrashSubfoldersState build() {
    return const DeleteTrashSubfoldersIdle();
  }

  bool get mounted => ref.mounted;
  bool get isLoading => state is DeleteTrashSubfoldersLoading;

  Future<void> execute(
    Session session,
    AccountId accountId,
    List<MailboxId> childIds,
  ) async {
    if (isLoading) return;
    if (childIds.isEmpty) return;

    state = const DeleteTrashSubfoldersLoading();
    try {
      final result = await getBinding<DeleteMultipleMailboxInteractor>()
          ?.execute(session, accountId, childIds)
          .last;
      if (!mounted) return;
      if (result != null) {
        state = result.fold(_toFailed, _toSuccess);
      } else {
        state = const DeleteTrashSubfoldersFailed();
      }
    } catch (e) {
      logError('DeleteTrashSubfoldersNotifier::execute: $e');
      if (!mounted) return;
      state = DeleteTrashSubfoldersFailed(exception: e);
    }
  }

  DeleteTrashSubfoldersState _toSuccess(Success success) {
    if (success is DeleteMultipleMailboxAllSuccess) {
      return const DeleteTrashSubfoldersSuccess();
    }
    if (success is DeleteMultipleMailboxHasSomeSuccess) {
      return const DeleteTrashSubfoldersPartialSuccess();
    }
    return const DeleteTrashSubfoldersFailed();
  }

  DeleteTrashSubfoldersState _toFailed(Failure failure) {
    final exception =
        failure is FeatureFailure ? failure.exception : null;
    return DeleteTrashSubfoldersFailed(exception: exception);
  }
}
