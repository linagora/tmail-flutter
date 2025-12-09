import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/handle_setup_label_visibility_in_setting_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/preferences_option_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/preferences_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/widgets/preferences_option_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_header_widget.dart';

class PreferencesView extends GetWidget<PreferencesController> with AppLoaderMixin {
  const PreferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          if (!controller.isLoading) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: SettingsUtils.getSettingProgressBarPadding(
              context,
              controller.responsiveUtils,
            ),
            child: horizontalLoadingWidget,
          );
        }),
        Expanded(
          child: SettingDetailViewBuilder(
            responsiveUtils: controller.responsiveUtils,
            padding: SettingsUtils.getSettingContentWithoutHeaderPadding(
              context,
              controller.responsiveUtils,
            ),
            child: Container(
              color: SettingsUtils.getContentBackgroundColor(
                context, controller.responsiveUtils,
              ),
              decoration: SettingsUtils.getBoxDecorationForContent(
                context,
                controller.responsiveUtils,
              ),
              width: double.infinity,
              padding: controller.responsiveUtils.isDesktop(context)
                ? const EdgeInsets.symmetric(vertical: 30, horizontal: 22)
                : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.responsiveUtils.isWebDesktop(context))
                    Obx(
                      () {
                        final labelVisibility = controller
                            .accountDashboardController.isLabelVisibility.value;

                        final isLabelCapabilitySupported = controller
                            .accountDashboardController
                            .isLabelCapabilitySupported;

                        final disableMultiClick =
                            labelVisibility || !isLabelCapabilitySupported;

                        return SettingHeaderWidget(
                          menuItem: AccountMenuItem.preferences,
                          padding: const EdgeInsets.only(bottom: 21),
                          onMultiClickAction: disableMultiClick
                              ? null
                              : controller.accountDashboardController
                                  .enableLabelVisibility,
                        );
                      },
                    ),
                  Obx(() {
                    final settingOption = controller.settingOption.value;
                    final localSettingOption = controller.localSettings.value;
                    final isLabelVisibility = controller
                        .accountDashboardController
                        .isLabelVisibility;

                    if (settingOption == null &&
                        localSettingOption.configs.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final availableSettingOptions = [
                      if (settingOption != null)
                        ...PreferencesOptionType.values.where(
                          (optionType) => !optionType.isLocal,
                        ),
                      if (localSettingOption.configs.isNotEmpty)
                        ...PreferencesOptionType.values.where(
                          (optionType) => optionType.isLocal &&
                              optionType != PreferencesOptionType.label
                        ).where((optionType) {
                          if (optionType == PreferencesOptionType.aiScribe) {
                            return controller.isAIScribeAvailable;
                          }
                          return true;
                        }),
                      if (isLabelVisibility.isTrue)
                        PreferencesOptionType.label,
                    ];

                    return Expanded(
                      child: ListView.separated(
                        itemCount: availableSettingOptions.length,
                        itemBuilder: (context, index) {
                          return PreferencesOptionItem(
                            imagePaths: controller.imagePaths,
                            settingOption: settingOption,
                            preferencesSetting: localSettingOption,
                            optionType: availableSettingOptions[index],
                            onTapPreferencesOptionAction: controller.updateStateSettingOption,
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 49),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}