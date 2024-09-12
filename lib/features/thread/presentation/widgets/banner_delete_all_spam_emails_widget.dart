
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/banner_delete_all_spam_emails_styles.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/banner_empty_trash_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class BannerDeleteAllSpamEmailsWidget extends StatelessWidget {

  final VoidCallback onTapAction;

  const BannerDeleteAllSpamEmailsWidget({super.key, required this.onTapAction});

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();
    final responsiveUtils = Get.find<ResponsiveUtils>();

    return Container(
      decoration: const ShapeDecoration(
        color: BannerDeleteAllSpamEmailsStyles.backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: BannerDeleteAllSpamEmailsStyles.borderStrokeColor,
          ),
          borderRadius: BorderRadius.all(Radius.circular(BannerDeleteAllSpamEmailsStyles.borderRadius)),
        ),
      ),
      margin: BannerEmptyTrashStyles.getBannerMargin(context, responsiveUtils),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapAction,
          borderRadius: const BorderRadius.all(Radius.circular(BannerDeleteAllSpamEmailsStyles.borderRadius)),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: BannerDeleteAllSpamEmailsStyles.horizontalPadding,
              vertical: BannerDeleteAllSpamEmailsStyles.verticalPadding
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  imagePaths.icDeleteRuleMobile,
                  width: BannerDeleteAllSpamEmailsStyles.iconSize,
                  height: BannerDeleteAllSpamEmailsStyles.iconSize,
                  fit: BoxFit.fill
                ),
                const SizedBox(width: BannerDeleteAllSpamEmailsStyles.space),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).deleteAllSpamEmailsNow,
                        style: const TextStyle(
                          fontSize: BannerDeleteAllSpamEmailsStyles.buttonTextSize,
                          fontWeight: FontWeight.w500,
                          color: BannerDeleteAllSpamEmailsStyles.buttonTextColor
                        )
                      ),
                      Text(
                        AppLocalizations.of(context).bannerDeleteAllSpamEmailsMessage,
                        style: const TextStyle(
                          color: BannerDeleteAllSpamEmailsStyles.labelTextColor,
                          fontSize: BannerDeleteAllSpamEmailsStyles.labelTextSize,
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
