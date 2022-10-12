
import 'package:core/core.dart';
import 'package:enough_html_editor/enough_html_editor.dart' as html_editor_mobile;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:rich_text_composer/views/widgets/rich_text_keyboard_toolbar.dart';
import 'package:tmail_ui_user/features/base/widget/border_button_field.dart';
import 'package:tmail_ui_user/features/base/widget/text_input_decoration_builder.dart';
import 'package:tmail_ui_user/features/base/widget/text_input_field_builder.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/rich_text_button_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/button_layout_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/date_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_message_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_responder_status.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:html_editor_enhanced/html_editor.dart' as html_editor_browser;

class VacationView extends GetWidget<VacationController> with RichTextButtonMixin {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  VacationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _responsiveUtils.isWebDesktop(context)
          ? AppColor.colorBgDesktop
          : Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: KeyboardRichText(
          richTextController: controller.richTextControllerForMobile,
          keyBroadToolbar: RichTextKeyboardToolBar(
            titleBack: AppLocalizations.of(context).format,
            backgroundKeyboardToolBarColor: AppColor.colorBackgroundKeyboard,
            titleFormatBottomSheet: AppLocalizations.of(context).format,
            richTextController: controller.richTextControllerForMobile,
            titleQuickStyleBottomSheet: AppLocalizations.of(context).quickStyles,
            titleBackgroundBottomSheet: AppLocalizations.of(context).background,
            titleForegroundBottomSheet: AppLocalizations.of(context).foreground,
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            margin: _responsiveUtils.isWebDesktop(context)
                ? const EdgeInsets.all(24)
                : EdgeInsets.zero,
            decoration: _responsiveUtils.isWebDesktop(context)
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColor.colorBorderBodyThread, width: 1),
                    color: Colors.white)
                : null,
            padding: SettingsUtils.getMarginViewForSettingDetails(context, _responsiveUtils),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              controller: controller.scrollController,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_responsiveUtils.isWebDesktop(context))
                     ...[
                       Text(AppLocalizations.of(context).vacation,
                           style: const TextStyle(
                               fontSize: 20,
                               fontWeight: FontWeight.w500,
                               color: Colors.black)),
                       const SizedBox(height: 8)
                     ],
                    Text(AppLocalizations.of(context).vacationSettingExplanation,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: AppColor.colorVacationSettingExplanation)),
                    const SizedBox(height: 24),
                    Row(children: [
                      Obx(() {
                        return InkWell(
                            onTap: () {
                              final newStatus = controller.isVacationDeactivated
                                  ? VacationResponderStatus.activated
                                  : VacationResponderStatus.deactivated;
                              controller.updateVacationPresentation(newStatus: newStatus);
                            },
                            child: SvgPicture.asset(
                                controller.isVacationDeactivated
                                    ? _imagePaths.icSwitchOff
                                    : _imagePaths.icSwitchOn,
                                fit: BoxFit.fill,
                                width: 24,
                                height: 24)
                        );
                      }),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(AppLocalizations.of(context).vacationSettingToggleButtonAutoReply,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black)
                        ),
                      )
                    ]),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: Column(children: [
                        Obx(() => AbsorbPointer(
                          absorbing: controller.isVacationDeactivated,
                          child: Opacity(
                            opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                            child: _responsiveUtils.isPortraitMobile(context)
                              ? Column(children: [
                                  BorderButtonField<DateTime>(
                                      label: AppLocalizations.of(context).startDate,
                                      value: controller.vacationPresentation.value.startDate,
                                      mouseCursor: SystemMouseCursors.text,
                                      backgroundColor: AppColor.colorBackgroundVacationSettingField,
                                      isEmpty: !controller.isVacationDeactivated &&
                                          controller.vacationPresentation.value.startDateIsNull,
                                      hintText: AppLocalizations.of(context).startDate,
                                      tapActionCallback: (value) =>
                                          controller.selectDate(context, DateType.start, value)),
                                  const SizedBox(height: 18),
                                  BorderButtonField<TimeOfDay>(
                                      label: AppLocalizations.of(context).startTime,
                                      value: controller.vacationPresentation.value.startTime,
                                      mouseCursor: SystemMouseCursors.text,
                                      backgroundColor: AppColor.colorBackgroundVacationSettingField,
                                      isEmpty: !controller.isVacationDeactivated &&
                                          controller.vacationPresentation.value.starTimeIsNull,
                                      hintText: AppLocalizations.of(context).noStartTime,
                                      tapActionCallback: (value) =>
                                          controller.selectTime(context, DateType.start, value)),
                                ])
                            : Row(children: [
                                Expanded(child: BorderButtonField<DateTime>(
                                    label: AppLocalizations.of(context).startDate,
                                    value: controller.vacationPresentation.value.startDate,
                                    mouseCursor: SystemMouseCursors.text,
                                    backgroundColor: AppColor.colorBackgroundVacationSettingField,
                                    isEmpty: !controller.isVacationDeactivated &&
                                        controller.vacationPresentation.value.startDateIsNull,
                                    hintText: AppLocalizations.of(context).startDate,
                                    tapActionCallback: (value) =>
                                        controller.selectDate(context, DateType.start, value))),
                                const SizedBox(width: 24),
                                Expanded(child: BorderButtonField<TimeOfDay>(
                                    label: AppLocalizations.of(context).startTime,
                                    value: controller.vacationPresentation.value.startTime,
                                    mouseCursor: SystemMouseCursors.text,
                                    backgroundColor: AppColor.colorBackgroundVacationSettingField,
                                    isEmpty: !controller.isVacationDeactivated &&
                                        controller.vacationPresentation.value.starTimeIsNull,
                                    hintText: AppLocalizations.of(context).noStartTime,
                                    tapActionCallback: (value) =>
                                        controller.selectTime(context, DateType.start, value))),
                              ]),
                          ),
                        )),
                        const SizedBox(height: 24),
                        Obx(() => AbsorbPointer(
                            absorbing: controller.isVacationDeactivated,
                            child: Opacity(
                              opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                              child: Row(children: [
                                Obx(() => InkWell(
                                    onTap: () {
                                      final value = !controller.vacationPresentation.value.vacationStopEnabled;
                                      controller.updateVacationPresentation(vacationStopEnabled: value);
                                    },
                                    child: SvgPicture.asset(
                                        controller.vacationPresentation.value.vacationStopEnabled
                                            ? _imagePaths.icSwitchOn
                                            : _imagePaths.icSwitchOff,
                                        fit: BoxFit.fill,
                                        width: 24,
                                        height: 24)
                                )
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(AppLocalizations.of(context).vacationStopsAt,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black)
                                  ),
                                )
                              ]),
                            )
                        )),
                        const SizedBox(height: 24),
                        Obx(() => AbsorbPointer(
                            absorbing: !controller.canChangeEndDate,
                            child: Opacity(
                              opacity: !controller.canChangeEndDate ? 0.3 : 1.0,
                              child: _responsiveUtils.isPortraitMobile(context)
                                ? Column(children: [
                                    BorderButtonField<DateTime>(
                                        label: AppLocalizations.of(context).endDate,
                                        value: controller.vacationPresentation.value.endDate,
                                        mouseCursor: SystemMouseCursors.text,
                                        backgroundColor: AppColor.colorBackgroundVacationSettingField,
                                        isEmpty: controller.canChangeEndDate &&
                                            controller.vacationPresentation.value.endDateIsNull,
                                        hintText: AppLocalizations.of(context).noEndDate,
                                        tapActionCallback: (value) =>
                                            controller.selectDate(context, DateType.end, value)),
                                    const SizedBox(height: 18),
                                    BorderButtonField<TimeOfDay>(
                                        label: AppLocalizations.of(context).endTime,
                                        value: controller.vacationPresentation.value.endTime,
                                        mouseCursor: SystemMouseCursors.text,
                                        backgroundColor: AppColor.colorBackgroundVacationSettingField,
                                        isEmpty: controller.canChangeEndDate &&
                                            controller.vacationPresentation.value.endTimeIsNull,
                                        hintText: AppLocalizations.of(context).noEndTime,
                                        tapActionCallback: (value) =>
                                            controller.selectTime(context, DateType.end, value)),
                                  ])
                                : Row(children: [
                                    Expanded(child: BorderButtonField<DateTime>(
                                        label: AppLocalizations.of(context).endDate,
                                        value: controller.vacationPresentation.value.endDate,
                                        mouseCursor: SystemMouseCursors.text,
                                        backgroundColor: AppColor.colorBackgroundVacationSettingField,
                                        isEmpty: controller.canChangeEndDate &&
                                            controller.vacationPresentation.value.endDateIsNull,
                                        hintText: AppLocalizations.of(context).noEndDate,
                                        tapActionCallback: (value) =>
                                            controller.selectDate(context, DateType.end, value))),
                                    const SizedBox(width: 24),
                                    Expanded(child: BorderButtonField<TimeOfDay>(
                                        label: AppLocalizations.of(context).endTime,
                                        value: controller.vacationPresentation.value.endTime,
                                        mouseCursor: SystemMouseCursors.text,
                                        backgroundColor: AppColor.colorBackgroundVacationSettingField,
                                        isEmpty: controller.canChangeEndDate &&
                                            controller.vacationPresentation.value.endTimeIsNull,
                                        hintText: AppLocalizations.of(context).noEndTime,
                                        tapActionCallback: (value) =>
                                            controller.selectTime(context, DateType.end, value))),
                                  ]),
                            )
                        )),
                        const SizedBox(height: 24),
                        Obx(() => AbsorbPointer(
                            absorbing: controller.isVacationDeactivated,
                            child: _responsiveUtils.isPortraitMobile(context)
                                ? Opacity(
                                    opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                                    child: TextInputFieldBuilder(
                                    label: AppLocalizations.of(context).subject,
                                    hint: AppLocalizations.of(context).hintSubjectInputVacationSetting,
                                    editingController: controller.subjectTextController),
                                  )
                                : Row(children: [
                                    Expanded(child: Opacity(
                                      opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                                      child: TextInputFieldBuilder(
                                          label: AppLocalizations.of(context).subject,
                                          hint: AppLocalizations.of(context).hintSubjectInputVacationSetting,
                                          editingController: controller.subjectTextController),
                                    )),
                                    const SizedBox(width: 24),
                                    const Expanded(child: SizedBox.shrink())
                                  ])
                        )),
                        const SizedBox(height: 24),
                        Obx(() => AbsorbPointer(
                          absorbing: controller.isVacationDeactivated,
                          child: Opacity(
                            opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                            child: _buildVacationMessage(context),
                          ),
                        )),
                        const SizedBox(height: 24),
                        _buildListButtonAction(context)
                      ]),
                    )
                  ]
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListButtonAction(BuildContext context) {
    if (_responsiveUtils.isWebDesktop(context)) {
      return Align(
        alignment: Alignment.centerRight,
        child: buildTextButton(
            AppLocalizations.of(context).saveChanges,
            textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 16
            ),
            width: 156,
            height: 44,
            radius: 10,
            onTap: () => controller.saveVacation(context)),
      );
    } else {
      if (_responsiveUtils.isPortraitMobile(context)) {
        return Row(children: [
          Expanded(
            child: buildTextButton(
                AppLocalizations.of(context).cancel,
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                    color: AppColor.colorTextButton),
                backgroundColor: AppColor.emailAddressChipColor,
                width: 156,
                height: 44,
                radius: 10,
                onTap: () => controller.backToUniversalSettings(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: buildTextButton(
                AppLocalizations.of(context).saveChanges,
                textStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 16
                ),
                width: 156,
                height: 44,
                radius: 10,
                onTap: () => controller.saveVacation(context)),
          )
        ]);
      } else {
        return Row(children: [
          const Spacer(),
          buildTextButton(
              AppLocalizations.of(context).cancel,
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  color: AppColor.colorTextButton),
              backgroundColor: AppColor.emailAddressChipColor,
              width: 156,
              height: 44,
              radius: 10,
              onTap: () => controller.backToUniversalSettings(context)),
          const SizedBox(width: 12),
          buildTextButton(
              AppLocalizations.of(context).saveChanges,
              textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 16
              ),
              width: 156,
              height: 44,
              radius: 10,
              onTap: () => controller.saveVacation(context))
        ]);
      }
    }
  }

  Widget _buildVacationMessage(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(AppLocalizations.of(context).message,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColor.colorContentEmail))),
        _buildVacationMessageTypeButton(context, VacationMessageType.plainText),
        _buildVacationMessageTypeButton(context, VacationMessageType.htmlTemplate),
      ]),
      const SizedBox(height: 8),
      _buildMessageTextEditor(context)
    ]);
  }

  Widget _buildMessageTextEditor(BuildContext context) {
    return Obx(() {
      if (controller.vacationMessageType.value == VacationMessageType.plainText) {
        return _buildMessagePlainTextEditor(context);
      } else {
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.colorInputBorderCreateMailbox),
              color: Colors.white),
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
          child: Column(children: [
            _buildMessageHtmlTextEditor(context),
            if (BuildUtils.isWeb)
              Center(child: Obx(() {
                return PointerInterceptor(
                  child: buildToolbarRichTextForWeb(
                      context,
                      controller.richTextControllerForWeb,
                      layoutType: ButtonLayoutType.scrollHorizontal),
                );
              }))
          ]),
        );
      }
    });
  }

  Widget _buildMessagePlainTextEditor(BuildContext context) {
    return (TextFieldBuilder()
      ..onChange((value) => controller.updateMessageBody(context, value))
      ..textInputAction(TextInputAction.next)
      ..addController(controller.messageTextController)
      ..textStyle(const TextStyle(color: Colors.black, fontSize: 16))
      ..keyboardType(TextInputType.text)
      ..minLines(10)
      ..maxLines(null)
      ..textDecoration((TextInputDecorationBuilder()
        ..setContentPadding(const EdgeInsets.all(16))
        ..setHintText(AppLocalizations.of(context).hintMessageBodyVacation)
        ..setFillColor(Colors.white)
        ..setErrorText(controller.isVacationDeactivated
            ? null
            : controller.errorMessageBody.value))
        .build()))
      .build();
  }

  Widget _buildMessageHtmlTextEditor(BuildContext context) {
    if (BuildUtils.isWeb) {
      return html_editor_browser.HtmlEditor(
        key: const Key('vacation_message_html_text_editor_web'),
        controller: controller.richTextControllerForWeb.editorController,
        htmlEditorOptions: html_editor_browser.HtmlEditorOptions(
            hint: '',
            darkMode: false,
            customBodyCssStyle: bodyCssStyleForEditor),
        blockQuotedContent: controller.vacationMessageHtmlText ?? '',
        htmlToolbarOptions: const html_editor_browser.HtmlToolbarOptions(
            toolbarType: html_editor_browser.ToolbarType.hide,
            defaultToolbarButtons: []),
        otherOptions: const html_editor_browser.OtherOptions(height: 150),
        callbacks: html_editor_browser.Callbacks(
          onInit: () {
            controller.richTextControllerForWeb.setFullScreenEditor();
          }, onChangeSelection: (settings) {
            controller.richTextControllerForWeb.onEditorSettingsChange(settings);
          }, onChangeContent: (String? changed) {
            controller.updateMessageHtmlText(changed);
          }, onFocus: () {
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 500), () {
              controller.richTextControllerForWeb.editorController.setFocus();
            });
            controller.richTextControllerForWeb.closeAllMenuPopup();
          }
        ),
      );
    } else {
      return html_editor_mobile.HtmlEditor(
          key: controller.htmlKey,
          minHeight: controller.htmlEditorMinHeight,
          addDefaultSelectionMenuItems: false,
          initialContent: controller.vacationMessageHtmlText ?? '',
          onCreated: (htmlApi) {
            controller.richTextControllerForMobile.onCreateHTMLEditor(
              htmlApi,
              onFocus: controller.onFocusHTMLEditor,
              onEnterKeyDown: controller.onEnterKeyDown,
              context: context,
            );
          }
      );
    }
  }

  Widget _buildVacationMessageTypeButton(BuildContext context, VacationMessageType messageType) {
    return buildButtonWrapText(
        messageType.getTitle(context),
        textStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: controller.vacationMessageType.value == messageType
                ? AppColor.colorContentEmail
                : AppColor.colorHintSearchBar),
        bgColor: controller.vacationMessageType.value == messageType
            ? AppColor.emailAddressChipColor
            : Colors.transparent,
        height: 35,
        radius: 10,
        onTap: () => controller.selectVacationMessageType(context, messageType));
  }
}