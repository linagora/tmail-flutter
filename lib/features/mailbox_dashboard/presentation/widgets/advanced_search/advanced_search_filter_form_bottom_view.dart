import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/input_field_focus_manager.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class AdvancedSearchFilterFormBottomView extends GetWidget<AdvancedFilterController> {

  final InputFieldFocusManager? focusManager;

  const AdvancedSearchFilterFormBottomView({
    Key? key,
    this.focusManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _responsiveUtils = Get.find<ResponsiveUtils>();

    return Padding(
      padding: EdgeInsets.only(
          top: _isMobileAndLandscapeTablet(context, _responsiveUtils) ? 8 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isMobileAndLandscapeTablet(context, _responsiveUtils))
            ...[
              _buildCheckboxHasAttachment(
                  context,
                  currentFocusNode: focusManager?.attachmentCheckboxFocusNode,
                  nextFocusNode: focusManager?.searchButtonFocusNode),
              const SizedBox(height: 24)
            ],
          Row(
            mainAxisAlignment: _isMobileAndLandscapeTablet(context, _responsiveUtils)
                ? MainAxisAlignment.spaceEvenly
                : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!_isMobileAndLandscapeTablet(context, _responsiveUtils))
                Expanded(child: _buildCheckboxHasAttachment(
                    context,
                    currentFocusNode: focusManager?.attachmentCheckboxFocusNode,
                    nextFocusNode: focusManager?.searchButtonFocusNode)),
              ..._buildListButton(context, _responsiveUtils),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildListButton(
      BuildContext context,
      ResponsiveUtils responsiveUtils
  ) {
    if (_isMobileAndLandscapeTablet(context, responsiveUtils)) {
      return [
        Expanded(
          child: _buildButton(
            onAction: () {
              controller.cleanSearchFilter(context);
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
              controller.applyAdvancedSearchFilter(context);
              popBack();
            },
            colorButton: AppColor.primaryColor,
            colorText: AppColor.primaryLightColor,
            text: AppLocalizations.of(context).search,
            context: context,
            responsiveUtils: responsiveUtils,
            currentFocusNode: focusManager?.searchButtonFocusNode,
            nextFocusNode: focusManager?.fromFieldFocusNode
          ),
        ),
      ];
    } else {
      return [
        _buildButton(
          onAction: () {
            controller.cleanSearchFilter(context);
            popBack();
          },
          colorButton: Colors.white,
          colorText: AppColor.colorContentEmail,
          text: AppLocalizations.of(context).clearFilter,
          context: context,
          responsiveUtils: responsiveUtils,
          minWidth: 92
        ),
        const SizedBox(width: 12),
        _buildButton(
          onAction: () {
            controller.applyAdvancedSearchFilter(context);
            popBack();
          },
          colorButton: AppColor.primaryColor,
          colorText: AppColor.primaryLightColor,
          text: AppLocalizations.of(context).search,
          context: context,
          responsiveUtils: responsiveUtils,
          minWidth: 144,
          currentFocusNode: focusManager?.searchButtonFocusNode,
          nextFocusNode: focusManager?.fromFieldFocusNode
        ),
      ];
    }
  }

  Widget _buildCheckboxHasAttachment(
      BuildContext context,
      {
        FocusNode? currentFocusNode,
        FocusNode? nextFocusNode,
      }
  ) {
    return Obx(
      () => RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.tab) {
            nextFocusNode?.requestFocus();
          }
        },
        child: LabeledCheckbox(
          label: AppLocalizations.of(context).hasAttachment,
          focusNode: currentFocusNode,
          contentPadding: EdgeInsets.zero,
          value: controller.hasAttachment.value,
          activeColor: AppColor.primaryColor,
          onChanged: (value) => controller.hasAttachment.value = value ?? false,
        ),
      ),
    );
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
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        if (event is RawKeyDownEvent &&
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

  bool _isMobileAndLandscapeTablet(
      BuildContext context,
      ResponsiveUtils responsive
  ) {
    return responsive.isMobile(context) ||
        responsive.landscapeTabletSupported(context);
  }
}
