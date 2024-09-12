
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/banner_empty_trash_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class BannerEmptyTrashWidget extends StatelessWidget {

  final VoidCallback onTapAction;

  const BannerEmptyTrashWidget({super.key, required this.onTapAction});

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();
    final responsiveUtils = Get.find<ResponsiveUtils>();

    return Container(
      decoration: const ShapeDecoration(
        color: BannerEmptyTrashStyles.backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: BannerEmptyTrashStyles.borderStrokeColor,
          ),
          borderRadius: BorderRadius.all(Radius.circular(BannerEmptyTrashStyles.borderRadius)),
        ),
      ),
      margin: BannerEmptyTrashStyles.getBannerMargin(context, responsiveUtils),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapAction,
          borderRadius: const BorderRadius.all(Radius.circular(BannerEmptyTrashStyles.borderRadius)),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: BannerEmptyTrashStyles.horizontalPadding,
              vertical: BannerEmptyTrashStyles.verticalPadding
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  imagePaths.icDeleteRuleMobile,
                  width: BannerEmptyTrashStyles.iconSize,
                  height: BannerEmptyTrashStyles.iconSize,
                  fit: BoxFit.fill
                ),
                const SizedBox(width: BannerEmptyTrashStyles.space),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).empty_trash_now,
                        style: const TextStyle(
                          fontSize: BannerEmptyTrashStyles.buttonTextSize,
                          fontWeight: FontWeight.w500,
                          color: BannerEmptyTrashStyles.buttonTextColor
                        )
                      ),
                      Text(
                        AppLocalizations.of(context).message_delete_all_email_in_trash_button,
                        style: const TextStyle(
                          color: BannerEmptyTrashStyles.labelTextColor,
                          fontSize: BannerEmptyTrashStyles.labelTextSize,
                          fontWeight: FontWeight.w400
                        )
                      ),
                    ]
                  )
                )
              ]
            ),
          ),
        ),
      ),
    );
  }
}
