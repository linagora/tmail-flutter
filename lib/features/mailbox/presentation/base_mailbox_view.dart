import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mixin/mailbox_widget_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/user_information_widget_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

abstract class BaseMailboxView extends GetWidget<MailboxController>
    with
        AppLoaderMixin,
        MailboxWidgetMixin {

  BaseMailboxView({Key? key}) : super(key: key);

  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  Widget buildUserInformation(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Obx(() => UserInformationWidgetBuilder(
        imagePaths,
        controller.mailboxDashBoardController.userProfile.value,
        subtitle: AppLocalizations.of(context).manage_account,
        onSubtitleClick: controller.mailboxDashBoardController.goToSettings)),
      const Divider(color: AppColor.colorDividerMailbox, height: 1)
    ]);
  }
}