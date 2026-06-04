import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/clear_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/adapters/empty_folder_adapter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/dashboard_provider_listener_delegate.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/delete_emails_in_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/execute_empty_trash_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/empty_folder_provider.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class EmptyFolderProviderListenerDelegate
    implements DashboardProviderListenerDelegate {
  final EmptyFolderAdapter adapter;

  // Tracks the active notifier subscription so it can be replaced without
  // accumulating listeners when the user triggers empty-folder multiple times.
  ProviderSubscription<EmptyFolderState>? _stateSubscription;

  EmptyFolderProviderListenerDelegate({required this.adapter});

  @override
  void listen(BuildContext context, WidgetRef ref) {
    ref.listen(emptyFolderRequestedProvider(adapter.tag), (_, asyncValue) {
      asyncValue.whenData((mailbox) {
        final dashboardController = getBinding<MailboxDashBoardController>();
        if (dashboardController == null) return;
        _executeEmptyFolder(context, ref, mailbox, dashboardController);
      });
    });
  }

  void _executeEmptyFolder(
    BuildContext context,
    WidgetRef ref,
    PresentationMailbox mailbox,
    MailboxDashBoardController dashboardController,
  ) {
    final session = dashboardController.sessionCurrent;
    final accountId = dashboardController.accountId.value;
    if (session == null || accountId == null) return;

    final childIds = dashboardController.childMailboxIds(mailbox);

    final useJmapClear =
        CapabilityIdentifier.jmapMailboxClear.isSupported(session, accountId) &&
        !mailbox.isFirstLevelTeamSystemFolder(
          dashboardController.mapMailboxById,
          adapter.teamMailboxRole,
        );

    _stateSubscription?.close();
    _stateSubscription = ref.listenManual(
      emptyFolderNotifierProvider(mailbox.id),
      (_, state) => _handleEmptyFolderStateChange(context, state),
    );

    ref
        .read(emptyFolderNotifierProvider(mailbox.id).notifier)
        .execute(session, accountId, mailbox, childIds, useJmapClear);
  }

  void _handleEmptyFolderStateChange(
    BuildContext context,
    EmptyFolderState state,
  ) {
    final dashboardController = getBinding<MailboxDashBoardController>();
    if (dashboardController == null) return;

    switch (state) {
      case EmptyFolderLoading():
        dashboardController.viewStateMailboxActionProgress.value = Right(
          ClearingMailbox(),
        );

      case EmptyFolderSuccess(
        :final clearedEmailIds,
        :final mailboxId,
        :final subfoldersStatus,
      ):
        _resetProgress(dashboardController);
        if (clearedEmailIds.isEmpty) {
          dashboardController.handleClearAllEmailsInMailbox(mailboxId);
        } else {
          dashboardController.handleDeleteEmailsInMailbox(
            emailIds: clearedEmailIds,
            affectedMailboxId: mailboxId,
          );
        }
        _showEmptyFolderSuccessToast(
          context,
          subfoldersStatus: subfoldersStatus,
        );
        dashboardController.dispatchMailboxUIAction(RefreshAllMailboxAction());

      case EmptyFolderFailure(:final exception):
        _resetProgress(dashboardController);
        _showEmptyFolderFailureToast(context);
        if (exception != null) {
          final handler = getBinding<UrgentExceptionHandler>();
          if (handler != null && handler.validateUrgentException(exception)) {
            handler.handleUrgentException(
              exception: exception is Exception ? exception : null,
            );
          }
        }

      case EmptyFolderIdle():
        break;
    }
  }

  void _resetProgress(MailboxDashBoardController dashboardController) {
    dashboardController.viewStateMailboxActionProgress.value = Right(
      UIState.idle,
    );
  }

  void _showEmptyFolderSuccessToast(
    BuildContext context, {
    required SubfoldersDeleteStatus subfoldersStatus,
  }) {
    final appToast = getBinding<AppToast>();
    final l10n = AppLocalizations.of(context);

    appToast?.showToastSuccessMessage(context, adapter.successMessage(l10n));

    switch (subfoldersStatus) {
      case SubfoldersDeleteStatus.allDeleted:
        final message = adapter.subfoldersAllDeletedMessage(l10n);
        if (message != null) appToast?.showToastSuccessMessage(context, message);
      case SubfoldersDeleteStatus.someDeleted:
        final message = adapter.subfoldersPartiallyDeletedMessage(l10n);
        if (message != null) appToast?.showToastMessage(context, message);
      case SubfoldersDeleteStatus.failed:
        final message = adapter.subfoldersDeleteFailedMessage(l10n);
        if (message != null) appToast?.showToastErrorMessage(context, message);
      case SubfoldersDeleteStatus.none:
        break;
    }
  }

  void _showEmptyFolderFailureToast(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    getBinding<AppToast>()?.showToastErrorMessage(
      context,
      adapter.failureMessage(l10n),
    );
  }
}
