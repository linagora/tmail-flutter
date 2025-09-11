
import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart' as html_editor_browser;
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:rich_text_composer/views/widgets/rich_text_keyboard_toolbar.dart';
import 'package:tmail_ui_user/features/base/widget/dialog_picker/color_dialog_picker.dart';
import 'package:tmail_ui_user/features/base/widget/dialog_picker/date_time_dialog_picker.dart';
import 'package:tmail_ui_user/features/base/widget/label_border_button_field.dart';
import 'package:tmail_ui_user/features/base/widget/switch_label_button_widget.dart';
import 'package:tmail_ui_user/features/base/widget/label_input_field_builder.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/toolbar_rich_text_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/date_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_responder_status.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_list_action_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_explanation_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_header_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class VacationView extends GetWidget<VacationController> {

  const VacationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vacationInputForm = SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      controller: controller.scrollController,
      child: Padding(
        padding: _getScrollViewPadding(
          context,
          controller.responsiveUtils,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final isVacationDeactivated = controller.isVacationDeactivated;

              return SwitchLabelButtonWidget(
                imagePaths: controller.imagePaths,
                label: AppLocalizations.of(context).vacationSettingToggleButtonAutoReply,
                isActive: !isVacationDeactivated,
                padding: const EdgeInsets.only(top: 10),
                onSwitchAction: () {
                  final newStatus = isVacationDeactivated
                      ? VacationResponderStatus.activated
                      : VacationResponderStatus.deactivated;
                  controller.updateVacationPresentation(newStatus: newStatus);
                },
              );
            }),
            SizedBox(
              height: controller.responsiveUtils.isScreenWithShortestSide(context)
                ? 24
                : 12,
            ),
            Obx(() => AbsorbPointer(
              absorbing: controller.isVacationDeactivated,
              child: Opacity(
                opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LabelBorderButtonField<DateTime>(
                      label: AppLocalizations.of(context).startDate,
                      value: controller.vacationPresentation.value.startDate,
                      isEmpty: !controller.isVacationDeactivated &&
                          controller.vacationPresentation.value.startDateIsNull,
                      hintText: 'dd/mm/yyyy',
                      arrangeHorizontally: !controller.responsiveUtils.isScreenWithShortestSide(context),
                      minWidth: controller.responsiveUtils.isScreenWithShortestSide(context) ? 117 : null,
                      onSelectValueAction: (value) => controller.selectDate(
                        context,
                        DateType.start,
                        value,
                      ),
                    ),
                    const SizedBox(width: 32),
                    LabelBorderButtonField<TimeOfDay>(
                      label: AppLocalizations.of(context).startTime,
                      value: controller.vacationPresentation.value.startTime,
                      isEmpty: !controller.isVacationDeactivated &&
                          controller.vacationPresentation.value.starTimeIsNull,
                      hintText: 'hh:min AM/PM',
                      horizontalSpacing: 8,
                      arrangeHorizontally: !controller.responsiveUtils.isScreenWithShortestSide(context),
                      minWidth: controller.responsiveUtils.isScreenWithShortestSide(context) ? 117 : null,
                      onSelectValueAction: (value) => controller.selectTime(
                        context,
                        DateType.start,
                        value,
                      ),
                    ),
                  ],
                ),
              ),
            )),
            SizedBox(
              height: controller.responsiveUtils.isScreenWithShortestSide(context)
                  ? 24
                  : 37,
            ),
            Obx(
              () => AbsorbPointer(
                absorbing: controller.isVacationDeactivated,
                child: Opacity(
                  opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                  child: Obx(() {
                    final vacationStopEnabled = controller
                        .vacationPresentation.value.vacationStopEnabled;

                    return SwitchLabelButtonWidget(
                      imagePaths: controller.imagePaths,
                      label: AppLocalizations.of(context).vacationStopsAt,
                      isActive: vacationStopEnabled,
                      onSwitchAction: () {
                        controller.updateVacationPresentation(
                          vacationStopEnabled: !vacationStopEnabled,
                        );
                      },
                    );
                  }),
                ),
              ),
            ),
            SizedBox(
              height: controller.responsiveUtils.isScreenWithShortestSide(context)
                ? 24
                : 12,
            ),
            Obx(() => AbsorbPointer(
              absorbing: !controller.canChangeEndDate,
              child: Opacity(
                opacity: !controller.canChangeEndDate ? 0.3 : 1.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LabelBorderButtonField<DateTime>(
                      label: AppLocalizations.of(context).endDate,
                      value: controller.vacationPresentation.value.endDate,
                      isEmpty: controller.canChangeEndDate && controller.vacationPresentation.value.endDateIsNull,
                      hintText: 'dd/mm/yyyy',
                      arrangeHorizontally: !controller.responsiveUtils.isScreenWithShortestSide(context),
                      minWidth: controller.responsiveUtils.isScreenWithShortestSide(context) ? 117 : null,
                      onSelectValueAction: (value) => controller.selectDate(
                        context,
                        DateType.end,
                        value,
                      ),
                    ),
                    const SizedBox(width: 32),
                    LabelBorderButtonField<TimeOfDay>(
                      label: AppLocalizations.of(context).endTime,
                      value: controller.vacationPresentation.value.endTime,
                      isEmpty: controller.canChangeEndDate &&
                          controller.vacationPresentation.value.endTimeIsNull,
                      hintText: 'hh:min AM/PM',
                      horizontalSpacing: 8,
                      arrangeHorizontally: !controller.responsiveUtils.isScreenWithShortestSide(context),
                      minWidth: controller.responsiveUtils.isScreenWithShortestSide(context) ? 117 : null,
                      onSelectValueAction: (value) => controller.selectTime(
                        context,
                        DateType.end,
                        value,
                      ),
                    ),
                  ],
                ),
              )
            )),
            SizedBox(
              height: controller.responsiveUtils.isScreenWithShortestSide(context)
                ? 24
                : 12,
            ),
            Obx(() => AbsorbPointer(
              absorbing: controller.isVacationDeactivated,
              child: controller.responsiveUtils.isScreenWithShortestSide(context)
                ? Opacity(
                    opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                    child: LabelInputFieldBuilder(
                      label: AppLocalizations.of(context).subject,
                      hintText: AppLocalizations.of(context).hintSubjectInputVacationSetting,
                      textEditingController: controller.subjectTextController,
                      focusNode: controller.subjectTextFocusNode,
                      arrangeHorizontally: false,
                    ),
                  )
                : Opacity(
                    opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                    child: LabelInputFieldBuilder(
                      label: AppLocalizations.of(context).subject,
                      hintText: AppLocalizations.of(context).hintSubjectInputVacationSetting,
                      textEditingController: controller.subjectTextController,
                      focusNode: controller.subjectTextFocusNode,
                    ),
                  ),
            )),
            SizedBox(
              height: controller.responsiveUtils.isScreenWithShortestSide(context)
                ? 24
                : 12,
            ),
            Obx(() => AbsorbPointer(
              absorbing: controller.isVacationDeactivated,
              child: Opacity(
                opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                child: _buildVacationMessage(context),
              ),
            )),
            Container(
              padding: EdgeInsets.only(
                top: controller.responsiveUtils.isScreenWithShortestSide(context)
                    ? 24
                    : 22,
                bottom: controller.responsiveUtils.isScreenWithShortestSide(context)
                    ? PlatformInfo.isMobile
                        ? 64
                        : 24
                    : 0,
              ),
              constraints: const BoxConstraints(maxWidth: 660),
              child: VacationListActionWidget(
                onCancelButtonAction: () {
                  if (controller.responsiveUtils.isWebDesktop(context)) {
                    controller.switchProfileSetting();
                  } else {
                    controller.backToUniversalSettings(context);
                  }
                },
                onConfirmButtonAction: () => controller.saveVacation(context),
              ),
            ),
          ]
        ),
      ),
    );

    final vacationView = SettingDetailViewBuilder(
      responsiveUtils: controller.responsiveUtils,
      child: Container(
        color: SettingsUtils.getContentBackgroundColor(
          context,
          controller.responsiveUtils,
        ),
        decoration: SettingsUtils.getBoxDecorationForContent(
          context,
          controller.responsiveUtils,
        ),
        width: double.infinity,
        padding: controller.responsiveUtils.isDesktop(context)
            ? const EdgeInsetsDirectional.only(
          top: 30,
          start: 22,
        )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.responsiveUtils.isWebDesktop(context))
              SettingHeaderWidget(
                menuItem: AccountMenuItem.vacation,
                textStyle: ThemeUtils.textStyleInter600().copyWith(
                  color: Colors.black.withValues(alpha: 0.9),
                ),
                padding: const EdgeInsetsDirectional.only(bottom: 16, end: 22),
              )
            else
              const SettingExplanationWidget(
                menuItem: AccountMenuItem.vacation,
                padding: EdgeInsetsDirectional.only(
                  start: 16,
                  end: 16,
                  bottom: 16,
                ),
                isCenter: true,
              ),
            Expanded(child: vacationInputForm),
          ],
        ),
      ),
    );

    if (PlatformInfo.isWeb) {
      return vacationView;
    } else {
      return ResponsiveWidget(
        responsiveUtils: controller.responsiveUtils,
        mobile: GestureDetector(
          onTap: () => controller.clearFocusEditor(context),
          child: Scaffold(
            backgroundColor: SettingsUtils.getBackgroundColor(context, controller.responsiveUtils),
            body: SafeArea(
              left: controller.responsiveUtils.isScreenWithShortestSide(context),
              top: false,
              right: controller.responsiveUtils.isScreenWithShortestSide(context),
              child: KeyboardRichText(
                richTextController: controller.richTextControllerForMobile!,
                keyBroadToolbar: RichTextKeyboardToolBar(
                  rootContext: context,
                  titleBack: AppLocalizations.of(context).format,
                  backgroundKeyboardToolBarColor: PlatformInfo.isIOS
                    ? AppColor.colorBackgroundKeyboard
                    : AppColor.colorBackgroundKeyboardAndroid,
                  formatLabel: AppLocalizations.of(context).format,
                  richTextController: controller.richTextControllerForMobile!,
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
                    child: vacationView,
                  ),
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
                  richTextController: controller.richTextControllerForMobile!,
                  keyBroadToolbar: RichTextKeyboardToolBar(
                    rootContext: context,
                    titleBack: AppLocalizations.of(context).format,
                    backgroundKeyboardToolBarColor: PlatformInfo.isIOS
                      ? AppColor.colorBackgroundKeyboard
                      : AppColor.colorBackgroundKeyboardAndroid,
                    formatLabel: AppLocalizations.of(context).format,
                    richTextController: controller.richTextControllerForMobile!,
                    quickStyleLabel: AppLocalizations.of(context).quickStyles,
                    backgroundLabel: AppLocalizations.of(context).background,
                    foregroundLabel: AppLocalizations.of(context).foreground,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: vacationView,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildVacationMessage(BuildContext context) {
    Widget overlayWidget = Obx(() {
      bool isOverlayEnabled = DateTimeDialogPicker().isOpened.isTrue ||
          ColorDialogPicker().isOpened.isTrue;

      if (isOverlayEnabled) {
        return Positioned.fill(
          child: PointerInterceptor(
            child: const SizedBox.expand(),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });

    if (controller.responsiveUtils.isScreenWithShortestSide(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppLocalizations.of(context).message}:',
            style: ThemeUtils.textStyleBodyBody3(color: Colors.black),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: AppColor.m3Neutral90),
            ),
            padding: const EdgeInsetsDirectional.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            height: PlatformInfo.isMobile ? null : 236,
            child: PlatformInfo.isMobile
              ? _buildMessageHtmlTextEditor(context)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Stack(
                        children: [
                          _buildMessageHtmlTextEditor(context),
                          overlayWidget,
                        ],
                      ),
                    ),
                    ToolbarRichTextWidget(
                      richTextController: controller.richTextControllerForWeb!,
                      scrollListController: controller.richTextButtonScrollController,
                      imagePaths: controller.imagePaths,
                      isHorizontalArrange: true,
                      isMobile: controller.responsiveUtils.isMobile(context),
                    ),
                  ],
                ),
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 83),
            child: Text(
              '${AppLocalizations.of(context).message}:',
              style: ThemeUtils.textStyleBodyBody3(color: Colors.black),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: AppColor.m3Neutral90),
              ),
              constraints: const BoxConstraints(maxWidth: 565),
              height: PlatformInfo.isMobile ? null : 236,
              padding: EdgeInsetsDirectional.only(
                bottom: PlatformInfo.isMobile ? 8 : 0,
                start: 12,
                end: 12,
              ),
              child: PlatformInfo.isMobile
                ? _buildMessageHtmlTextEditor(context)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Stack(
                          children: [
                            _buildMessageHtmlTextEditor(context),
                            overlayWidget,
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ToolbarRichTextWidget(
                        richTextController: controller.richTextControllerForWeb!,
                        scrollListController: controller.richTextButtonScrollController,
                        imagePaths: controller.imagePaths,
                        isHorizontalArrange: true,
                        isMobile: controller.responsiveUtils.isMobile(context),
                      ),
                    ],
                  ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildMessageHtmlTextEditor(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return html_editor_browser.HtmlEditor(
        key: const Key('vacation_message_html_text_editor_web'),
        controller: controller.richTextControllerForWeb!.editorController,
        htmlEditorOptions: html_editor_browser.HtmlEditorOptions(
          hint: '',
          darkMode: false,
          cacheHTMLAssetOffline: true,
          initialText: controller.vacationMessageHtmlText,
          spellCheck: true,
          normalizeHtmlTextWhenDropping: true,
          normalizeHtmlTextWhenPasting: true,
          customBodyCssStyle: HtmlUtils.customInlineBodyCssStyleHtmlEditor(
            direction: AppUtils.getCurrentDirection(context),
            horizontalPadding: 0,
          ),
          customInternalCSS: HtmlTemplate.webCustomInternalStyleCSS(),
        ),
        htmlToolbarOptions: const html_editor_browser.HtmlToolbarOptions(
          toolbarType: html_editor_browser.ToolbarType.hide,
          defaultToolbarButtons: [],
        ),
        otherOptions: const html_editor_browser.OtherOptions(height: 300),
        callbacks: html_editor_browser.Callbacks(
          onChangeSelection:
              controller.richTextControllerForWeb?.onEditorSettingsChange,
          onChangeContent: controller.updateMessageHtmlText,
          onFocus: () {
            KeyboardUtils.hideKeyboard(context);
            Future.delayed(const Duration(milliseconds: 500), () {
              controller.richTextControllerForWeb?.editorController.setFocus();
            });
            controller.richTextControllerForWeb?.closeAllMenuPopup();
          },
        ),
      );
    } else {
      return HtmlEditor(
          key: controller.htmlKey,
          minHeight: ConstantsUI.htmlContentMinHeight.toInt(),
          maxHeight: PlatformInfo.isIOS ? ConstantsUI.composerHtmlContentMaxHeight : null,
          addDefaultSelectionMenuItems: false,
          initialContent: controller.vacationMessageHtmlText ?? '',
          customStyleCss: HtmlTemplate.mobileCustomInternalStyleCSS(direction: AppUtils.getCurrentDirection(context)),
          onCreated: (editorApi) => controller.initRichTextForMobile(context, editorApi)
      );
    }
  }

  EdgeInsetsGeometry _getScrollViewPadding(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsetsDirectional.only(end: 22, bottom: 30);
    } else if (responsiveUtils.isMobile(context)) {
      return const EdgeInsetsDirectional.symmetric(horizontal: 16);
    } else {
      return const EdgeInsetsDirectional.symmetric(horizontal: 32);
    }
  }
}