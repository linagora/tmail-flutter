import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/update_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/date_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_presentation.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_responder_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class VacationController extends BaseController {

  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();
  final _appToast = Get.find<AppToast>();
  final _imagePaths = Get.find<ImagePaths>();
  final _settingController = Get.find<SettingsController>();

  final GetAllVacationInteractor _getAllVacationInteractor;
  final UpdateVacationInteractor _updateVacationInteractor;
  final VerifyNameInteractor _verifyNameInteractor;

  final vacationPresentation = VacationPresentation.initialize().obs;
  final errorMessageBody = Rxn<String>();

  final messageTextController = TextEditingController();
  final subjectTextController = TextEditingController();

  VacationResponse? currentVacation;
  late Worker vacationWorker;

  VacationController(
    this._getAllVacationInteractor,
    this._updateVacationInteractor,
    this._verifyNameInteractor
  );

  @override
  void onInit() {
    _initWorker();
    super.onInit();
  }

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
        } else if (success is UpdateVacationSuccess) {
          _handleUpdateVacationSuccess(success);
        }
      }
    );
  }

  @override
  void onError(error) {}

  void _initWorker() {
    vacationWorker = ever(_accountDashBoardController.vacationResponse, (vacation) {
      if (vacation is VacationResponse) {
        currentVacation = vacation;
        final newVacationPresentation = currentVacation?.toVacationPresentation();
        vacationPresentation.value = newVacationPresentation ?? VacationPresentation.initialize();
        messageTextController.text = newVacationPresentation?.messageBody ?? '';
        subjectTextController.text = newVacationPresentation?.subject ?? '';
      }
    });
  }

  void _getAllVacation() {
    final accountId = _accountDashBoardController.accountId.value;
    if (accountId != null) {
      consumeState(_getAllVacationInteractor.execute(accountId));
    }
  }

  void _handleGetAllVacationSuccess(GetAllVacationSuccess success) {
    if (success.listVacationResponse.isNotEmpty) {
      currentVacation = success.listVacationResponse.first;
      log('VacationController::_handleGetAllVacationSuccess(): $currentVacation');

      if (currentVacation != null) {
        final newVacationPresentation = currentVacation!.toVacationPresentation();
        vacationPresentation.value = newVacationPresentation;
        messageTextController.text = newVacationPresentation.messageBody ?? '';
        subjectTextController.text = newVacationPresentation.subject ?? '';
      }
    }
  }

  bool get isVacationDeactivated => !vacationPresentation.value.isEnabled;

  bool get isVacationStopEnabled => vacationPresentation.value.vacationStopEnabled;

  bool get canChangeEndDate => !isVacationDeactivated && isVacationStopEnabled;

  void updateVacationPresentation({
    VacationResponderStatus? newStatus,
    DateTime? startDate,
    TimeOfDay? startTime,
    DateTime? endDate,
    TimeOfDay? endTime,
    bool? vacationStopEnabled,
    String? messageBody
  }) {
    final currentVacation = vacationPresentation.value;
    final newVacation = currentVacation.copyWidth(
        status: newStatus,
        startDate: startDate,
        startTime: startTime,
        endDate: endDate,
        endTime: endTime,
        vacationStopEnabled: vacationStopEnabled,
        messageBody: messageBody);
    log('VacationController::updateVacationPresentation():newVacation: $newVacation');
    vacationPresentation.value = newVacation;
  }

  void selectDate(BuildContext context, DateType dateType, DateTime? currentDate) async {
    final datePicked = await showDatePicker(
        context: context,
        initialDate: currentDate ?? DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        locale: Localizations.localeOf(context),
        builder: (context, child) {
          return Theme(
              data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                      primary: AppColor.primaryColor,
                      onPrimary: Colors.white,
                      onSurface: Colors.black),
                  textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(primary: AppColor.primaryColor))),
              child: child!);
        }
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(primary: AppColor.primaryColor))),
          child: MediaQuery(
              data: const MediaQueryData(alwaysUse24HourFormat: false),
              child: child!),
        );
      }
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

  String? _getErrorStringByInputValue(BuildContext context, String? inputValue) {
    return _verifyNameInteractor.execute(inputValue, [EmptyNameValidator()]).fold(
      (failure) {
        if (failure is VerifyNameFailure) {
          return failure.getMessageVacation(context);
        } else {
          return null;
        }
      },
      (success) => null
    );
  }

  void updateMessageBody(BuildContext context, String? value) {
    errorMessageBody.value = _getErrorStringByInputValue(context, value);
  }

  void saveVacation(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (vacationPresentation.value.isEnabled) {
      final fromDate = vacationPresentation.value.fromDate;
      if (fromDate == null) {
          _appToast.showToastWithIcon(
              context,
              bgColor: AppColor.toastErrorBackgroundColor,
              textColor: Colors.white,
              message: AppLocalizations.of(context).errorMessageWhenStartDateVacationIsEmpty);
        return;
      }

      final vacationStopEnabled = vacationPresentation.value.vacationStopEnabled;
      final toDate = vacationPresentation.value.toDate;
      if (vacationStopEnabled && toDate != null && toDate.isBefore(fromDate)) {
        _appToast.showToastWithIcon(
            context,
            bgColor: AppColor.toastErrorBackgroundColor,
            textColor: Colors.white,
            message: AppLocalizations.of(context).errorMessageWhenEndDateVacationIsInValid);
        return;
      }

      final messageBody = messageTextController.text;
      if (messageBody.isEmpty) {
        _appToast.showToastWithIcon(
            context,
            bgColor: AppColor.toastErrorBackgroundColor,
            textColor: Colors.white,
            message: AppLocalizations.of(context).errorMessageWhenMessageVacationIsEmpty);
        return;
      }

      final subjectVacation = subjectTextController.text;

      final newVacationPresentation = vacationPresentation.value.copyWidth(
          messageBody: messageBody,
          subject: subjectVacation);
      log('VacationController::saveVacation(): newVacationPresentation: $newVacationPresentation');
      final newVacationResponse = newVacationPresentation.toVacationResponse();
      log('VacationController::saveVacation(): newVacationResponse: $newVacationResponse');
      _updateVacationAction(newVacationResponse);
    } else {
      final vacationDisabled = currentVacation != null
          ? currentVacation!.copyWith(isEnabled: false)
          : VacationResponse(isEnabled: false);
      log('VacationController::saveVacation(): vacationDisabled: $vacationDisabled');
      _updateVacationAction(vacationDisabled);
    }
  }

  void _updateVacationAction(VacationResponse vacationResponse) {
    final accountId = _accountDashBoardController.accountId.value;
    if (accountId != null) {
      consumeState(_updateVacationInteractor.execute(accountId, vacationResponse));
    }
  }

  void _handleUpdateVacationSuccess(UpdateVacationSuccess success) {
    if (success.listVacationResponse.isNotEmpty) {
      if (currentContext != null && currentOverlayContext != null) {
        _appToast.showToastWithIcon(
            currentOverlayContext!,
            message: AppLocalizations.of(currentContext!).vacationSettingSaved,
            icon: _imagePaths.icChecked);
      }
      currentVacation = success.listVacationResponse.first;
      log('VacationController::_handleUpdateVacationSuccess(): $currentVacation');

      if (currentVacation != null) {
        final newVacationPresentation = currentVacation!.toVacationPresentation();
        vacationPresentation.value = newVacationPresentation;
        messageTextController.text = newVacationPresentation.messageBody ?? '';
        subjectTextController.text = newVacationPresentation.subject ?? '';
      }

      _accountDashBoardController.updateVacationResponse(currentVacation);
    }
  }

  void backToUniversalSettings() {
    _settingController.backToUniversalSettings();
  }

  @override
  void onClose() {
    messageTextController.dispose();
    subjectTextController.dispose();
    vacationWorker.dispose();
    super.onClose();
  }
}