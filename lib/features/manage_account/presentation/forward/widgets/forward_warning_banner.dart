import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
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
      margin: SettingsUtils.getForwardBannerPadding(context, responsiveUtils),
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: AppColor.colorBackgroundNotificationVacationSetting,
      ),
      child: Row(children: [
        SvgPicture.asset(
          imagePaths.icInfoCircleOutline,
          colorFilter: AppColor.colorQuotaError.asFilter(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            AppConfig.getForwardWarningMessage(context),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 15,
              color: Colors.black
            )
          )
        ),
      ]),
    );
  }
}