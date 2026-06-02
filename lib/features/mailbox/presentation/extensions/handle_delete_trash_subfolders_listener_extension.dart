import 'package:core/presentation/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/providers/delete_trash_subfolders_provider.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_provider_listener_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleDeleteTrashSubfoldersListenerExtension
    on MailboxProviderListenerWidget {
  void listenDeleteTrashSubfolders(BuildContext context, WidgetRef ref) {
    ref.listen(deleteTrashSubfoldersProvider, (_, next) {
      switch (next) {
        case DeleteTrashSubfoldersSuccess() ||
              DeleteTrashSubfoldersPartialSuccess():
          _onDeleteCompleted(context, next);
        case DeleteTrashSubfoldersFailed(:final exception):
          _onDeleteFailed(context, exception);
        case DeleteTrashSubfoldersIdle() || DeleteTrashSubfoldersLoading():
          break;
      }
    });
  }

  void _onDeleteCompleted(
    BuildContext context,
    DeleteTrashSubfoldersState result,
  ) {
    final appToast = getBinding<AppToast>();
    if (result is DeleteTrashSubfoldersSuccess) {
      appToast?.showToastSuccessMessage(
        context,
        AppLocalizations.of(context).clearTrashSubfoldersSuccess,
      );
    } else {
      appToast?.showToastMessage(
        context,
        AppLocalizations.of(context).clearTrashSubfoldersPartialSuccess,
      );
    }
    getBinding<MailboxDashBoardController>()
        ?.dispatchMailboxUIAction(RefreshAllMailboxAction());
  }

  void _onDeleteFailed(BuildContext context, Object? exception) {
    getBinding<AppToast>()?.showToastErrorMessage(
      context,
      AppLocalizations.of(context).clearTrashSubfoldersFailed,
    );
    _handleUrgentException(exception);
  }

  void _handleUrgentException(Object? exception) {
    final dashboardController = getBinding<MailboxDashBoardController>();
    if (exception == null || dashboardController == null) return;
    if (!dashboardController.validateUrgentException(exception)) return;

    dashboardController.handleUrgentException(
      exception: exception is Exception ? exception : null,
    );
  }
}
