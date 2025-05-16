
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/export_trace_log_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/export_trace_log_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/trace_log_interactor_bindings.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension ExportTraceLogExtension on ManageAccountDashBoardController {

  void injectTraceLogDependencies() {
    TraceLogInteractorBindings().dependencies();
  }

  void disposeTraceLogDependencies() {
    TraceLogInteractorBindings().dispose();
  }

  Future<void> showExportTraceLogConfirmDialog(BuildContext context) async {
    await showConfirmDialogAction(
      context,
      AppLocalizations.of(context).messageExportTraceLogDialog,
      AppLocalizations.of(context).yes,
      title: AppLocalizations.of(context).exportTraceLog,
      alignCenter: true,
      outsideDismissible: false,
      useIconAsBasicLogo: false,
      cancelTitle: AppLocalizations.of(context).no,
      onConfirmAction: _exportTraceLog,
    );
  }

  void _exportTraceLog() {
    final exportTraceLogInteractor = getBinding<ExportTraceLogInteractor>();
    if (exportTraceLogInteractor != null) {
      consumeState(exportTraceLogInteractor.execute());
    }
  }

  void handleExportTraceLogSuccess(ExportTraceLogSuccess success) {
    toastManager.showMessageSuccess(success);
  }

  void handleExportTraceLogFailure(ExportTraceLogFailure failure) {
    toastManager.showMessageFailure(failure);
  }
}