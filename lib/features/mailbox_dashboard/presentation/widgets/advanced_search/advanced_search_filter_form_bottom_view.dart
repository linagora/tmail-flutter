import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/checkbox/custom_icon_labeled_checkbox.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxHasAttachment(
          context,
          focusManager.attachmentCheckboxFocusNode,
        ),
        _buildListButton(context),
      ],
    );
  }

  Widget _buildListButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(minWidth: 92),
            height: 48,
            child: ConfirmDialogButton(
              label: AppLocalizations.of(context).clearFilter,
              onTapAction: _onClickCancelButton,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.tab) {
                focusManager.fromFieldFocusNode.requestFocus();
              }
            },
            child: Container(
              constraints: const BoxConstraints(minWidth: 112),
              height: 48,
              child: ConfirmDialogButton(
                label: AppLocalizations.of(context).search,
                backgroundColor: AppColor.primaryMain,
                textColor: Colors.white,
                onTapAction: _onClickSearchButton,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxHasAttachment(
      BuildContext context,
      FocusNode currentFocusNode,
  ) {
    return Obx(
      () => CustomIconLabeledCheckbox(
        label: AppLocalizations.of(context).hasAttachment,
        svgIconPath: controller.imagePaths.icCheckboxUnselected,
        selectedSvgIconPath: controller.imagePaths.icCheckboxSelected,
        focusNode: currentFocusNode,
        value: controller.hasAttachment.value,
        onChanged: controller.onHasAttachmentCheckboxChanged,
      ),
    );
  }

  void _onClickCancelButton() {
    controller.clearSearchFilter();
    popBack();
  }

  void _onClickSearchButton() {
    controller.applyAdvancedSearchFilter();
    popBack();
  }
}
