import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/network_connection_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/filter_email_popup_menu_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/user_setting_popup_menu_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';

abstract class BaseMailboxDashBoardView extends GetWidget<MailboxDashBoardController>
    with NetworkConnectionMixin, UserSettingPopupMenuMixin, FilterEmailPopupMenuMixin,
        AppLoaderMixin {
  BaseMailboxDashBoardView({Key? key}) : super(key: key);

  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  Widget buildQuickSearchFilterButton(
      BuildContext context, QuickSearchFilter filter) {
    return Obx(() {
      return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: filter.getBackgroundColor(controller.listFilterQuickSearch)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SvgPicture.asset(
                filter.getIcon(imagePaths, controller.listFilterQuickSearch),
                width: 16,
                height: 16,
                fit: BoxFit.fill),
            const SizedBox(width: 4),
            Text(
              filter.getTitle(context, receiveTimeType: controller.emailReceiveTimeType.value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: filter.getTextStyle(controller.listFilterQuickSearch),
            )
          ]));
    });
  }
}