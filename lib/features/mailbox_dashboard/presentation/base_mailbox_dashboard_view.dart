import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/filter_email_popup_menu_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/user_setting_popup_menu_mixin.dart';

abstract class BaseMailboxDashBoardView extends GetWidget<MailboxDashBoardController>
    with UserSettingPopupMenuMixin, FilterEmailPopupMenuMixin,
        AppLoaderMixin {
  BaseMailboxDashBoardView({Key? key}) : super(key: key);

  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();
}