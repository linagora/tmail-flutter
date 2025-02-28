import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/widgets/check_box_has_attachment_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/input_field_focus_manager.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class AdvancedSearchFilterFormBottomView extends GetWidget<AdvancedFilterController> {

  final InputFieldFocusManager focusManager;

  const AdvancedSearchFilterFormBottomView({
    Key? key,
    required this.focusManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: !controller.responsiveUtils.isWebDesktop(context) ? 8 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform(
            transform: Matrix4.translationValues(-8.0, 0.0, 0.0),
            child: _buildCheckboxHasAttachment(
              context,
              currentFocusNode: focusManager.attachmentCheckboxFocusNode,
              nextFocusNode: focusManager.searchButtonFocusNode),
          ),
          _buildListButton(context, controller.responsiveUtils),
        ],
      ),
    );
  }

  Widget _buildListButton(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (!responsiveUtils.isWebDesktop(context)) {
      return Row(children: [
        Expanded(
          child: _buildButton(
            onAction: () {
              controller.clearSearchFilter();
              popBack();
            },
            colorButton: Colors.white,
            colorText: AppColor.colorContentEmail,
            text: AppLocalizations.of(context).clearFilter,
            context: context,
            responsiveUtils: responsiveUtils,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildButton(
            onAction: () {
              controller.applyAdvancedSearchFilter();
              popBack();
            },
            colorButton: AppColor.primaryColor,
            colorText: AppColor.primaryLightColor,
            text: AppLocalizations.of(context).search,
            context: context,
            responsiveUtils: responsiveUtils,
            currentFocusNode: focusManager.searchButtonFocusNode,
            nextFocusNode: focusManager.fromFieldFocusNode
          ),
        ),
      ]);
    } else {
      return Row(children: [
        const Spacer(),
        _buildButton(
          onAction: () {
            controller.clearSearchFilter();
            popBack();
          },
          colorButton: Colors.transparent,
          colorText: AppColor.colorContentEmail,
          text: AppLocalizations.of(context).clearFilter,
          context: context,
          responsiveUtils: responsiveUtils,
          minWidth: 92
        ),
        const SizedBox(width: 12),
        _buildButton(
          onAction: () {
            controller.applyAdvancedSearchFilter();
            popBack();
          },
          colorButton: AppColor.primaryColor,
          colorText: AppColor.primaryLightColor,
          text: AppLocalizations.of(context).search,
          context: context,
          responsiveUtils: responsiveUtils,
          minWidth: 144,
          currentFocusNode: focusManager.searchButtonFocusNode,
          nextFocusNode: focusManager.fromFieldFocusNode
        ),
      ]);
    }
  }

  Widget _buildCheckboxHasAttachment(
      BuildContext context,
      {
        FocusNode? currentFocusNode,
        FocusNode? nextFocusNode,
      }
  ) {
    return Obx(() => CheckBoxHasAttachmentWidget(
      currentFocusNode: currentFocusNode,
      nextFocusNode: nextFocusNode,
      onChanged: controller.onHasAttachmentCheckboxChanged,
      hasAttachmentValue: controller.hasAttachment.value,
    ));
  }

  Widget _buildButton({
    required Color colorButton,
    required Color colorText,
    required String text,
    required VoidCallback onAction,
    required BuildContext context,
    required ResponsiveUtils responsiveUtils,
    FocusNode? currentFocusNode,
    FocusNode? nextFocusNode,
    double? minWidth,
  }) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.tab) {
          nextFocusNode?.requestFocus();
        }
      },
      child: buildButtonWrapText(
        text,
        focusNode: currentFocusNode,
        radius: 10,
        height: 44,
        minWidth: minWidth,
        textStyle: TextStyle(
          fontSize: 17,
          color: colorText,
          fontWeight: FontWeight.w500),
        bgColor: colorButton,
        onTap: onAction),
    );
  }
}
