import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_attachments_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AttachmentsInfo extends StatelessWidget {
  const AttachmentsInfo({
    super.key,
    required this.imagePaths,
    required this.numberOfAttachments,
    required this.totalSizeInfo,
    required this.responsiveUtils,
    this.onTapShowAllAttachmentFile,
    this.downloadAllEnabled = false,
    this.onTapDownloadAllButton,
  });

  final ImagePaths imagePaths;
  final int numberOfAttachments;
  final String totalSizeInfo;
  final ResponsiveUtils responsiveUtils;
  final VoidCallback? onTapShowAllAttachmentFile;
  final bool downloadAllEnabled;
  final VoidCallback? onTapDownloadAllButton;

  @override
  Widget build(BuildContext context) {
    List<Widget> attachmentsAmountAndSize = [
      SvgPicture.asset(
        imagePaths.icAttachment,
        width: EmailAttachmentsStyles.headerIconSize,
        height: EmailAttachmentsStyles.headerIconSize,
        colorFilter: EmailAttachmentsStyles.headerIconColor.asFilter(),
        fit: BoxFit.fill
      ),
      const SizedBox(width: EmailAttachmentsStyles.headerSpace),
      Text(
        AppLocalizations.of(context).titleHeaderAttachment(
          numberOfAttachments,
          totalSizeInfo,
        ),
        style: const TextStyle(
          fontSize: EmailAttachmentsStyles.headerTextSize,
          fontWeight: EmailAttachmentsStyles.headerFontWeight,
          color: EmailAttachmentsStyles.headerTextColor
        )
      ),
    ];

    final showAllAttachments = (numberOfAttachments > 2)
      ? TMailButtonWidget(
          text: AppLocalizations.of(context).showAll,
          backgroundColor: Colors.transparent,
          borderRadius: EmailAttachmentsStyles.buttonBorderRadius,
          padding: EmailAttachmentsStyles.buttonPadding,
          textStyle: const TextStyle(
            fontSize: EmailAttachmentsStyles.buttonTextSize,
            color: EmailAttachmentsStyles.buttonTextColor,
            fontWeight: EmailAttachmentsStyles.buttonFontWeight
          ),
          onTapActionCallback: onTapShowAllAttachmentFile,
        )
      : const SizedBox.shrink();

    List<Widget> downloadAllAttachments = downloadAllEnabled && !responsiveUtils.isMobile(context)
      ? [
          const Spacer(),
          TMailButtonWidget(
            text: AppLocalizations.of(context).downloadAll,
            icon: imagePaths.icDownloadAll,
            iconAlignment: TextDirection.rtl,
            backgroundColor: Colors.transparent,
            borderRadius: EmailAttachmentsStyles.buttonBorderRadius,
            padding: EmailAttachmentsStyles.buttonPadding,
            textStyle: const TextStyle(
              fontSize: EmailAttachmentsStyles.buttonTextSize,
              color: EmailAttachmentsStyles.buttonTextColor,
              fontWeight: EmailAttachmentsStyles.buttonFontWeight
            ),
            onTapActionCallback: onTapDownloadAllButton,
          ),
        ]
      : const [];

    return Row(
      children: [
        ...attachmentsAmountAndSize,
        if (!PlatformInfo.isWeb) const Spacer(),
        showAllAttachments,
        ...downloadAllAttachments,
      ],
    );
  }
}