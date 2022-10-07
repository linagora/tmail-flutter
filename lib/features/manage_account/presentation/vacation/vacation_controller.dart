import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
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
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_message_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_presentation.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_responder_status.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/utils/vacation_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller_bindings.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class VacationController extends BaseController {

  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();
  final _appToast = Get.find<AppToast>();
  final _imagePaths = Get.find<ImagePaths>();
  final _settingController = Get.find<SettingsController>();
  final _richTextControllerForWeb = Get.find<RichTextWebController>(tag: VacationUtils.vacationTagName);

  final GetAllVacationInteractor _getAllVacationInteractor;
  final UpdateVacationInteractor _updateVacationInteractor;
  final VerifyNameInteractor _verifyNameInteractor;

  final vacationPresentation = VacationPresentation.initialize().obs;
  final errorMessageBody = Rxn<String>();
  final vacationMessageType = Rx<VacationMessageType>(VacationMessageType.plainText);

  final messageTextController = TextEditingController();
  final subjectTextController = TextEditingController();
  final richTextControllerForMobile = RichTextController();
  final htmlEditorMinHeight = 150;

  final GlobalKey htmlKey = GlobalKey();

  VacationResponse? currentVacation;
  String? _vacationMessageHtmlText;

  late Worker vacationWorker;

  final ScrollController scrollController = ScrollController();

  VacationController(
    this._getAllVacationInteractor,
    this._updateVacationInteractor,
    this._verifyNameInteractor
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
    messageTextController.text = newVacation.messagePlainText ?? '';
    subjectTextController.text = newVacation.subject ?? '';
    updateMessageHtmlText(newVacation.messageHtmlText ?? '');
    if (BuildUtils.isWeb) {
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

  void saveVacation(BuildContext context) async {
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

      final messagePlainText = messageTextController.text;
      final messageHtmlText = (BuildUtils.isWeb ? _vacationMessageHtmlText : await _getMessageHtmlText()) ?? '';
      if (messagePlainText.isEmpty && messageHtmlText.isEmpty) {
        _appToast.showToastWithIcon(
            context,
            bgColor: AppColor.toastErrorBackgroundColor,
            textColor: Colors.white,
            message: AppLocalizations.of(context).errorMessageWhenMessageVacationIsEmpty);
        return;
      }

      final subjectVacation = subjectTextController.text;

      final newVacationPresentation = vacationPresentation.value.copyWidth(
          messagePlainText: messagePlainText,
          messageHtmlText: messageHtmlText,
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
        _initializeValueForVacation(newVacationPresentation);
      }

      _accountDashBoardController.updateVacationResponse(currentVacation);
    }
  }

  void updateMessageHtmlText(String? text) => _vacationMessageHtmlText = text;

  Future<String>? _getMessageHtmlText() {
    if (BuildUtils.isWeb) {
      return _richTextControllerForWeb.editorController.getText();
    } else {
      return richTextControllerForMobile.htmlEditorApi?.getText();
    }
  }

  void selectVacationMessageType(BuildContext context, VacationMessageType newMessageType) {
    if (newMessageType == VacationMessageType.plainText && !BuildUtils.isWeb) {
      _storeMessageHtmlTextOnMobile();
    }
    clearFocusEditor(context);
    vacationMessageType.value = newMessageType;
  }

  void _storeMessageHtmlTextOnMobile() async {
    final messageHtml = await _getMessageHtmlText();
    updateMessageHtmlText(messageHtml);
  }

  void clearFocusEditor(BuildContext context) {
    if (!BuildUtils.isWeb) {
      richTextControllerForMobile.htmlEditorApi?.unfocus();
    }
    FocusScope.of(context).unfocus();
  }

  void backToUniversalSettings(BuildContext context) {
    clearFocusEditor(context);
    _settingController.backToUniversalSettings();
  }

  void onFocusHTMLEditor() async {
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
    messageTextController.dispose();
    subjectTextController.dispose();
    richTextControllerForMobile.dispose();
    vacationWorker.dispose();
    scrollController.dispose();
    VacationControllerBindings().dispose();
    super.onClose();
  }
}