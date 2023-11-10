
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class LoginBackButton extends StatelessWidget {

  final _imagePath = Get.find<ImagePaths>();
  final VoidCallback onBackAction;

  LoginBackButton({super.key, required this.onBackAction});

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      start: 12,
      top: 12,
      child: IconButton(
        onPressed: onBackAction,
        icon: SvgPicture.asset(
          _imagePath.icBack,
          alignment: Alignment.center,
          colorFilter: AppColor.primaryColor.asFilter()
        )
      ),
    );
  }
}
