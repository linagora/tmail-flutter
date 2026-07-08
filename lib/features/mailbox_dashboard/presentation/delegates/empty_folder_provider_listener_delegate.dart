import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/handle_urgent_exception.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/empty_folder_request.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/clear_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/strategies/empty_folder_strategy.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/strategies/trash_folder_strategy.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/dashboard_provider_listener_delegate.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/delete_emails_in_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/map_mailbox_by_id_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/empty_folder_provider.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class EmptyFolderProviderListenerDelegate
    implements DashboardProviderListenerDelegate {
  static EmptyFolderProviderListenerDelegate trash() =>
      EmptyFolderProviderListenerDelegate(strategy: const TrashFolderStrategy());

  final EmptyFolderStrategy strategy;

  ProviderSubscription<AsyncValue<EmptyFolderRequest>>? _requestSubscription;

  // Replaced on each trigger to avoid accumulating listeners across repeated executions.
  ProviderSubscription<EmptyFolderState>? _stateSubscription;

  EmptyFolderProviderListenerDelegate({required this.strategy});

  @override
  void setup(WidgetRef ref, BuildContext Function() contextOf) {
    _requestSubscription = ref.listenManual(
      emptyFolderRequestedProvider(strategy.tag),
      (_, asyncValue) {
        asyncValue.when(
          data: (request) {
            final dashboardController = getBinding<MailboxDashBoardController>();
            if (dashboardController == null) return;
            _executeEmptyFolder(contextOf(), ref, request.mailbox, dashboardController);
          },
          error: (error, _) => logError(
            'EmptyFolderProviderListenerDelegate::setup',
            exception: error,
          ),
          loading: () {},
        );
      },
    );
  }

  @override
  void dispose() {
    _requestSubscription?.close();
    _requestSubscription = null;
    _stateSubscription?.close();
    _stateSubscription = null;
  }

  void _executeEmptyFolder(
    BuildContext context,
    WidgetRef ref,
    PresentationMailbox mailbox,
    MailboxDashBoardController dashboardController,
  ) {
    final session = dashboardController.sessionCurrent;
    final accountId = dashboardController.accountId.value;
    if (session == null || accountId == null) {
      _showEmptyFolderFailureToast(context, ref);
      return;
    }

    final childIds = dashboardController.mapMailboxById.childMailboxIds(mailbox);

    final useJmapClear =
        CapabilityIdentifier.jmapMailboxClear.isSupported(session, accountId) &&
        !mailbox.isFirstLevelTeamSystemFolder(
          dashboardController.mapMailboxById,
          strategy.teamMailboxRole,
        );

    _stateSubscription?.close();
    _stateSubscription = ref.listenManual(
      emptyFolderProvider(mailbox.id),
      (_, state) => _handleEmptyFolderStateChange(
        context,
        ref,
        state,
        dashboardController,
      ),
    );

    ref
        .read(emptyFolderProvider(mailbox.id).notifier)
        .execute(session, accountId, mailbox, childIds, useJmapClear);
  }

  void _handleEmptyFolderStateChange(
    BuildContext context,
    WidgetRef ref,
    EmptyFolderState state,
    MailboxDashBoardController dashboardController,
  ) {
    switch (state) {
      case EmptyFolderLoading():
        dashboardController.syncViewStateMailboxActionProgress(
          newState: Right(ClearingMailbox()),
        );

      case EmptyFolderInProgress(
        :final mailboxId,
        :final countEmailsDeleted,
        :final totalEmails,
      ):
        dashboardController.syncViewStateMailboxActionProgress(
          newState: Right(
            EmptyingFolderState(mailboxId, countEmailsDeleted, totalEmails),
          ),
        );

      case EmptyFolderSuccess(
        :final clearedEmailIds,
        :final mailboxId,
        :final subfoldersStatus,
        :final deletedSubfolderIds,
        :final subfoldersException,
      ):
        _stateSubscription?.close();
        _stateSubscription = null;
        _resetProgress(dashboardController);
        _applyEmailChanges(dashboardController, clearedEmailIds, mailboxId);
        dashboardController.removeMailboxesFromMap(deletedSubfolderIds);
        _showEmptyFolderSuccessToast(
          context,
          ref,
          subfoldersStatus: subfoldersStatus,
        );
        _handleUrgentException(subfoldersException);
        dashboardController.dispatchMailboxUIAction(RefreshAllMailboxAction());
        dashboardController.dispatchEmailUIAction(RefreshAllEmailAction());

      case EmptyFolderFailure(:final exception):
        _stateSubscription?.close();
        _stateSubscription = null;
        _resetProgress(dashboardController);
        // Skip the generic failure toast when the urgent handler already owns
        // the UX (re-login, reconnect), to avoid a duplicate error surface.
        if (!_handleUrgentException(exception)) {
          _showEmptyFolderFailureToast(context, ref);
        }

      case EmptyFolderIdle():
        break;
    }
  }

  void _applyEmailChanges(
    MailboxDashBoardController dashboardController,
    List<EmailId> clearedEmailIds,
    MailboxId mailboxId,
  ) {
    if (clearedEmailIds.isEmpty) {
      dashboardController.handleClearAllEmailsInMailbox(mailboxId);
    } else {
      dashboardController.handleDeleteEmailsInMailbox(
        emailIds: clearedEmailIds,
        affectedMailboxId: mailboxId,
      );
    }
  }

  // Routes urgent exceptions through the shared helper (ADR-0093). Returns true
  // when the failure was urgent and handled centrally, so the caller can skip
  // its own error UI.
  bool _handleUrgentException(Object? exception) {
    if (exception == null) return false;
    return handleUrgentExceptionIfNeeded(exception: exception);
  }

  void _resetProgress(MailboxDashBoardController dashboardController) {
    dashboardController.syncViewStateMailboxActionProgress(
      newState: Right(UIState.idle),
    );
  }

  void _showEmptyFolderSuccessToast(
    BuildContext context,
    WidgetRef ref, {
    required SubfoldersDeleteStatus subfoldersStatus,
  }) {
    final appToast = ref.read(appToastProvider);
    final l10n = AppLocalizations.of(context);

    appToast.showToastSuccessMessage(context, strategy.successMessage(l10n));

    switch (subfoldersStatus) {
      case SubfoldersDeleteStatus.allDeleted:
        final message = strategy.subfoldersAllDeletedMessage(l10n);
        if (message != null) {
          appToast.showToastSuccessMessage(context, message);
        }
      case SubfoldersDeleteStatus.someDeleted:
        final message = strategy.subfoldersPartiallyDeletedMessage(l10n);
        if (message != null) appToast.showToastMessage(context, message);
      case SubfoldersDeleteStatus.failed:
        final message = strategy.subfoldersDeleteFailedMessage(l10n);
        if (message != null) appToast.showToastErrorMessage(context, message);
      case SubfoldersDeleteStatus.none:
        break;
    }
  }

  void _showEmptyFolderFailureToast(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    ref.read(appToastProvider).showToastErrorMessage(
      context,
      strategy.failureMessage(l10n),
    );
  }
}
