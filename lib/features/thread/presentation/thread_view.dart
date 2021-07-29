import 'package:core/core.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar_thread_widget_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/thread_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ThreadView extends GetWidget<ThreadController> {

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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => _buildAppBarMailboxListMail(context)),
              Expanded(child: _buildListMail(context)),
            ])
        )
      ),
    );
  }

  Widget _buildAppBarMailboxListMail(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 8.0, right: 16),
      child: AppBarThreadWidgetBuilder(
          context,
          imagePaths,
          responsiveUtils,
          mailboxDashBoardController.mailboxCurrent.value)
        .onOpenListMailboxActionClick(() => controller.goToMailbox(keyWidgetMailboxContainer: mailboxDashBoardController.scaffoldKey))
        .build());
  }

  Widget _buildListMail(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      color: responsiveUtils.isMobile(context) ? AppColor.bgMailboxListMail : Colors.white,
      child: Obx(() => controller.viewState.value.fold(
        (failure) => _buildEmptyThread(context),
        (success) => _buildListThreadBody(context, []))
      ),
    );
  }

  Widget _buildListThreadBody(BuildContext context, List<PresentationThread> listThread) {
    if (listThread.isEmpty) {
      return _buildEmptyThread(context);
    } else {
      return ListView.builder(
        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
        key: Key('thread_list'),
        itemCount: listThread.length,
        itemBuilder: (context, index) =>
          Obx(() => ThreadTileBuilder(
              imagePaths,
              controller.getSelectMode(listThread[index]),
              listThread[index])
            .onOpenMailAction(() => controller.selectMail(context, listThread[index]))
            .build()
          )
      );
    }
  }

  Widget _buildEmptyThread(BuildContext context) {
    return Text(
      AppLocalizations.of(context).no_threads,
      maxLines: 1,
      style: TextStyle(fontSize: 25, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold));
  }
}