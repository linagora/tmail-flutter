import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/date_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_presentation.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_responder_status.dart';

class VacationController extends BaseController {

  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();

  final GetAllVacationInteractor _getAllVacationInteractor;

  final vacationPresentation = VacationPresentation.initialize().obs;

  final TextEditingController messageBodyEditorController = TextEditingController();

  VacationResponse? currentVacation;

  VacationController(this._getAllVacationInteractor);

  @override
  void onReady() {
    _getAllVacation();
    super.onReady();
  }

  @override
  void onDone() {
    viewState.value.fold(
      (failure) => null,
      (success) {
        if (success is GetAllVacationSuccess) {
          _handleGetAllVacationSuccess(success);
        }
      }
    );
  }

  @override
  void onError(error) {}

  void _getAllVacation() {
    final accountId = _accountDashBoardController.accountId.value;
    if (accountId != null) {
      consumeState(_getAllVacationInteractor.execute(accountId));
    }
  }

  void _handleGetAllVacationSuccess(GetAllVacationSuccess success) {
    if (success.listVacationResponse?.isNotEmpty == true) {
      currentVacation = success.listVacationResponse!.first;
      log('VacationController::_handleGetAllVacationSuccess(): $currentVacation');

      final vacationStatus = currentVacation?.isEnabled;
      final startDate = currentVacation?.fromDate?.value;
      final endDate = currentVacation?.toDate?.value;
      final messageBody = currentVacation?.htmlBody ?? currentVacation?.textBody;
      final startTime = startDate != null
        ? TimeOfDay.fromDateTime(startDate)
        : null;
      final endTime = endDate != null
          ? TimeOfDay.fromDateTime(endDate)
          : null;
      final vacationStopEnabled = endDate != null;

      if (messageBody != null) {
        messageBodyEditorController.text = messageBody;
      }

      updateVacationPresentation(
        newStatus: vacationStatus == true
            ? VacationResponderStatus.activated
            : VacationResponderStatus.deactivated,
        startDate: startDate,
        startTime: startTime,
        endDate: endDate,
        endTime: endTime,
        vacationStopEnabled: vacationStopEnabled,
      );
    }
  }

  bool get isVacationDeactivated =>
      vacationPresentation.value.status == VacationResponderStatus.deactivated;

  bool get isVacationStopEnabled => vacationPresentation.value.vacationStopEnabled;

  bool get canChangeEndDate => !isVacationDeactivated && isVacationStopEnabled;

  void updateVacationPresentation({
    VacationResponderStatus? newStatus,
    DateTime? startDate,
    TimeOfDay? startTime,
    DateTime? endDate,
    TimeOfDay? endTime,
    bool? vacationStopEnabled,
  }) {
    final currentVacation = vacationPresentation.value;
    final newVacation = currentVacation.copyWidth(
        status: newStatus,
        startDate: startDate,
        startTime: startTime,
        endDate: endDate,
        endTime: endTime,
        vacationStopEnabled: vacationStopEnabled);
    vacationPresentation.value = newVacation;
  }

  void selectDate(BuildContext context, DateType dateType, DateTime? currentDate) async {
    final datePicked = await showDatePicker(
        context: context,
        initialDate: currentDate ?? DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        locale: Localizations.localeOf(context)
    );

    if (datePicked == null) {
      return;
    }

    if (dateType == DateType.start) {
      updateVacationPresentation(startDate: datePicked);
    } else {
      updateVacationPresentation(endDate: datePicked);
    }
  }

  void selectTime(BuildContext context, DateType dateType, TimeOfDay? currentTime) async {
    final timePicked = await showTimePicker(
      context: context,
      initialTime: currentTime ?? TimeOfDay.now(),
    );

    if (timePicked == null) {
      return;
    }

    if (dateType == DateType.start) {
      updateVacationPresentation(startTime: timePicked);
    } else {
      updateVacationPresentation(endTime: timePicked);
    }
  }

  void saveVacation(BuildContext context) {

  }

  @override
  void onClose() {
    messageBodyEditorController.dispose();
    super.onClose();
  }
}