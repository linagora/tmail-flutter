import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/presentation/email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/app_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/bottom_bar_mail_widget_builder.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailView extends GetWidget<EmailController> {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.primaryLightColor,
      body: SafeArea(
        right: false,
        left: false,
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAppBar(context),
              Expanded(child: _buildListMail(context)),
              _buildBottomBar(context),
            ])
        )
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 16.0, right: 16, bottom: 16),
      child: AppBarMailWidgetBuilder(context, imagePaths, responsiveUtils)
        .onBackActionClick(() => controller.goToMailboxListMail(context))
        .build());
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 16.0, right: 16, bottom: 16),
      child: BottomBarMailWidgetBuilder(context, imagePaths, responsiveUtils)
          .build());
  }

  Widget _buildListMail(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.all(20),
      color: AppColor.bgMessenger,
      child: Obx(() => Text(
        mailboxDashBoardController.selectedEmail.value != PresentationEmail.presentationEmailEmpty
          ? '${mailboxDashBoardController.selectedEmail.value.preview}'
          : AppLocalizations.of(context).no_mail_selected,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 25, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold)
      ))
    );
  }
}