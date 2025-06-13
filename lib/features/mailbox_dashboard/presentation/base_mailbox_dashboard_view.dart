import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

abstract class BaseMailboxDashBoardView extends GetWidget<MailboxDashBoardController>
    with AppLoaderMixin {
  BaseMailboxDashBoardView({Key? key}) : super(key: key);
}