import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/filter_email_popup_menu_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/user_setting_popup_menu_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';

abstract class BaseMailboxDashBoardView extends GetWidget<MailboxDashBoardController>
    with UserSettingPopupMenuMixin, FilterEmailPopupMenuMixin,
        AppLoaderMixin {
  BaseMailboxDashBoardView({Key? key}) : super(key: key);

  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  Widget buildQuickSearchFilterButton(
      BuildContext context, QuickSearchFilter filter) {
    return Obx(() {
      final isQuickSearchFilterSelected = controller.checkQuickSearchFilterSelected(
        quickSearchFilter: filter,
      );

      return Chip(
        labelPadding: const EdgeInsets.only(top: 2, bottom: 2, right: 10),
        label: Text(
          filter.getTitle(context, receiveTimeType: controller.searchController.emailReceiveTimeType.value),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: filter.getTextStyle(quickSearchFilterSelected: isQuickSearchFilterSelected),
        ),
        avatar: SvgPicture.asset(
            filter.getIcon(imagePaths, quickSearchFilterSelected: isQuickSearchFilterSelected),
            width: 16,
            height: 16,
            fit: BoxFit.fill),
        labelStyle: filter.getTextStyle(quickSearchFilterSelected: isQuickSearchFilterSelected),
        backgroundColor: filter.getBackgroundColor(quickSearchFilterSelected: isQuickSearchFilterSelected),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: filter.getBackgroundColor(quickSearchFilterSelected: isQuickSearchFilterSelected)),
        ),
      );
    });
  }
}