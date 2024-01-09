import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailto/presentation/mailto_url_controller.dart';

class MailtoUrlView extends GetWidget<MailtoUrlController> {
  const MailtoUrlView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.primaryLightColor,
      child: const SizedBox(
        width: 100,
        height: 100,
        child: CupertinoActivityIndicator(),
      ),
    );
  }
}