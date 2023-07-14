import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rich_text_composer/richtext_controller.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
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
  final _settingController = Get.find<SettingsController>();

  final GetAllVacationInteractor _getAllVacationInteractor;
  final UpdateVacationInteractor _updateVacationInteractor;
  final VerifyNameInteractor _verifyNameInteractor;
  final RichTextWebController _richTextControllerForWeb;

  final vacationPresentation = VacationPresentation.initialize().obs;
  final errorMessageBody = Rxn<String>();

  final subjectTextController = TextEditingController();
  final subjectTextFocusNode = FocusNode();
  final richTextControllerForMobile = RichTextController();
  final htmlEditorMinHeight = 150;

  final GlobalKey htmlKey = GlobalKey();

  VacationResponse? currentVacation;
  String? _vacationMessageHtmlText;

  final ScrollController scrollController = ScrollController();

  VacationController(
    this._getAllVacationInteractor,
    this._updateVacationInteractor,
    this._verifyNameInteractor,
    this._richTextControllerForWeb
  );

  String? get vacationMessageHtmlText => _vacationMessageHtmlText;

  RichTextWebController get richTextControllerForWeb => _richTextControllerForWeb;

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
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is GetAllVacationSuccess) {
      _handleGetAllVacationSuccess(success);
    } else if (success is UpdateVacationSuccess) {
      _handleUpdateVacationSuccess(success);
    }
  }

  void _initWorker() {
    ever(_accountDashBoardController.vacationResponse, (vacation) {
      if (vacation is VacationResponse) {
        currentVacation = vacation;
        final newVacationPresentation = currentVacation?.toVacationPresentation();
        _initializeValueForVacation(newVacationPresentation ?? VacationPresentation.initialize());
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
        _initializeValueForVacation(newVacationPresentation);
      }
    }
  }

  void _initializeValueForVacation(VacationPresentation newVacation) {
    vacationPresentation.value = newVacation;
    subjectTextController.text = newVacation.subject ?? '';
    updateMessageHtmlText(newVacation.messageHtmlText ?? newVacation.messagePlainText ?? '');
    if (PlatformInfo.isWeb) {
      _richTextControllerForWeb.editorController.setText(newVacation.messageHtmlText ?? '');
    } else {
      richTextControllerForMobile.htmlEditorApi?.setText(newVacation.messageHtmlText ?? '');
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
    String? messagePlainText,
    String? messageHtmlText,
  }) {
    final currentVacation = vacationPresentation.value;
    final newVacation = currentVacation.copyWidth(
        status: newStatus,
        startDate: startDate,
        startTime: startTime,
        endDate: endDate,
        endTime: endTime,
        vacationStopEnabled: vacationStopEnabled,
        messagePlainText: messagePlainText,
        messageHtmlText: messageHtmlText
    );
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
                      style: TextButton.styleFrom(foregroundColor: AppColor.primaryColor))),
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
        return PointerInterceptor(
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColor.primaryColor,
                onPrimary: Colors.white,
                onSurface: Colors.black),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: AppColor.primaryColor))),
            child: MediaQuery(
                data: const MediaQueryData(alwaysUse24HourFormat: false),
                child: child!),
          ),
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

  void saveVacation(BuildContext context) async {
    KeyboardUtils.hideKeyboard(context);

    if (vacationPresentation.value.isEnabled) {
      final fromDate = vacationPresentation.value.fromDate;
      if (fromDate == null) {
        if (currentOverlayContext != null && currentContext != null) {
          _appToast.showToastErrorMessage(
            currentOverlayContext!,
            AppLocalizations.of(currentContext!).errorMessageWhenStartDateVacationIsEmpty);
        }
        return;
      }

      final vacationStopEnabled = vacationPresentation.value.vacationStopEnabled;
      final toDate = vacationPresentation.value.toDate;
      if (vacationStopEnabled && toDate != null && toDate.isBefore(fromDate)) {
        if (currentOverlayContext != null && currentContext != null) {
          _appToast.showToastErrorMessage(
            currentOverlayContext!,
            AppLocalizations.of(currentContext!).errorMessageWhenEndDateVacationIsInValid);
        }
        return;
      }

      final messageHtmlText = (PlatformInfo.isWeb ? _vacationMessageHtmlText : await _getMessageHtmlText()) ?? '';
      if (messageHtmlText.isEmpty && context.mounted) {
        if (currentOverlayContext != null && currentContext != null) {
          _appToast.showToastErrorMessage(
            currentOverlayContext!,
            AppLocalizations.of(currentContext!).errorMessageWhenMessageVacationIsEmpty);
        }
        return;
      }

      final subjectVacation = subjectTextController.text;

      final newVacationPresentation = vacationPresentation.value.copyWidth(
        messageHtmlText: messageHtmlText,
        subject: subjectVacation
      );
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
      if (currentOverlayContext != null && currentContext != null) {
        _appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).vacationSettingSaved);
      }
      currentVacation = success.listVacationResponse.first;
      log('VacationController::_handleUpdateVacationSuccess(): $currentVacation');

      if (currentVacation != null) {
        final newVacationPresentation = currentVacation!.toVacationPresentation();
        _initializeValueForVacation(newVacationPresentation);
      }

      _accountDashBoardController.updateVacationResponse(currentVacation);
    }
  }

  void updateMessageHtmlText(String? text) => _vacationMessageHtmlText = text;

  Future<String>? _getMessageHtmlText() {
    if (PlatformInfo.isWeb) {
      return _richTextControllerForWeb.editorController.getText();
    } else {
      return richTextControllerForMobile.htmlEditorApi?.getText();
    }
  }

  void clearFocusEditor(BuildContext context) {
    if (PlatformInfo.isMobile) {
      richTextControllerForMobile.htmlEditorApi?.unfocus();
      KeyboardUtils.hideSystemKeyboardMobile();
    }
    KeyboardUtils.hideKeyboard(context);
  }

  void backToUniversalSettings(BuildContext context) {
    clearFocusEditor(context);
    _settingController.backToUniversalSettings();
  }

  void onFocusHTMLEditor() async {
    subjectTextFocusNode.unfocus();

    await Scrollable.ensureVisible(htmlKey.currentContext!);
    await Future.delayed(const Duration(milliseconds: 500), () {
      scrollController.animateTo(
        scrollController.position.pixels + defaultKeyboardToolbarHeight + htmlEditorMinHeight,
        duration: const Duration(milliseconds: 1),
        curve: Curves.linear,
      );
    });
  }

  void onEnterKeyDown() {
    if(scrollController.position.pixels < scrollController.position.maxScrollExtent) {
      scrollController.animateTo(
        scrollController.position.pixels + 20,
        duration: const Duration(milliseconds: 1),
        curve: Curves.linear,
      );
    }
  }

  @override
  void onClose() {
    subjectTextFocusNode.dispose();
    subjectTextController.dispose();
    richTextControllerForMobile.dispose();
    scrollController.dispose();
    super.onClose();
  }
}