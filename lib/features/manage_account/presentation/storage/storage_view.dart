import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/circle_loading_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/storage/storage_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/storage/widgets/storage_progress_bar_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/storage/widgets/upgrade_storage_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_explanation_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_header_widget.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';

class StorageView extends GetWidget<StorageController> with AppLoaderMixin {
  const StorageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsiveUtils = controller.responsiveUtils;
    final isMobile = responsiveUtils.isMobile(context);
    final isDesktop = responsiveUtils.isDesktop(context);
    final isWebDesktop = responsiveUtils.isWebDesktop(context);

    return SettingDetailViewBuilder(
      responsiveUtils: responsiveUtils,
      child: Container(
        color: SettingsUtils.getContentBackgroundColor(
          context,
          responsiveUtils,
        ),
        decoration: SettingsUtils.getBoxDecorationForContent(
          context,
          responsiveUtils,
        ),
        width: double.infinity,
        padding: isDesktop
            ? const EdgeInsets.symmetric(vertical: 30, horizontal: 22)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWebDesktop)
              SettingHeaderWidget(
                menuItem: AccountMenuItem.storage,
                textStyle: ThemeUtils.textStyleInter600().copyWith(
                  color: Colors.black.withValues(alpha: 0.9),
                ),
                padding: EdgeInsets.zero,
              )
            else
              const SettingExplanationWidget(
                menuItem: AccountMenuItem.storage,
                padding: EdgeInsetsDirectional.only(
                  start: 16,
                  end: 16,
                  bottom: 16,
                ),
                isCenter: true,
                textAlign: TextAlign.center,
              ),
            Obx(() {
              if (!controller.isLoading) {
                return const SizedBox.shrink();
              }
              return Center(
                child: Padding(
                  padding: SettingsUtils.getSettingProgressBarPadding(
                    context,
                    controller.responsiveUtils,
                  ),
                  child: const CircleLoadingWidget(),
                ),
              );
            }),
            Expanded(
              child: Obx(() {
                final octetsQuota = controller.octetsQuota.value;
                if (octetsQuota != null && octetsQuota.storageAvailable) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: _getPadding(
                        isMobile: isMobile,
                        isDesktop: isDesktop,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StorageProgressBarWidget(
                            imagePaths: controller.imagePaths,
                            quota: octetsQuota,
                            isMobile: isMobile,
                          ),
                          Obx(() {
                            if (controller.validatePremiumIsAvailable() &&
                                PlatformInfo.isWeb) {
                              return UpgradeStorageWidget(
                                imagePaths: controller.imagePaths,
                                isMobile: isMobile,
                                onUpgradeStorageAction: () =>
                                    controller.onUpgradeStorage(context),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          })
                        ],
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  EdgeInsetsGeometry _getPadding({
    bool isMobile = false,
    bool isDesktop = false,
  }) {
    if (isMobile) {
      return const EdgeInsetsDirectional.only(top: 31, start: 24, end: 24);
    } else if (isDesktop) {
      return const EdgeInsetsDirectional.only(top: 37, start: 15);
    } else {
      return const EdgeInsetsDirectional.only(top: 31, start: 32, end: 32);
    }
  }
}
