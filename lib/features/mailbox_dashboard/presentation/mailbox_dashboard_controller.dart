import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';

class MailboxDashBoardController extends BaseController {

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final mailboxCurrent = PresentationMailbox.createMailboxEmpty().obs;
  final mailCurrent = PresentationThread.createThreadEmpty().obs;

  MailboxDashBoardController();

  @override
  void onReady() {
    super.onReady();
    scaffoldKey.currentState?.openDrawer();
  }

  @override
  void onDone() {
  }

  @override
  void onError(error) {
  }
}