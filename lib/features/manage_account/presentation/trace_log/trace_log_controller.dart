import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/log_tracking.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/export_trace_log_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_trace_log_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/export_trace_log_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_trace_log_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/permission_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class TraceLogController extends BaseController {

  final GetTraceLogInteractor _getTraceLogInteractor;
  final ExportTraceLogInteractor _exportTraceLogInteractor;

  TraceLogController(
    this._getTraceLogInteractor,
    this._exportTraceLogInteractor,
  );

  final tracLog = Rxn<TraceLog>();

  @override
  void onInit() {
    super.onInit();
    _getTraceLog();
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is GetTraceLogSuccess) {
      tracLog.value = success.traceLog;
    } else if (success is ExportTraceLogSuccess) {
      _handleExportTraceLogSuccess(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is GetTraceLogFailure) {
      if (currentContext != null && currentOverlayContext != null) {
        appToast.showToastErrorMessage(
          currentOverlayContext!,
          failure.exception.toString());
      }
    } else if (failure is ExportTraceLogFailure) {
      _handleExportTraceLogFailure(failure);
    }
  }

  void _getTraceLog() {
    consumeState(_getTraceLogInteractor.execute());
  }

  void exportTraceLogFile(TraceLog traceLog) {
    consumeState(_exportTraceLogInteractor.execute(traceLog));
  }

  void _handleExportTraceLogSuccess(ExportTraceLogSuccess success) {
    if (currentContext != null && currentOverlayContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).exportTraceLogSuccess(success.savePath));
    }
  }

  void _handleExportTraceLogFailure(ExportTraceLogFailure failure) {
    if (failure.exception is NotGrantedPermissionStorageException) {
      if (currentContext != null && currentOverlayContext != null) {
        appToast.showToastWarningMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).youNeedToGrantFilesPermissionToExportFile);
      }
    } else {
      if (currentContext != null && currentOverlayContext != null) {
        appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).exportTraceLogFailed);
      }
    }
  }

  bool get isExporting => viewState.value.fold(
    (failure) => false,
    (success) => success is ExportTraceLogLoading);

}