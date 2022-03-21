import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/home/presentation/home_controller.dart';

class HomeView extends GetWidget<HomeController> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.primaryLightColor,
      child: SizedBox(
        width: 100,
        height: 100,
        child: CupertinoActivityIndicator(),
      ),
    );
  }
}