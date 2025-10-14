import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AttachmentsInfo extends StatelessWidget {
  const AttachmentsInfo({
    super.key,
    required this.imagePaths,
    required this.numberOfAttachments,
    required this.totalSizeInfo,
    required this.responsiveUtils,
    this.displayShowAll = false,
    this.onTapShowAllAttachmentFile,
    this.onTapDownloadAllButton,
  });

  final ImagePaths imagePaths;
  final int numberOfAttachments;
  final String totalSizeInfo;
  final ResponsiveUtils responsiveUtils;
  final bool displayShowAll;
  final VoidCallback? onTapShowAllAttachmentFile;
  final VoidCallback? onTapDownloadAllButton;

  @override
  Widget build(BuildContext context) {
    final iconAttachment = SvgPicture.asset(
      imagePaths.icAttachment,
      width: 14,
      height: 14,
      colorFilter: AppColor.gray959DAD.asFilter(),
      fit: BoxFit.fill,
    );

    final titleHeaderAttachment = Text(
      numberOfAttachments > 1
        ? AppLocalizations.of(context).titleHeaderAttachment(
            numberOfAttachments,
            totalSizeInfo,
          )
        : AppLocalizations.of(context).singularAttachmentTitleHeader(
            numberOfAttachments,
            totalSizeInfo,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: ThemeUtils.textStyleInter400.copyWith(
        fontSize: 15,
        height: 20 / 15,
        letterSpacing: -0.24,
        color: AppColor.gray99A2AD,
      ),
    );

    return Row(
      children: [
        iconAttachment,
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 8, end: 3),
            child: titleHeaderAttachment,
          ),
        ),
        if (onTapDownloadAllButton != null)
          TMailButtonWidget(
            key: const Key('download_all_attachments_button'),
            text: AppLocalizations.of(context).downloadAll,
            icon: !responsiveUtils.isMobile(context)
                ? imagePaths.icDownloadAttachment
                : imagePaths.icDownloadAll,
            iconSize: 20,
            iconColor: AppColor.steelGrayA540,
            iconAlignment: TextDirection.rtl,
            backgroundColor: Colors.transparent,
            borderRadius: 5,
            mainAxisSize: MainAxisSize.min,
            flexibleText: true,
            maxLines: 1,
            maxWidth: 300,
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            textStyle: ThemeUtils.textStyleBodyBody1().copyWith(
              color: AppColor.steelGray400,
            ),
            onTapActionCallback: onTapDownloadAllButton,
          ),
      ],
    );
  }
}
