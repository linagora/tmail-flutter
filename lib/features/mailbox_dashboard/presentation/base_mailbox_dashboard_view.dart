import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_drawer_changed_extension.dart';

abstract class BaseMailboxDashBoardView
    extends GetWidget<MailboxDashBoardController> with AppLoaderMixin {
  BaseMailboxDashBoardView({Key? key}) : super(key: key);

  Widget buildScaffoldHaveDrawer({required Widget body}) {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: ResponsiveWidget(
        responsiveUtils: controller.responsiveUtils,
        mobile: SizedBox(
          width: ResponsiveUtils.mobileLeftMenuSize,
          child: MailboxView(),
        ),
        tabletLarge: SizedBox(
          width: ResponsiveUtils.defaultSizeLeftMenuMobile,
          child: MailboxView(),
        ),
        desktop: const SizedBox.shrink(),
      ),
      onDrawerChanged:
          PlatformInfo.isWeb ? controller.handleDrawerChanged : null,
      body: body,
    );
  }

  Widget buildTwoPaneLayout({
    required Widget left,
    required Widget right,
  }) {
    return buildScaffoldHaveDrawer(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ResponsiveUtils.defaultSizeLeftMenuMobile,
            child: left,
          ),
          const VerticalDivider(width: 1),
          Expanded(child: right),
        ],
      ),
    );
  }

  Widget buildResponsiveWithDrawer({
    required Widget left,
    required Widget right,
    required Widget mobile,
  }) {
    return ResponsiveWidget(
      responsiveUtils: controller.responsiveUtils,
      tablet: buildTwoPaneLayout(left: left, right: right),
      mobile: mobile,
    );
  }
}
