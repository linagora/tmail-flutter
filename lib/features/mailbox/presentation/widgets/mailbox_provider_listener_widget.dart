import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/clear_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/delete_emails_in_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/empty_trash_provider.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class MailboxProviderListenerWidget extends ConsumerWidget {
  final Widget child;

  const MailboxProviderListenerWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(emptyTrashRequestedProvider, (_, asyncValue) {
      asyncValue.whenData((trashMailbox) {
        final dashboardController = getBinding<MailboxDashBoardController>();
        if (dashboardController == null) return;
        _executeEmptyTrash(context, ref, trashMailbox, dashboardController);
      });
    });

    ref.listen(emptyTrashProvider, (_, next) {
      _handleEmptyTrashStateChange(context, next);
    });

    return child;
  }

  void _executeEmptyTrash(
    BuildContext context,
    WidgetRef ref,
    PresentationMailbox trashMailbox,
    MailboxDashBoardController dashboardController,
  ) {
    final session = dashboardController.sessionCurrent;
    final accountId = dashboardController.accountId.value;
    if (session == null || accountId == null) return;

    final childIds = dashboardController.mapMailboxById.values
        .where((m) => m.parentId == trashMailbox.id)
        .map((m) => m.id)
        .toList();

    final useJmapClear =
        CapabilityIdentifier.jmapMailboxClear.isSupported(session, accountId) &&
        !trashMailbox.isFirstLevelTeamSystemFolder(
          dashboardController.mapMailboxById,
          PresentationMailbox.trashRole,
        );

    ref.read(emptyTrashProvider.notifier).execute(
      session,
      accountId,
      trashMailbox,
      childIds,
      useJmapClear,
    );
  }

  void _handleEmptyTrashStateChange(BuildContext context, EmptyTrashState state) {
    final dashboardController = getBinding<MailboxDashBoardController>();
    if (dashboardController == null) return;

    switch (state) {
      case EmptyTrashLoading():
        dashboardController.viewStateMailboxActionProgress.value =
            Right(ClearingMailbox());

      case EmptyTrashSuccess(
        :final clearedEmailIds,
        :final mailboxId,
        :final subfoldersStatus,
      ):
        dashboardController.viewStateMailboxActionProgress.value =
            Right(UIState.idle);
        dashboardController.handleDeleteEmailsInMailbox(
          emailIds: clearedEmailIds,
          affectedMailboxId: mailboxId,
        );
        _showEmptyTrashSuccessToast(context, subfoldersStatus: subfoldersStatus);
        dashboardController.dispatchMailboxUIAction(RefreshAllMailboxAction());

      case EmptyTrashFailure(:final exception):
        dashboardController.viewStateMailboxActionProgress.value =
            Right(UIState.idle);
        _showEmptyTrashFailureToast(context);
        if (exception != null) {
          final handler = getBinding<UrgentExceptionHandler>();
          if (handler != null && handler.validateUrgentException(exception)) {
            handler.handleUrgentException(
              exception: exception is Exception ? exception : null,
            );
          }
        }

      case EmptyTrashIdle():
        break;
    }
  }

  void _showEmptyTrashSuccessToast(
    BuildContext context, {
    required SubfoldersDeleteStatus subfoldersStatus,
  }) {
    final appToast = getBinding<AppToast>();
    final appLocalizations = AppLocalizations.of(context);

    appToast?.showToastSuccessMessage(
      context,
      appLocalizations.toast_message_empty_trash_folder_success,
    );

    switch (subfoldersStatus) {
      case SubfoldersDeleteStatus.allDeleted:
        appToast?.showToastSuccessMessage(
          context,
          appLocalizations.clearTrashSubfoldersSuccess,
        );
      case SubfoldersDeleteStatus.someDeleted:
        appToast?.showToastMessage(
          context,
          appLocalizations.clearTrashSubfoldersPartialSuccess,
        );
      case SubfoldersDeleteStatus.failed:
        appToast?.showToastErrorMessage(
          context,
          appLocalizations.clearTrashSubfoldersFailed,
        );
      case SubfoldersDeleteStatus.none:
        break;
    }
  }

  void _showEmptyTrashFailureToast(BuildContext context) {
    getBinding<AppToast>()?.showToastErrorMessage(
      context,
      AppLocalizations.of(context).emptyTrashFolderFailed,
    );
  }
}
