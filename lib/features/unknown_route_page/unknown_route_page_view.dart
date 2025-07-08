import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class UnknownRoutePageView extends StatelessWidget {

  static const double maxWidthTextDefault = 440.0;

  final _imagePath = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  UnknownRoutePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (_responsiveUtils.isPortraitMobile(context))
              Padding(
                padding: const EdgeInsets.only(top: 48, bottom: 32),
                child: SvgPicture.asset(_imagePath.icPageNotFoundMobile))
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: SvgPicture.asset(_imagePath.icPageNotFound)),
            Container(
              color: Colors.white,
              padding: _getPaddingTitle(context),
              constraints: BoxConstraints(maxWidth: _getMaxWidthTitle(context)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context).titlePageNotFound,
                    textAlign: TextAlign.center,
                    style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: _getFontSizeTitle(context)
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).subTitlePageNotFound,
                    textAlign: TextAlign.center,
                    style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColor.colorSettingExplanation,
                      fontSize: 16
                    ),
                  )
                ]
              ),
            ),
            const SizedBox(height: 48)
          ]),
        ),
      ),
    );
  }

  double _getMaxWidthTitle(BuildContext context) {
    final widthScreen = _responsiveUtils.getSizeScreenWidth(context);
    if (widthScreen > maxWidthTextDefault) {
      return maxWidthTextDefault;
    } else {
      return widthScreen;
    }
  }

  EdgeInsets _getPaddingTitle(BuildContext context) {
    if (_responsiveUtils.isPortraitMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 30);
    } else {
      return EdgeInsets.zero;
    }
  }

  double _getFontSizeTitle(BuildContext context) {
    if (_responsiveUtils.isPortraitMobile(context)) {
      return 20.0;
    } else {
      return 24.0;
    }
  }
}