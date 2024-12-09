import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:rich_text_composer/views/commons/constants.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/update_vacation_state.dart';
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
  final _settingController = Get.find<SettingsController>();

  final UpdateVacationInteractor _updateVacationInteractor;
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
    this._updateVacationInteractor,
    this._richTextControllerForWeb
  );

  String? get vacationMessageHtmlText => _vacationMessageHtmlText;

  RichTextWebController get richTextControllerForWeb => _richTextControllerForWeb;

  @override
  void onInit() {
    _initWorker();
    _initFocusListener();
    super.onInit();
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is UpdateVacationSuccess) {
      _handleUpdateVacationSuccess(success);
    } else {
      super.handleSuccessViewState(success);
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

  void _initFocusListener() {
    subjectTextFocusNode.addListener(_onSubjectTextListener);
  }

  void _onSubjectTextListener() {
    if (subjectTextFocusNode.hasFocus && PlatformInfo.isMobile) {
      richTextControllerForMobile.hideRichTextView();
    }
  }

  void _initializeValueForVacation(VacationPresentation newVacation) {
    vacationPresentation.value = newVacation;
    subjectTextController.text = newVacation.subject ?? '';
    updateMessageHtmlText(newVacation.messageHtmlText ?? '');
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
    Option<DateTime>? startDateOption,
    Option<TimeOfDay>? startTimeOption,
    Option<DateTime>? endDateOption,
    Option<TimeOfDay>? endTimeOption,
    bool? vacationStopEnabled,
    Option<String>? messagePlainTextOption,
    Option<String>? messageHtmlTextOption,
  }) {
    final currentVacation = vacationPresentation.value;
    final stopEnabled = vacationStopEnabled ?? currentVacation.vacationStopEnabled;
    final newVacation = currentVacation.copyWith(
        status: newStatus,
        startDateOption: startDateOption,
        startTimeOption: startTimeOption,
        endDateOption: stopEnabled ? endDateOption : const None(),
        endTimeOption: stopEnabled ? endTimeOption : const None(),
        vacationStopEnabled: vacationStopEnabled,
        messagePlainTextOption: messagePlainTextOption,
        messageHtmlTextOption: messageHtmlTextOption
    );
    log('VacationController::updateVacationPresentation():newVacation: $newVacation');
    vacationPresentation.value = newVacation;
  }

  void selectDate(BuildContext context, DateType dateType, DateTime? currentDate) async {
    if (PlatformInfo.isMobile) {
      richTextControllerForMobile.htmlEditorApi?.unfocus();
    }
    FocusScope.of(context).unfocus();

    _accountDashBoardController.isVacationDateDialogDisplayed = true;
    final datePicked = await showDatePicker(
        context: context,
        initialDate: currentDate ?? DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        locale: Localizations.localeOf(context),
        builder: (context, child) {
          return PointerInterceptor(
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColor.primaryColor,
                  onPrimary: Colors.white,
                  onSurface: Colors.black
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColor.primaryColor
                  )
                )
              ),
              child: child!
            ),
          );
        }
    ).whenComplete(() => _accountDashBoardController.isVacationDateDialogDisplayed = false);

    if (datePicked == null) {
      return;
    }

    if (dateType == DateType.start) {
      updateVacationPresentation(startDateOption: Some(datePicked));
    } else {
      updateVacationPresentation(endDateOption: Some(datePicked));
    }
  }

  void selectTime(BuildContext context, DateType dateType, TimeOfDay? currentTime) async {
    if (PlatformInfo.isMobile) {
      richTextControllerForMobile.htmlEditorApi?.unfocus();
    }
    FocusScope.of(context).unfocus();

    _accountDashBoardController.isVacationDateDialogDisplayed = true;
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
    ).whenComplete(() => _accountDashBoardController.isVacationDateDialogDisplayed = false);

    if (timePicked == null) {
      return;
    }

    if (dateType == DateType.start) {
      updateVacationPresentation(startTimeOption: Some(timePicked));
    } else {
      updateVacationPresentation(endTimeOption: Some(timePicked));
    }
  }

  void saveVacation(BuildContext context) async {
    KeyboardUtils.hideKeyboard(context);

    if (vacationPresentation.value.isEnabled) {
      final fromDate = vacationPresentation.value.fromDate;
      if (fromDate == null) {
        if (currentOverlayContext != null && currentContext != null) {
          appToast.showToastErrorMessage(
            currentOverlayContext!,
            AppLocalizations.of(currentContext!).errorMessageWhenStartDateVacationIsEmpty);
        }
        return;
      }

      final vacationStopEnabled = vacationPresentation.value.vacationStopEnabled;
      final toDate = vacationPresentation.value.toDate;
      if (vacationStopEnabled && toDate != null && toDate.isBefore(fromDate)) {
        if (currentOverlayContext != null && currentContext != null) {
          appToast.showToastErrorMessage(
            currentOverlayContext!,
            AppLocalizations.of(currentContext!).errorMessageWhenEndDateVacationIsInValid);
        }
        return;
      }

      final messageHtmlText = (PlatformInfo.isWeb ? _vacationMessageHtmlText : await _getMessageHtmlText()) ?? '';
      if (messageHtmlText.isEmpty && context.mounted) {
        if (currentOverlayContext != null && currentContext != null) {
          appToast.showToastErrorMessage(
            currentOverlayContext!,
            AppLocalizations.of(currentContext!).errorMessageWhenMessageVacationIsEmpty);
        }
        return;
      }

      final subjectVacation = subjectTextController.text;

      final newVacationPresentation = vacationPresentation.value.copyWith(
        messageHtmlTextOption: Some(messageHtmlText),
        subjectOption: Some(subjectVacation)
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
        appToast.showToastSuccessMessage(
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
    }
    KeyboardUtils.hideKeyboard(context);
  }

  void backToUniversalSettings(BuildContext context) {
    clearFocusEditor(context);
    _settingController.backToUniversalSettings();
  }

  void initRichTextForMobile(BuildContext context, HtmlEditorApi editorApi) {
    richTextControllerForMobile.onCreateHTMLEditor(
      editorApi,
      onFocus: () => onFocusHTMLEditor(context),
      onEnterKeyDown: onEnterKeyDown,
    );
  }

  void onFocusHTMLEditor(BuildContext context) async {
    if (PlatformInfo.isAndroid) {
      FocusScope.of(context).unfocus();
      await Future.delayed(
        const Duration(milliseconds: 300),
        richTextControllerForMobile.showDeviceKeyboard);
    }

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
    subjectTextFocusNode.removeListener(_onSubjectTextListener);
    subjectTextFocusNode.dispose();
    subjectTextController.dispose();
    richTextControllerForMobile.dispose();
    scrollController.dispose();
    super.onClose();
  }
}