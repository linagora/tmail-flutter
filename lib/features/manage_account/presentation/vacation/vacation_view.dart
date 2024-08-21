
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart' as html_editor_browser;
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:rich_text_composer/views/widgets/rich_text_keyboard_toolbar.dart';
import 'package:tmail_ui_user/features/base/widget/border_button_field.dart';
import 'package:tmail_ui_user/features/base/widget/text_input_field_builder.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/rich_text_button_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/button_layout_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/date_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_responder_status.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/utils/vacation_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class VacationView extends GetWidget<VacationController> with RichTextButtonMixin {

  VacationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget vacationInputForm = SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      controller: controller.scrollController,
      child: Padding(
        padding: VacationUtils.getPaddingView(context, controller.responsiveUtils),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.responsiveUtils.isWebDesktop(context))
              ...[
                Text(
                  AppLocalizations.of(context).vacation,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                  )
                ),
                const SizedBox(height: 8)
              ],
            Text(
              AppLocalizations.of(context).vacationSettingExplanation,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: AppColor.colorVacationSettingExplanation
              )
            ),
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
                      ? controller.imagePaths.icSwitchOff
                      : controller.imagePaths.icSwitchOn,
                    fit: BoxFit.fill,
                    width: 24,
                    height: 24
                  )
                );
              }),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).vacationSettingToggleButtonAutoReply,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black
                  )
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
                    child: controller.responsiveUtils.isPortraitMobile(context)
                      ? Column(children: [
                          BorderButtonField<DateTime>(
                            label: AppLocalizations.of(context).startDate,
                            value: controller.vacationPresentation.value.startDate,
                            mouseCursor: SystemMouseCursors.text,
                            backgroundColor: AppColor.colorBackgroundVacationSettingField,
                            isEmpty: !controller.isVacationDeactivated && controller.vacationPresentation.value.startDateIsNull,
                            hintText: AppLocalizations.of(context).startDate,
                            tapActionCallback: (value) => controller.selectDate(context, DateType.start, value)
                          ),
                          const SizedBox(height: 18),
                          BorderButtonField<TimeOfDay>(
                            label: AppLocalizations.of(context).startTime,
                            value: controller.vacationPresentation.value.startTime,
                            mouseCursor: SystemMouseCursors.text,
                            backgroundColor: AppColor.colorBackgroundVacationSettingField,
                            isEmpty: !controller.isVacationDeactivated && controller.vacationPresentation.value.starTimeIsNull,
                            hintText: AppLocalizations.of(context).noStartTime,
                            tapActionCallback: (value) => controller.selectTime(context, DateType.start, value)
                          ),
                        ])
                      : Row(children: [
                          Expanded(child: BorderButtonField<DateTime>(
                            label: AppLocalizations.of(context).startDate,
                            value: controller.vacationPresentation.value.startDate,
                            mouseCursor: SystemMouseCursors.text,
                            backgroundColor: AppColor.colorBackgroundVacationSettingField,
                            isEmpty: !controller.isVacationDeactivated && controller.vacationPresentation.value.startDateIsNull,
                            hintText: AppLocalizations.of(context).startDate,
                            tapActionCallback: (value) => controller.selectDate(context, DateType.start, value))
                          ),
                          const SizedBox(width: 24),
                          Expanded(child: BorderButtonField<TimeOfDay>(
                            label: AppLocalizations.of(context).startTime,
                            value: controller.vacationPresentation.value.startTime,
                            mouseCursor: SystemMouseCursors.text,
                            backgroundColor: AppColor.colorBackgroundVacationSettingField,
                            isEmpty: !controller.isVacationDeactivated && controller.vacationPresentation.value.starTimeIsNull,
                            hintText: AppLocalizations.of(context).noStartTime,
                            tapActionCallback: (value) => controller.selectTime(context, DateType.start, value))
                          ),
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
                            ? controller.imagePaths.icSwitchOn
                            : controller.imagePaths.icSwitchOff,
                          fit: BoxFit.fill,
                          width: 24,
                          height: 24
                        )
                      )),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).vacationStopsAt,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.black
                          )
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
                    child: controller.responsiveUtils.isPortraitMobile(context)
                      ? Column(children: [
                          BorderButtonField<DateTime>(
                            label: AppLocalizations.of(context).endDate,
                            value: controller.vacationPresentation.value.endDate,
                            mouseCursor: SystemMouseCursors.text,
                            backgroundColor: AppColor.colorBackgroundVacationSettingField,
                            isEmpty: controller.canChangeEndDate && controller.vacationPresentation.value.endDateIsNull,
                            hintText: AppLocalizations.of(context).noEndDate,
                            tapActionCallback: (value) => controller.selectDate(context, DateType.end, value)
                          ),
                          const SizedBox(height: 18),
                          BorderButtonField<TimeOfDay>(
                            label: AppLocalizations.of(context).endTime,
                            value: controller.vacationPresentation.value.endTime,
                            mouseCursor: SystemMouseCursors.text,
                            backgroundColor: AppColor.colorBackgroundVacationSettingField,
                            isEmpty: controller.canChangeEndDate && controller.vacationPresentation.value.endTimeIsNull,
                            hintText: AppLocalizations.of(context).noEndTime,
                            tapActionCallback: (value) => controller.selectTime(context, DateType.end, value)
                          ),
                        ])
                      : Row(children: [
                          Expanded(child: BorderButtonField<DateTime>(
                            label: AppLocalizations.of(context).endDate,
                            value: controller.vacationPresentation.value.endDate,
                            mouseCursor: SystemMouseCursors.text,
                            backgroundColor: AppColor.colorBackgroundVacationSettingField,
                            isEmpty: controller.canChangeEndDate && controller.vacationPresentation.value.endDateIsNull,
                            hintText: AppLocalizations.of(context).noEndDate,
                            tapActionCallback: (value) => controller.selectDate(context, DateType.end, value))
                          ),
                          const SizedBox(width: 24),
                          Expanded(child: BorderButtonField<TimeOfDay>(
                            label: AppLocalizations.of(context).endTime,
                            value: controller.vacationPresentation.value.endTime,
                            mouseCursor: SystemMouseCursors.text,
                            backgroundColor: AppColor.colorBackgroundVacationSettingField,
                            isEmpty: controller.canChangeEndDate && controller.vacationPresentation.value.endTimeIsNull,
                            hintText: AppLocalizations.of(context).noEndTime,
                            tapActionCallback: (value) => controller.selectTime(context, DateType.end, value))
                          ),
                        ]),
                  )
                )),
                const SizedBox(height: 24),
                Obx(() => AbsorbPointer(
                  absorbing: controller.isVacationDeactivated,
                  child: controller.responsiveUtils.isPortraitMobile(context)
                    ? Opacity(
                        opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                        child: TextInputFieldBuilder(
                          label: AppLocalizations.of(context).subject,
                          hint: AppLocalizations.of(context).hintSubjectInputVacationSetting,
                          editingController: controller.subjectTextController,
                          focusNode: controller.subjectTextFocusNode,
                        ),
                      )
                    : Row(children: [
                        Expanded(child: Opacity(
                          opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                          child: TextInputFieldBuilder(
                            label: AppLocalizations.of(context).subject,
                            hint: AppLocalizations.of(context).hintSubjectInputVacationSetting,
                            editingController: controller.subjectTextController,
                            focusNode: controller.subjectTextFocusNode,
                          ),
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
                _buildListButtonAction(context),
                const SizedBox(height: 24),
              ]),
            )
          ]
        ),
      ),
    );

    if (PlatformInfo.isWeb) {
      return SettingDetailViewBuilder(
        responsiveUtils: controller.responsiveUtils,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: vacationInputForm,
      );
    } else {
      return ResponsiveWidget(
        responsiveUtils: controller.responsiveUtils,
        mobile: GestureDetector(
          onTap: () => controller.clearFocusEditor(context),
          child: Scaffold(
            backgroundColor: SettingsUtils.getBackgroundColor(context, controller.responsiveUtils),
            body: SafeArea(
              left: controller.responsiveUtils.isPortraitMobile(context),
              top: false,
              right: controller.responsiveUtils.isPortraitMobile(context),
              child: KeyboardRichText(
                richTextController: controller.richTextControllerForMobile,
                keyBroadToolbar: RichTextKeyboardToolBar(
                  rootContext: context,
                  titleBack: AppLocalizations.of(context).format,
                  backgroundKeyboardToolBarColor: PlatformInfo.isIOS
                    ? AppColor.colorBackgroundKeyboard
                    : AppColor.colorBackgroundKeyboardAndroid,
                  formatLabel: AppLocalizations.of(context).format,
                  richTextController: controller.richTextControllerForMobile,
                  quickStyleLabel: AppLocalizations.of(context).quickStyles,
                  backgroundLabel: AppLocalizations.of(context).background,
                  foregroundLabel: AppLocalizations.of(context).foreground,
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: vacationInputForm),
                )
              ),
            ),
          ),
        ),
        tablet: Portal(
          child: GestureDetector(
            onTap: () => controller.clearFocusEditor(context),
            child: Scaffold(
              backgroundColor: SettingsUtils.getBackgroundColor(context, controller.responsiveUtils),
              body: SafeArea(
                child: KeyboardRichText(
                  richTextController: controller.richTextControllerForMobile,
                  keyBroadToolbar: RichTextKeyboardToolBar(
                    rootContext: context,
                    titleBack: AppLocalizations.of(context).format,
                    backgroundKeyboardToolBarColor: PlatformInfo.isIOS
                      ? AppColor.colorBackgroundKeyboard
                      : AppColor.colorBackgroundKeyboardAndroid,
                    formatLabel: AppLocalizations.of(context).format,
                    richTextController: controller.richTextControllerForMobile,
                    quickStyleLabel: AppLocalizations.of(context).quickStyles,
                    backgroundLabel: AppLocalizations.of(context).background,
                    foregroundLabel: AppLocalizations.of(context).foreground,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: vacationInputForm,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildListButtonAction(BuildContext context) {
    if (controller.responsiveUtils.isWebDesktop(context)) {
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
      if (controller.responsiveUtils.isPortraitMobile(context)) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).message,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: AppColor.colorContentEmail
          )
        ),
        const SizedBox(height: 8),
        _buildMessageTextEditor(context)
      ]
    );
  }

  Widget _buildMessageTextEditor(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.colorInputBorderCreateMailbox),
        color: Colors.white),
      padding: const EdgeInsetsDirectional.only(start: 12, end: 12, top: 12),
      child: Column(children: [
        _buildMessageHtmlTextEditor(context),
        if (PlatformInfo.isWeb)
          Center(
            child: PointerInterceptor(
              child: buildToolbarRichTextForWeb(
                context,
                controller.richTextControllerForWeb,
                layoutType: ButtonLayoutType.scrollHorizontal
              )
            )
          )
      ]),
    );
  }

  Widget _buildMessageHtmlTextEditor(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: html_editor_browser.HtmlEditor(
          key: const Key('vacation_message_html_text_editor_web'),
          controller: controller.richTextControllerForWeb.editorController,
          htmlEditorOptions: html_editor_browser.HtmlEditorOptions(
            hint: '',
            darkMode: false,
            initialText: controller.vacationMessageHtmlText,
            spellCheck: true,
            customBodyCssStyle: HtmlUtils.customCssStyleHtmlEditor(direction: AppUtils.getCurrentDirection(context))
          ),
          htmlToolbarOptions: const html_editor_browser.HtmlToolbarOptions(
              toolbarType: html_editor_browser.ToolbarType.hide,
              defaultToolbarButtons: []),
          otherOptions: const html_editor_browser.OtherOptions(height: 150),
          callbacks: html_editor_browser.Callbacks(
            onChangeSelection: controller.richTextControllerForWeb.onEditorSettingsChange,
            onChangeContent: controller.updateMessageHtmlText,
            onFocus: () {
              KeyboardUtils.hideKeyboard(context);
              Future.delayed(const Duration(milliseconds: 500), () {
                controller.richTextControllerForWeb.editorController.setFocus();
              });
              controller.richTextControllerForWeb.closeAllMenuPopup();
            }
          ),
        ),
      );
    } else {
      return HtmlEditor(
          key: controller.htmlKey,
          minHeight: controller.htmlEditorMinHeight,
          addDefaultSelectionMenuItems: false,
          initialContent: controller.vacationMessageHtmlText ?? '',
          customStyleCss: HtmlUtils.customCssStyleHtmlEditor(direction: AppUtils.getCurrentDirection(context)),
          onCreated: (editorApi) => controller.initRichTextForMobile(context, editorApi)
      );
    }
  }
}