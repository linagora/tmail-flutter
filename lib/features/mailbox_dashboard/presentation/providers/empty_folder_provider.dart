import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/clear_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/clear_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/empty_folder_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/empty_folder_request.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_trash_folder_interactor.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

export 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/empty_folder_state.dart';

part 'empty_folder_provider.g.dart';

typedef EmptyFolderProgressCallback =
    void Function(int countDeleted, int totalEmails);

// EmptyFolderRequest has no custom == so consecutive clicks on the same mailbox are never deduplicated.
@riverpod
Stream<EmptyFolderRequest> emptyFolderRequested(Ref ref, String tag) {
  final controller = getBinding<MailboxDashBoardController>();
  if (controller == null) return const Stream.empty();
  return controller.onEmptyFolderRequested
      .where((request) => request.tag == tag);
}

sealed class _ClearEmailResult {}

class _ClearEmailSuccess extends _ClearEmailResult {
  final List<EmailId> emailIds;

  _ClearEmailSuccess({required this.emailIds});
}

class _ClearEmailFailure extends _ClearEmailResult {
  final Object? exception;

  _ClearEmailFailure({this.exception});
}

sealed class _SubfoldersResult {}

class _SubfoldersAllDeleted extends _SubfoldersResult {
  final List<MailboxId> deletedIds;

  _SubfoldersAllDeleted({required this.deletedIds});
}

class _SubfoldersSomeDeleted extends _SubfoldersResult {
  final List<MailboxId> deletedIds;

  _SubfoldersSomeDeleted({required this.deletedIds});
}

class _SubfoldersDeleteFailed extends _SubfoldersResult {
  final Object? exception;

  _SubfoldersDeleteFailed({this.exception});
}

@riverpod
class EmptyFolderNotifier extends _$EmptyFolderNotifier {
  @override
  EmptyFolderState build(MailboxId mailboxId) => const EmptyFolderIdle();

  bool get mounted => ref.mounted;

  bool get _isExecuting => state is EmptyFolderLoading || state is EmptyFolderInProgress;

  Future<void> execute(
    Session session,
    AccountId accountId,
    PresentationMailbox mailbox,
    List<MailboxId> childIds,
    bool useJmapClear,
  ) async {
    if (_isExecuting) return;
    state = const EmptyFolderLoading();

    final emailResult = await _resolveEmailClearResult(
      session,
      accountId,
      mailbox,
      useJmapClear,
      onProgress: (countDeleted, totalEmails) {
        if (mounted) {
          state = EmptyFolderInProgress(
            mailboxId: mailbox.id,
            countEmailsDeleted: countDeleted,
            totalEmails: totalEmails,
          );
        }
      },
    );
    if (!mounted) return;

    if (emailResult is _ClearEmailFailure) {
      state = EmptyFolderFailure(
        exception: emailResult.exception,
        mailboxId: mailbox.id,
      );
      return;
    }

    final subfoldersResult = await _resolveSubfoldersStatus(
      session,
      accountId,
      childIds,
    );
    if (!mounted) return;

    state = EmptyFolderSuccess(
      clearedEmailIds: (emailResult as _ClearEmailSuccess).emailIds,
      mailboxId: mailbox.id,
      subfoldersStatus: subfoldersResult.status,
      deletedSubfolderIds: subfoldersResult.deletedSubfolderIds,
      subfoldersException: subfoldersResult.exception,
    );
  }

  Future<_ClearEmailResult> _resolveEmailClearResult(
    Session session,
    AccountId accountId,
    PresentationMailbox mailbox,
    bool useJmapClear, {
    EmptyFolderProgressCallback? onProgress,
  }) async {
    if (mailbox.countTotalEmails == 0) {
      return _ClearEmailSuccess(emailIds: const []);
    }
    if (useJmapClear) return _clearMailbox(session, accountId, mailbox);
    return _emptyByEmailDeletion(
      session,
      accountId,
      mailbox,
      onProgress: onProgress,
    );
  }

  Future<({SubfoldersDeleteStatus status, List<MailboxId> deletedSubfolderIds, Object? exception})> _resolveSubfoldersStatus(
    Session session,
    AccountId accountId,
    List<MailboxId> childIds,
  ) async {
    if (childIds.isEmpty) return (status: SubfoldersDeleteStatus.none, deletedSubfolderIds: <MailboxId>[], exception: null);
    final result = await _deleteSubfolders(session, accountId, childIds);
    return switch (result) {
      _SubfoldersAllDeleted(:final deletedIds) => (status: SubfoldersDeleteStatus.allDeleted, deletedSubfolderIds: deletedIds, exception: null),
      _SubfoldersSomeDeleted(:final deletedIds) => (status: SubfoldersDeleteStatus.someDeleted, deletedSubfolderIds: deletedIds, exception: null),
      _SubfoldersDeleteFailed(:final exception) => (status: SubfoldersDeleteStatus.failed, deletedSubfolderIds: <MailboxId>[], exception: exception),
    };
  }

  Future<_ClearEmailResult> _clearMailbox(
    Session session,
    AccountId accountId,
    PresentationMailbox mailbox,
  ) async {
    try {
      final role = mailbox.role;
      if (role == null) return _ClearEmailFailure();

      final result = await getBinding<ClearMailboxInteractor>()
          ?.execute(session, accountId, mailbox.id, role)
          .last;

      if (result == null) return _ClearEmailFailure();
      return result.fold(
        (failure) => _ClearEmailFailure(
          exception: failure is FeatureFailure ? failure.exception : null,
        ),
        (success) => success is ClearMailboxSuccess
            ? _ClearEmailSuccess(emailIds: const [])
            : _ClearEmailFailure(),
      );
    } catch (e, s) {
      logError('EmptyFolderNotifier::_clearMailbox', exception: e, stackTrace: s);
      return _ClearEmailFailure(exception: e);
    }
  }

  Future<_ClearEmailResult> _emptyByEmailDeletion(
    Session session,
    AccountId accountId,
    PresentationMailbox mailbox, {
    EmptyFolderProgressCallback? onProgress,
  }) async {
    final progressCtrl = StreamController<Either<Failure, Success>>.broadcast(
      sync: true,
    );
    final progressSub = onProgress != null
        ? progressCtrl.stream.listen((event) {
            event.fold((_) => null, (success) {
              if (success is EmptyingFolderState) {
                onProgress(success.countEmailsDeleted, success.totalEmails);
              }
            });
          })
        : null;
    try {
      final result = await getBinding<EmptyTrashFolderInteractor>()
          ?.execute(
            session,
            accountId,
            mailbox.id,
            mailbox.countTotalEmails,
            progressCtrl,
          )
          .last;

      if (result == null) return _ClearEmailFailure();
      return result.fold(
        (failure) => _ClearEmailFailure(
          exception: failure is FeatureFailure ? failure.exception : null,
        ),
        (success) => success is EmptyTrashFolderSuccess
            ? _ClearEmailSuccess(emailIds: success.emailIds)
            : _ClearEmailFailure(),
      );
    } catch (e, s) {
      logError('EmptyFolderNotifier::_emptyByEmailDeletion', exception: e, stackTrace: s);
      return _ClearEmailFailure(exception: e);
    } finally {
      await progressSub?.cancel();
      unawaited(progressCtrl.close());
    }
  }

  Future<_SubfoldersResult> _deleteSubfolders(
    Session session,
    AccountId accountId,
    List<MailboxId> childIds,
  ) async {
    try {
      final result = await getBinding<DeleteMultipleMailboxInteractor>()
          ?.execute(session, accountId, childIds)
          .last;

      if (result == null) return _SubfoldersDeleteFailed();
      return result.fold(
        (failure) => _SubfoldersDeleteFailed(
          exception: failure is FeatureFailure ? failure.exception : null,
        ),
        (success) {
          if (success is DeleteMultipleMailboxAllSuccess) {
            return _SubfoldersAllDeleted(deletedIds: success.listMailboxIdDeleted);
          }
          if (success is DeleteMultipleMailboxHasSomeSuccess) {
            return _SubfoldersSomeDeleted(deletedIds: success.listMailboxIdDeleted);
          }
          return _SubfoldersDeleteFailed();
        },
      );
    } catch (e, s) {
      logError('EmptyFolderNotifier::_deleteSubfolders', exception: e, stackTrace: s);
      return _SubfoldersDeleteFailed(exception: e);
    }
  }
}
