import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/list/sliver_grid_delegate_fixed_height.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/app_grid/app_shortcut.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/app_linagora_ecosystem.dart';

extension OpenAppGridExtension on MailboxController {
  void openAppGrid(List<AppLinagoraEcosystem> linagoraApps) {
    log('OpenAppGridExtension::openAppGrid: length of linagoraApps = ${linagoraApps.length}');
    mailboxDashBoardController.isAppGridDialogDisplayed.value = true;
    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: Container(
            width: 254,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  offset: Offset(0, 2),
                  blurRadius: 24,
                ),
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 2,
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            child: GridView(
              gridDelegate: const SliverGridDelegateFixedHeight(
                height: 80.58,
                crossAxisCount: 3,
                mainAxisSpacing: 10,
              ),
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children: linagoraApps.map((app) {
                return AppShortcut(
                  icon: app.getIconPath(imagePaths),
                  label: app.appName ?? '',
                  onTapAction: () => _handleOpenApp(app),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      barrierColor: AppColor.blackAlpha20,
    ).whenComplete(() =>
        mailboxDashBoardController.isAppGridDialogDisplayed.value = false);
  }

  Future<void> _handleOpenApp(AppLinagoraEcosystem app) async {
    await launchApplication(
      androidPackageId: app.androidPackageId,
      iosScheme: app.iosUrlScheme,
      iosStoreLink: app.iosAppStoreLink,
      uri: app.appRedirectLink,
    );
  }
}
