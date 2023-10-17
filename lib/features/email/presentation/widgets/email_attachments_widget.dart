import 'package:core/presentation/action/action_callback_define.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/list_attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_attachments_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/draggable_attachment_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailAttachmentsWidget extends StatelessWidget {

  final List<Attachment> attachments;
  final OnDragAttachmentStarted? onDragStarted;
  final OnDragAttachmentEnd? onDragEnd;
  final OnDownloadAttachmentFileActionClick? downloadAttachmentAction;
  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final OnTapActionCallback? onTapShowAllAttachmentFile;

  const EmailAttachmentsWidget({
    super.key,
    required this.attachments,
    required this.responsiveUtils,
    required this.imagePaths,
    this.onDragStarted,
    this.onDragEnd,
    this.downloadAttachmentAction,
    this.onTapShowAllAttachmentFile,
  });

  @override
  Widget build(BuildContext context) {
    int getItemCount() {
      if (attachments.length <= 2) {
        return attachments.length;
      }
      if (attachments.length == 3) {
        return responsiveUtils.isDesktop(context) ? attachments.length : 2;
      } 
      return responsiveUtils.isDesktop(context) ? 4 : 2;
    }
    int hideItemsCount = attachments.length - getItemCount();
    return Padding(
      padding: EmailAttachmentsStyles.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(width: EmailAttachmentsStyles.headerSpace),
                    SvgPicture.asset(
                      imagePaths.icAttachment,
                      width: EmailAttachmentsStyles.headerIconSize,
                      height: EmailAttachmentsStyles.headerIconSize,
                      colorFilter: EmailAttachmentsStyles.headerIconColor.asFilter(),
                      fit: BoxFit.fill
                    ),
                    const SizedBox(width: EmailAttachmentsStyles.headerSpace),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).titleHeaderAttachment(
                          attachments.length,
                          filesize(attachments.totalSize(), 1)
                        ),
                        style: const TextStyle(
                          fontSize: EmailAttachmentsStyles.headerTextSize,
                          fontWeight: EmailAttachmentsStyles.headerFontWeight,
                          color: EmailAttachmentsStyles.headerTextColor
                        )
                      )
                    ),
                    const SizedBox(width: EmailAttachmentsStyles.headerSpace),
                  ]
                )
              ),
              if (attachments.length > 2)
                TMailButtonWidget(
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
            ],
          ),
          const SizedBox(height: EmailAttachmentsStyles.marginHeader),
          SizedBox(
            height: responsiveUtils.isMobile(context) ? EmailAttachmentsStyles.mobileListHeight : EmailAttachmentsStyles.listHeight,
            child: Row(
              children: [
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: responsiveUtils.isMobile(context) ? Axis.vertical : Axis.horizontal,
                    itemCount: getItemCount(),
                    itemBuilder: (context, index) {
                      if (PlatformInfo.isWeb) {
                        return DraggableAttachmentItemWidget(
                          attachment: attachments[index],
                          onDragStarted: onDragStarted,
                          onDragEnd: onDragEnd,
                          downloadAttachmentAction: downloadAttachmentAction
                        );
                      } else {
                        return AttachmentItemWidget(
                          attachment: attachments[index],
                          downloadAttachmentAction: downloadAttachmentAction
                        );
                      }
                    },
                    separatorBuilder: (context, index) {
                      if (responsiveUtils.isMobile(context)) {
                        return const SizedBox(height: EmailAttachmentsStyles.listSpace);
                      } else {
                        return const SizedBox(width: EmailAttachmentsStyles.listSpace);
                      }
                    },
                  ),
                ),
                if (hideItemsCount != 0)
                  Container(
                    padding: EdgeInsets.only(bottom: responsiveUtils.isMobile(context) ? EmailAttachmentsStyles.moreAttachmentsButtonPadding : 0),
                    alignment: responsiveUtils.isMobile(context)
                      ? Alignment.bottomRight
                      : Alignment.centerRight,
                    child: TMailButtonWidget(
                      text: AppLocalizations.of(context).moreAttachments(hideItemsCount),
                      backgroundColor: Colors.transparent,
                      borderRadius: EmailAttachmentsStyles.buttonBorderRadius,
                      padding: EmailAttachmentsStyles.buttonPadding,
                      textStyle: const TextStyle(
                        fontSize: EmailAttachmentsStyles.buttonMoreAttachmentsTextSize,
                        color: EmailAttachmentsStyles.ButtonMoreAttachmentsTextColor,
                        fontWeight: EmailAttachmentsStyles.buttonMoreAttachmentsFontWeight,
                      ),
                      onTapActionCallback: onTapShowAllAttachmentFile,
                    ),
                  ),
              ]
            )
          ),
        ],
      ),
    );
  }
}
