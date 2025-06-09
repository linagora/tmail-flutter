import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie_native/lottie_native.dart';
import 'package:tmail_ui_user/features/home/presentation/home_controller.dart';

class HomeView extends GetWidget<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeUtils.setSystemDarkUIStyle();

    if (PlatformInfo.isIOS) {
      return ColoredBox(
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 176,
              height: 176,
              child: LottieView.fromAsset(
                filePath: controller.imagePaths.animLottieTmail,
                loop: false,
              ),
            ),
            Positioned(
              bottom: 40,
              child: SafeArea(
                child: Image.asset(
                  controller.imagePaths.icTwakeWorkplace,
                  width: 210,
                ),
              ),
            ),
          ],
        ),
      );
    }

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