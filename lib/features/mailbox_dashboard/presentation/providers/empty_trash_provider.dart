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
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_trash_folder_interactor.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

part 'empty_trash_provider.g.dart';

@riverpod
Stream<PresentationMailbox> emptyTrashRequested(Ref ref) =>
    Get.find<MailboxDashBoardController>().onEmptyTrashRequested;

sealed class EmptyTrashState {
  const EmptyTrashState();
}

class EmptyTrashIdle extends EmptyTrashState {
  const EmptyTrashIdle();
}

class EmptyTrashLoading extends EmptyTrashState {
  const EmptyTrashLoading();
}

enum SubfoldersDeleteStatus { none, allDeleted, someDeleted, failed }

class EmptyTrashSuccess extends EmptyTrashState {
  final List<EmailId> clearedEmailIds;
  final MailboxId? mailboxId;
  final Role mailboxRole;
  final SubfoldersDeleteStatus subfoldersStatus;

  const EmptyTrashSuccess({
    required this.clearedEmailIds,
    required this.mailboxId,
    required this.mailboxRole,
    this.subfoldersStatus = SubfoldersDeleteStatus.none,
  });
}

class EmptyTrashFailure extends EmptyTrashState {
  final Object? exception;
  final Role mailboxRole;

  const EmptyTrashFailure({
    this.exception,
    required this.mailboxRole,
  });
}

sealed class _ClearEmailResult {}

class _ClearEmailSuccess extends _ClearEmailResult {
  final List<EmailId> emailIds;
  final MailboxId? mailboxId;

  _ClearEmailSuccess({required this.emailIds, this.mailboxId});
}

class _ClearEmailFailure extends _ClearEmailResult {
  final Object? exception;

  _ClearEmailFailure({this.exception});
}

sealed class _SubfoldersResult {}

class _SubfoldersAllDeleted extends _SubfoldersResult {}

class _SubfoldersSomeDeleted extends _SubfoldersResult {}

class _SubfoldersDeleteFailed extends _SubfoldersResult {
  final Object? exception;

  _SubfoldersDeleteFailed({this.exception});
}

@riverpod
class EmptyTrashNotifier extends _$EmptyTrashNotifier {
  @override
  EmptyTrashState build() => const EmptyTrashIdle();

  bool get mounted => ref.mounted;
  bool get _isExecuting => state is EmptyTrashLoading;

  Future<void> execute(
    Session session,
    AccountId accountId,
    PresentationMailbox trashMailbox,
    List<MailboxId> childIds,
    bool useJmapClear,
  ) async {
    if (_isExecuting) return;
    state = const EmptyTrashLoading();

    final emailResult = trashMailbox.countTotalEmails == 0
        ? _ClearEmailSuccess(emailIds: const [], mailboxId: null)
        : useJmapClear
            ? await _clearMailbox(session, accountId, trashMailbox)
            : await _emptyTrashByEmailDeletion(session, accountId, trashMailbox);

    if (!mounted) return;

    final trashRole = trashMailbox.role ?? Role(PresentationMailbox.trashRole);

    if (emailResult is _ClearEmailFailure) {
      state = EmptyTrashFailure(
        exception: emailResult.exception,
        mailboxRole: trashRole,
      );
      return;
    }

    final emailSuccess = emailResult as _ClearEmailSuccess;

    var subfoldersStatus = SubfoldersDeleteStatus.none;

    if (childIds.isNotEmpty) {
      final subfoldersResult = await _deleteSubfolders(session, accountId, childIds);
      if (!mounted) return;
      subfoldersStatus = switch (subfoldersResult) {
        _SubfoldersAllDeleted() => SubfoldersDeleteStatus.allDeleted,
        _SubfoldersSomeDeleted() => SubfoldersDeleteStatus.someDeleted,
        _SubfoldersDeleteFailed() => SubfoldersDeleteStatus.failed,
      };
    }

    state = EmptyTrashSuccess(
      clearedEmailIds: emailSuccess.emailIds,
      mailboxId: emailSuccess.mailboxId,
      mailboxRole: trashRole,
      subfoldersStatus: subfoldersStatus,
    );
  }

  Future<_ClearEmailResult> _clearMailbox(
    Session session,
    AccountId accountId,
    PresentationMailbox trashMailbox,
  ) async {
    try {
      final role = trashMailbox.role;
      if (role == null) return _ClearEmailFailure();

      final result = await getBinding<ClearMailboxInteractor>()
          ?.execute(session, accountId, trashMailbox.id, role)
          .last;

      if (result == null) return _ClearEmailFailure();
      return result.fold(
        (failure) => _ClearEmailFailure(
          exception: failure is FeatureFailure ? failure.exception : null,
        ),
        (success) => success is ClearMailboxSuccess
            ? _ClearEmailSuccess(emailIds: const [], mailboxId: trashMailbox.id)
            : _ClearEmailFailure(),
      );
    } catch (e) {
      logError('EmptyTrashNotifier::_clearMailbox: $e');
      return _ClearEmailFailure(exception: e);
    }
  }

  Future<_ClearEmailResult> _emptyTrashByEmailDeletion(
    Session session,
    AccountId accountId,
    PresentationMailbox trashMailbox,
  ) async {
    final progressCtrl = StreamController<Either<Failure, Success>>();
    try {
      final result = await getBinding<EmptyTrashFolderInteractor>()
          ?.execute(
            session,
            accountId,
            trashMailbox.id,
            trashMailbox.countTotalEmails,
            progressCtrl,
          )
          .last;
      unawaited(progressCtrl.close());

      if (result == null) return _ClearEmailFailure();
      return result.fold(
        (failure) => _ClearEmailFailure(
          exception: failure is FeatureFailure ? failure.exception : null,
        ),
        (success) => success is EmptyTrashFolderSuccess
            ? _ClearEmailSuccess(
                emailIds: success.emailIds,
                mailboxId: success.mailboxId,
              )
            : _ClearEmailFailure(),
      );
    } catch (e) {
      logError('EmptyTrashNotifier::_emptyTrashByEmailDeletion: $e');
      unawaited(progressCtrl.close());
      return _ClearEmailFailure(exception: e);
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
          if (success is DeleteMultipleMailboxAllSuccess) return _SubfoldersAllDeleted();
          if (success is DeleteMultipleMailboxHasSomeSuccess) return _SubfoldersSomeDeleted();
          return _SubfoldersDeleteFailed();
        },
      );
    } catch (e) {
      logError('EmptyTrashNotifier::_deleteSubfolders: $e');
      return _SubfoldersDeleteFailed(exception: e);
    }
  }
}
