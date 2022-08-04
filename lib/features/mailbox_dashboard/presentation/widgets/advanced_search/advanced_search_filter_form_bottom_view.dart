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
            colorButton: AppColor.primaryColor.withOpacity(0.06),
            colorText: AppColor.primaryColor,
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
          colorButton: AppColor.primaryColor.withOpacity(0.06),
          colorText: AppColor.primaryColor,
          text: AppLocalizations.of(context).clearFilter,
          context: context,
          responsiveUtils: responsiveUtils,
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
      () => SizedBox(
        width: 220,
        child: RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (event) {
            log('AdvancedSearchFilterFormBottomView::_buildCheckboxHasAttachment(): Event runtimeType is ${event.runtimeType}');
            if (event is RawKeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.tab) {
              log('AdvancedSearchFilterFormBottomView::_buildCheckboxHasAttachment(): PRESS TAB');
              nextFocusNode?.requestFocus();
            }
          },
          child: CheckboxListTile(
            focusNode: currentFocusNode,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: controller.hasAttachment.value,
            onChanged: (value) {
              controller.hasAttachment.value = value ?? false;
            },
            title: Text(AppLocalizations.of(context).hasAttachment),
          ),
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
  }) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        log('AdvancedSearchFilterFormBottomView::_buildButton(): Event runtimeType is ${event.runtimeType}');
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.tab) {
          log('AdvancedSearchFilterFormBottomView::_buildButton(): PRESS TAB');
          nextFocusNode?.requestFocus();
        }
      },
      child: buildTextButton(
          text,
          focusNode: currentFocusNode,
          width: _isMobileAndLandscapeTablet(context, responsiveUtils)
              ? double.infinity
              : 144,
          height: 44,
          radius: 10,
          textStyle: TextStyle(fontSize: 17, color: colorText),
          backgroundColor: colorButton,
          padding: EdgeInsets.symmetric(
              horizontal: _isMobileAndLandscapeTablet(context, responsiveUtils)
                  ? 0
                  : 26),
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
