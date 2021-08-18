import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/email_controller.dart';

class MailboxDashBoardController extends BaseController {

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final selectedMailbox = Rxn<PresentationMailbox>();
  final selectedEmail = Rxn<PresentationEmail>();
  final accountId = Rxn<AccountId>();

  Session? sessionCurrent;

  MailboxDashBoardController();

  @override
  void onReady() {
    super.onReady();
    _setSessionCurrent();
  }

  @override
  void onDone() {
  }

  @override
  void onError(error) {
  }

  void _setSessionCurrent() {
    Future.delayed(const Duration(milliseconds: 100), () {
      final arguments = Get.arguments;
      if (arguments is Session) {
        sessionCurrent = Get.arguments as Session;
        accountId.value = sessionCurrent?.accounts.keys.first;
      }
    });
  }

  void setSelectedMailbox(PresentationMailbox? newPresentationMailbox) {
    selectedMailbox.value = newPresentationMailbox;
  }

  void setSelectedEmail(PresentationEmail? newPresentationEmail) {
    selectedEmail.value = newPresentationEmail;
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  void onClose() {
    super.onClose();
    Get.delete<EmailController>();
  }
}