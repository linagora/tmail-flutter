
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/widgets/change_language_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/widgets/language_and_region_header_widget.dart';

class LanguageAndRegionView extends GetWidget<LanguageAndRegionController> {

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  LanguageAndRegionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _responsiveUtils.isWebDesktop(context)
          ? AppColor.colorBgDesktop
          : Colors.white,
      body: Container(
        width: double.infinity,
        margin: _responsiveUtils.isWebDesktop(context)
          ? const EdgeInsets.only(left: 48, right: 24, top: 24, bottom: 24)
          : EdgeInsets.zero,
        color: _responsiveUtils.isWebDesktop(context) ? null : Colors.white,
        decoration: _responsiveUtils.isWebDesktop(context)
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColor.colorBorderBodyThread, width: 1),
                color: Colors.white)
            : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
              _responsiveUtils.isWebDesktop(context) ? 20 : 0),
          child: Padding(
            padding: EdgeInsets.only(
                left: _responsiveUtils.isWebDesktop(context) ? 24 : 10,
                top: 24,
                right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LanguageAndRegionHeaderWidget(),
                const SizedBox(height: 22),
                Expanded(child: ChangeLanguageWidget())
              ]
            ),
          ),
        ),
      ),
    );
  }
}