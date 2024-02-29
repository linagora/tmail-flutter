import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ForwardWarningBanner extends StatelessWidget {

  final ImagePaths _imagePaths = Get.find<ImagePaths>();

  ForwardWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsetsDirectional.only(top: 16, start: 16, end: 16),
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: AppColor.colorBackgroundNotificationVacationSetting,
      ),
      child: Row(children: [
        SvgPicture.asset(
          _imagePaths.icInfoCircleOutline,
          colorFilter: AppColor.colorQuotaError.asFilter(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            AppLocalizations.of(context).messageWarningDialogForForwardsToOtherDomains,
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