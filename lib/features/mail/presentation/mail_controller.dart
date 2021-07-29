import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';

class MailController extends BaseController {

  final ResponsiveUtils responsiveUtils;

  MailController(this.responsiveUtils);

  @override
  void onReady() {
    super.onReady();
  }

  void goToMailboxListMail(BuildContext context) {
    Get.back();
  }

  @override
  void onDone() {
  }

  @override
  void onError(error) {
  }
}