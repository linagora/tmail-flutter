import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/preferences_option_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/preferences_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/widgets/preferences_option_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/providers/experimental_mode_notifier.dart';
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
              child: _PreferencesBody(controller: controller),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreferencesBody extends ConsumerWidget {
  const _PreferencesBody({required this.controller});

  final PreferencesController controller;

  static const _childOptionBorderColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExperimentalEnabled = ref.watch(experimentalModeNotifierProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.responsiveUtils.isWebDesktop(context))
          SettingHeaderWidget(
            menuItem: AccountMenuItem.preferences,
            padding: const EdgeInsets.only(bottom: 21),
            onMultiClickAction: isExperimentalEnabled
                ? null
                : controller.enableExperimentalMode,
            multiClickCount: ExperimentalModeNotifier.activationTapCount,
          ),
        Obx(() {
          final settingOption = controller.settingOption.value;
          final localSettingOption = controller.localSettings.value;
          final isLabelVisibility = controller
              .accountDashboardController
              .isLabelVisibilityEnabled;

          if (settingOption == null &&
              localSettingOption.configs.isEmpty) {
            return const SizedBox.shrink();
          }

          final ctx = (
            settingOption: settingOption,
            localSettings: localSettingOption,
            isExperimentalEnabled: isExperimentalEnabled,
            isAIScribeAvailable: controller.isAIScribeCapabilityAvailable,
            isAICapabilitySupported: controller.isAICapabilitySupported,
            isLabelVisibility: isLabelVisibility.isTrue,
          );
          final availableSettingOptions = _buildAvailableOptions(ctx);

          return Expanded(
            child: ListView.separated(
              itemCount: availableSettingOptions.length,
              itemBuilder: (context, index) {
                final optionType = availableSettingOptions[index];
                return _buildOptionItem(
                  optionType: optionType,
                  settingOption: settingOption,
                  localSettingOption: localSettingOption,
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 49),
            ),
          );
        }),
      ],
    );
  }

  List<PreferencesOptionType> _buildAvailableOptions(
    PreferencesVisibilityContext ctx,
  ) {
    return PreferencesOptionType.values
        .where((type) => type.isVisible(ctx))
        .toList();
  }

  Widget _buildOptionItem({
    required PreferencesOptionType optionType,
    required TMailServerSettingOptions? settingOption,
    required PreferencesSetting localSettingOption,
  }) {
    final item = PreferencesOptionItem(
      imagePaths: controller.imagePaths,
      settingOption: settingOption,
      preferencesSetting: localSettingOption,
      optionType: optionType,
      onTapPreferencesOptionAction: controller.updateStateSettingOption,
    );

    if (!optionType.isChildOption) return item;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 24),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: BorderDirectional(
            start: BorderSide(color: _childOptionBorderColor, width: 2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: item,
        ),
      ),
    );
  }
}
