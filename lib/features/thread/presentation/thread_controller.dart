import 'package:core/core.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class ThreadController extends BaseController {

  final ResponsiveUtils responsiveUtils;
  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  final presentationMailCurrent = PresentationThread.createThreadEmpty().obs;

  ThreadController(this.responsiveUtils);

  @override
  void onReady() {
    super.onReady();
    mailboxDashBoardController.scaffoldKey.currentState?.openEndDrawer();
  }

  SelectMode getSelectMode(PresentationThread presentationThread) {
    return presentationMailCurrent.value.id == presentationThread.id
      ? SelectMode.ACTIVE
      : SelectMode.INACTIVE;
  }

  void selectMail(BuildContext context, PresentationThread presentationMailSelected) {
    presentationMailCurrent.value = presentationMailSelected;
    mailboxDashBoardController.mailCurrent.value = presentationMailSelected;

    if (!responsiveUtils.isDesktop(context)) {
      goToMail(context);
    }
  }

  void goToMailbox({required GlobalKey<ScaffoldState> keyWidgetMailboxContainer}) {
    keyWidgetMailboxContainer.currentState?.openDrawer();
  }

  void goToMail(BuildContext context) {
    Get.toNamed(AppRoutes.MAIL);
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
  }

  @override
  void onDone() {}

  @override
  void onError(error) {}
}