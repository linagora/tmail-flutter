import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class ForwardWarningBanner extends StatelessWidget {

  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;

  const ForwardWarningBanner({
    super.key,
    required this.imagePaths,
    required this.responsiveUtils,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: _getMargin(context, responsiveUtils),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 17),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: AppColor.lightGrayEAEDF2,
      ),
      child: Row(
        crossAxisAlignment: responsiveUtils.isWebDesktop(context)
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            imagePaths.icInfoCircleOutline,
            width: 20,
            height: 20,
            fit: BoxFit.fill,
            colorFilter: AppColor.steelGray200.asFilter(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppConfig.forwardWarningMessage ??
                  AppLocalizations.of(context).messageWarningDialogForForwardsToOtherDomains,
              style: ThemeUtils.textStyleInter400.copyWith(
                letterSpacing: 0.0,
                color: AppColor.steelGray400,
              )
            )
          ),
        ],
      ),
    );
  }

  EdgeInsetsGeometry _getMargin(
    BuildContext context,
    ResponsiveUtils responsiveUtils,
  ) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsetsDirectional.only(end: 16, top: 16);
    } else if (responsiveUtils.isMobile(context)) {
      return const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 12);
    } else {
      return const EdgeInsetsDirectional.only(start: 32, end: 32, bottom: 12);
    }
  }
}