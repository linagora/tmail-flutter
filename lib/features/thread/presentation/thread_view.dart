import 'package:core/core.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/load_more_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/app_bar_thread_widget_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ThreadView extends GetWidget<ThreadController> {

  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: responsiveUtils.isMobile(context) ? AppColor.bgMailboxListMail : AppColor.primaryLightColor,
      body: SafeArea(
        right: false,
        left: false,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => _buildAppBarMailboxListMail(
                  context,
                  controller.mailboxDashBoardController.selectedMailbox.value,
                  controller.mailboxDashBoardController.userProfile.value,
              )),
              _buildLoadingView(),
              Expanded(child: _buildListEmail(context)),
              _buildLoadingViewLoadMore()
            ]
          )
        )
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 4.0,
        child: new Icon(Icons.add),
        backgroundColor: AppColor.appColor,
        onPressed: () => controller.composeEmailAction()
      )
    );
  }

  Widget _buildAppBarMailboxListMail(BuildContext context, PresentationMailbox? presentationMailbox, UserProfile? userProfile) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 12),
      child: AppBarThreadWidgetBuilder(
          context,
          imagePaths,
          responsiveUtils,
          presentationMailbox,
          userProfile)
        .onOpenListMailboxActionClick(() => controller.openMailboxLeftMenu())
        .build());
  }

  Widget _buildLoadingView() {
    return Obx(() => controller.viewState.value.fold(
      (failure) => SizedBox.shrink(),
      (success) => success == UIState.loading && controller.loadMoreState.value != LoadMoreState.LOADING
        ? Center(child: Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(color: AppColor.primaryColor))))
        : SizedBox.shrink()));
  }

  Widget _buildLoadingViewLoadMore() {
    return Obx(() => controller.loadMoreState.value == LoadMoreState.LOADING
      ? Center(child: Padding(
          padding: EdgeInsets.only(top: 16, bottom: 16),
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(color: AppColor.primaryColor))))
      : SizedBox.shrink());
  }

  Widget _buildListEmail(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      color: responsiveUtils.isMobile(context) ? AppColor.bgMailboxListMail : Colors.white,
      child: Obx(() => RefreshIndicator(
        color: AppColor.primaryColor,
        onRefresh: () async => controller.refreshGetAllEmailAction(),
        child: controller.emailList.isNotEmpty
          ? _buildListEmailBody(context, controller.emailList)
          : _buildEmptyEmail(context)))
      );
  }

  Widget _buildListEmailBody(BuildContext context, List<PresentationEmail> listPresentationEmail) {
    if (listPresentationEmail.isEmpty) {
      return _buildEmptyEmail(context);
    } else {
      return  NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (controller.loadMoreState.value == LoadMoreState.IDLE
                && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
              controller.loadMoreEmailAction();
              return true;
            }
            return false;
          },
          child: ListView.builder(
            padding: EdgeInsets.only(top: 16),
            key: Key('presentation_email_list'),
            itemCount: listPresentationEmail.length,
            itemBuilder: (context, index) =>
              Obx(() => EmailTileBuilder(
                  context,
                  imagePaths,
                  controller.getSelectMode(listPresentationEmail[index], controller.mailboxDashBoardController.selectedEmail.value),
                  listPresentationEmail[index],
                  responsiveUtils)
                .onOpenMailAction(() => controller.selectEmail(context, listPresentationEmail[index]))
                .build())
          ));
    }
  }

  Widget _buildEmptyEmail(BuildContext context) {
    return Obx(() => controller.viewState.value.fold(
      (failure) => SizedBox.shrink(),
      (success) => success != UIState.loading
        ? Text(
            AppLocalizations.of(context).no_emails,
            maxLines: 1,
            style: TextStyle(fontSize: 25, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold))
        : SizedBox.shrink())
    );
  }
}