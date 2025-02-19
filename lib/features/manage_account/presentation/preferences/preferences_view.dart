import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/setting_option_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/preferences_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/widgets/setting_option_item.dart';

class PreferencesView extends GetWidget<PreferencesController> with AppLoaderMixin {
  const PreferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUtils.getBackgroundColor(context, controller.responsiveUtils),
      body: Padding(
        padding: SettingsUtils.getMarginViewForSettingDetails(context, controller.responsiveUtils),
        child: Column(
          children: [
            Obx(() {
              if (!controller.isLoading) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: horizontalLoadingWidget,
              );
            }),
            Expanded(
              child: Container(
                color: SettingsUtils.getContentBackgroundColor(
                  context, controller.responsiveUtils,
                ),
                decoration: SettingsUtils.getBoxDecorationForContent(
                  context,
                  controller.responsiveUtils,
                ),
                width: double.infinity,
                padding: SettingsUtils.getPaddingAlwaysReadReceiptSetting(
                  context,
                  controller.responsiveUtils,
                ),
                child: Obx(() {
                  final settingOption = controller.settingOption.value;

                  if (settingOption == null) return const SizedBox.shrink();

                  final settingOptionList = SettingOptionType.values.toList();

                  return ListView.separated(
                    itemCount: settingOptionList.length,
                    itemBuilder: (context, index) {
                      return SettingOptionItem(
                        imagePaths: controller.imagePaths,
                        settingOption: settingOption,
                        optionType: settingOptionList[index],
                        onTapSettingOptionAction: controller.updateStateSettingOption,
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 60),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}