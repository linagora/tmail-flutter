import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/home/presentation/home_controller.dart';

class HomeView extends GetWidget<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeUtils.setSystemDarkUIStyle();

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