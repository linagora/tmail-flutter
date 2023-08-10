import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mixin/mailbox_widget_mixin.dart';

abstract class BaseMailboxView extends GetWidget<MailboxController>
    with
        AppLoaderMixin,
        MailboxWidgetMixin {

  BaseMailboxView({Key? key}) : super(key: key);

  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();
}