import 'package:core/presentation/action/action_callback_define.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/list_attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_attachments_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachments_info.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/draggable_attachment_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailAttachmentsWidget extends StatelessWidget {

  final List<Attachment> attachments;
  final OnDragAttachmentStarted? onDragStarted;
  final OnDragAttachmentEnd? onDragEnd;
  final OnDownloadAttachmentFileAction? downloadAttachmentAction;
  final OnViewAttachmentFileAction? viewAttachmentAction;
  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final OnTapActionCallback? onTapShowAllAttachmentFile;
  final bool showDownloadAllAttachmentsButton;
  final OnTapActionCallback? onTapDownloadAllButton;

  const EmailAttachmentsWidget({
    super.key,
    required this.attachments,
    required this.responsiveUtils,
    required this.imagePaths,
    this.onDragStarted,
    this.onDragEnd,
    this.downloadAttachmentAction,
    this.viewAttachmentAction,
    this.onTapShowAllAttachmentFile,
    this.showDownloadAllAttachmentsButton = false,
    this.onTapDownloadAllButton,
  });

  @override
  Widget build(BuildContext context) {
    final attachmentDisplayed = _getAttachmentDisplayed(context);
    int hideItemsCount = attachments.length - attachmentDisplayed.length;
    return Padding(
      padding: EmailAttachmentsStyles.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AttachmentsInfo(
            imagePaths: imagePaths,
            numberOfAttachments: attachments.length,
            totalSizeInfo: filesize(attachments.totalSize, 1),
            responsiveUtils: responsiveUtils,
            onTapShowAllAttachmentFile: onTapShowAllAttachmentFile,
            downloadAllEnabled: showDownloadAllAttachmentsButton,
            onTapDownloadAllButton: onTapDownloadAllButton,
          ),
          const SizedBox(height: EmailAttachmentsStyles.marginHeader),
          Row(
            crossAxisAlignment: responsiveUtils.isMobile(context)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Wrap(
                  spacing: EmailAttachmentsStyles.listSpace,
                  runSpacing: EmailAttachmentsStyles.listSpace,
                  children: attachmentDisplayed.map((attachment) {
                    if (PlatformInfo.isWeb) {
                      return DraggableAttachmentItemWidget(
                          attachment: attachment,
                          onDragStarted: onDragStarted,
                          onDragEnd: onDragEnd,
                          downloadAttachmentAction: downloadAttachmentAction,
                          viewAttachmentAction: viewAttachmentAction,
                      );
                    } else {
                      return AttachmentItemWidget(
                          attachment: attachment,
                          downloadAttachmentAction: downloadAttachmentAction,
                          viewAttachmentAction: viewAttachmentAction,
                      );
                    }
                  }).toList(),
                ),
              ),
              if (hideItemsCount > 0 && !responsiveUtils.isMobile(context))
                TMailButtonWidget(
                  text: AppLocalizations.of(context).moreAttachments(hideItemsCount),
                  backgroundColor: Colors.transparent,
                  borderRadius: EmailAttachmentsStyles.buttonBorderRadius,
                  padding: EmailAttachmentsStyles.buttonPadding,
                  margin: EmailAttachmentsStyles.moreButtonMargin,
                  textStyle: const TextStyle(
                    fontSize: EmailAttachmentsStyles.buttonMoreAttachmentsTextSize,
                    color: EmailAttachmentsStyles.buttonMoreAttachmentsTextColor,
                    fontWeight: EmailAttachmentsStyles.buttonMoreAttachmentsFontWeight,
                  ),
                  onTapActionCallback: onTapShowAllAttachmentFile,
                ),
            ]
          ),
          const SizedBox(height: EmailAttachmentsStyles.marginHeader),
          if (responsiveUtils.isMobile(context))
            Row(
              children: [
                if (hideItemsCount > 0)
                  TMailButtonWidget(
                    text: AppLocalizations.of(context).moreAttachments(hideItemsCount),
                    backgroundColor: Colors.transparent,
                    borderRadius: EmailAttachmentsStyles.buttonBorderRadius,
                    padding: EdgeInsets.zero,
                    margin: EmailAttachmentsStyles.moreButtonMargin,
                    textStyle: const TextStyle(
                      fontSize: EmailAttachmentsStyles.buttonMoreAttachmentsTextSize,
                      color: EmailAttachmentsStyles.buttonMoreAttachmentsTextColor,
                      fontWeight: EmailAttachmentsStyles.buttonMoreAttachmentsFontWeight,
                    ),
                    onTapActionCallback: onTapShowAllAttachmentFile,
                  ),
                const Spacer(),
                if (showDownloadAllAttachmentsButton)
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
            ),
        ],
      ),
    );
  }

  List<Attachment> _getAttachmentDisplayed(BuildContext context) {
    if (attachments.length <= 2) {
      return attachments;
    }

    if (attachments.length == 3) {
      if (PlatformInfo.isWeb) {
        return responsiveUtils.isDesktop(context)
          ? attachments
          : attachments.sublist(0, 2);
      } else {
        return responsiveUtils.isMobile(context)
          ? attachments
          : attachments.sublist(0, 2);
      }
    }

    if (PlatformInfo.isWeb) {
      return responsiveUtils.isDesktop(context) || responsiveUtils.isMobile(context)
        ? attachments.sublist(0, 4)
        : attachments.sublist(0, 2);
    } else {
      return responsiveUtils.isMobile(context)
        ? attachments.sublist(0, 4)
        : attachments.sublist(0, 2);
    }
  }
}
