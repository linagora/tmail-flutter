import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

class EmailSupervisorController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  final Queue<EmailLoaded> presentationEmailsLoaded = Queue();
  PageController? pageController;
  int currentIndexPageView = -1;
  final canGetNewerEmail = true.obs;
  final canGetOlderEmail = true.obs;

  Rxn<PresentationEmail> get selectedEmail => mailboxDashBoardController.selectedEmail;
  Session? get sessionCurrent => mailboxDashBoardController.sessionCurrent;
  AccountId? get accountId => mailboxDashBoardController.accountId.value;

  RxList<PresentationEmail> get listEmail => mailboxDashBoardController.searchController.isSearchEmailRunning && !kIsWeb ?
  mailboxDashBoardController.listResultSearch : mailboxDashBoardController.emailsInCurrentMailbox;

  @override
  void onClose() {
    pageController?.dispose();
    super.onClose();
  }

  void setCurrentPositionEmailInListEmail(EmailId? currentEmailId) {
    currentIndexPageView = listEmail.indexWhere((e) => e.id == currentEmailId);
    if(pageController != null && pageController!.hasClients && pageController!.page?.toInt() != currentIndexPageView) {
      pageController!.jumpToPage(currentIndexPageView);
    } else {
      pageController = PageController(initialPage: currentIndexPageView);
    }
    _checkEnableNavigatorPageView();
  }

  void onPageChanged(int index) {
    mailboxDashBoardController.selectedEmail.value = listEmail[index];
  }

  void _checkEnableNavigatorPageView() {
    canGetNewerEmail.value = listEmail.length > 1 && currentIndexPageView > 0;
    canGetOlderEmail.value = listEmail.length > 1 && currentIndexPageView < listEmail.length - 1;
  }

  void getNewerEmail() {
    currentIndexPageView = currentIndexPageView - 1;
    pageController?.jumpToPage(currentIndexPageView);
  }

  void getOlderEmail() {
    currentIndexPageView = currentIndexPageView + 1;
    pageController?.jumpToPage(currentIndexPageView);
  }

  @override
  void onDone() {
  }
}