import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HorizontalProgressLoadingButton extends StatelessWidget {
  const HorizontalProgressLoadingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 16, start: 24, end: 24),
      width: context.width,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          disabledBackgroundColor: AppColor.primaryColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          )
        ),
        onPressed: null,
        child: const LinearProgressIndicator(
          color: Colors.white,
          backgroundColor: AppColor.primaryColor
        )
      )
    );
  }
}