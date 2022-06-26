import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class AdvancedSearchFilterFormBottomView
    extends GetWidget<AdvancedFilterController> {
  const AdvancedSearchFilterFormBottomView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ResponsiveUtils _responsiveUtils = Get.find<ResponsiveUtils>();

    return Padding(
      padding: EdgeInsets.only(top: _responsiveUtils.isMobile(context) ? 8 : 20),
      child: Column(
        children: [
          if (_responsiveUtils.isMobile(context))
            _buildCheckboxHasAttachment(context),
          Row(
            mainAxisAlignment: _responsiveUtils.isMobile(context)
                ? MainAxisAlignment.spaceEvenly
                : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (!_responsiveUtils.isMobile(context))
                Expanded(child: _buildCheckboxHasAttachment(context)),
              _buildButton(
                onAction: () {
                  controller.cleanSearchFilter(context);
                  popBack();
                },
                colorButton: AppColor.primaryColor.withOpacity(0.14),
                colorText: AppColor.primaryColor,
                text: AppLocalizations.of(context).clearFilter,
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxHasAttachment(BuildContext context) {
    return Obx(
      () => CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: controller.hasAttachment.value,
        onChanged: (value) {
          controller.hasAttachment.value = value ?? false;
        },
        title: Text(AppLocalizations.of(context).hasAttachment),
      ),
    );
  }

  Widget _buildButton({
    required Color colorButton,
    required Color colorText,
    required String text,
    required VoidCallback onAction,
  }) {
    return InkWell(
      onTap: onAction,
      onTapDown: (_) {
        onAction.call();
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 154),
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: colorButton),
        child: Text(
          text,
          style: TextStyle(fontSize: 17, color: colorText),
        ),
      ),
    );
  }
}
