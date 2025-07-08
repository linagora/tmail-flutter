import 'package:core/presentation/action/action_callback_define.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/list_attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_attachments_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
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

  Widget _buildMoreAttachmentButton(
    BuildContext context,
    int hideItemsCount, {
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return TMailButtonWidget(
      text: AppLocalizations.of(context).moreAttachments(hideItemsCount),
      backgroundColor: Colors.transparent,
      borderRadius: EmailAttachmentsStyles.buttonBorderRadius,
      padding: padding,
      maxWidth: EmailAttachmentsStyles.buttonMoreMaxWidth,
      margin: margin,
      textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
        fontSize: EmailAttachmentsStyles.buttonMoreAttachmentsTextSize,
        color: EmailAttachmentsStyles.buttonMoreAttachmentsTextColor,
        fontWeight: EmailAttachmentsStyles.buttonMoreAttachmentsFontWeight,
      ),
      maxLines: 1,
      onTapActionCallback: onTapShowAllAttachmentFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final attachmentDisplayed = EmailUtils.getAttachmentDisplayed(
        context: context,
        maxWidth: constraints.maxWidth
          - EmailAttachmentsStyles.padding.horizontal
          - EmailAttachmentsStyles.listSpace * 2,
        platformIsMobile: PlatformInfo.isMobile,
        attachments: attachments,
        responsiveUtils: responsiveUtils,
      );
      int hideItemsCount = attachments.length - attachmentDisplayed.length;
      if (hideItemsCount > 999) {
        hideItemsCount = 999;
      }
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
                  _buildMoreAttachmentButton(
                    context,
                    hideItemsCount,
                    padding: EmailAttachmentsStyles.buttonPadding,
                    margin: EmailAttachmentsStyles.moreButtonMargin,
                  ),
              ]
            ),
            const SizedBox(height: EmailAttachmentsStyles.marginHeader),
            if (responsiveUtils.isMobile(context))
              Row(
                children: [
                  if (hideItemsCount > 0)
                    _buildMoreAttachmentButton(
                      context,
                      hideItemsCount,
                      padding: EmailAttachmentsStyles.mobileButtonPadding,
                      margin: EmailAttachmentsStyles.mobileMoreButtonMargin,
                    ),
                  const Spacer(),
                  if (showDownloadAllAttachmentsButton)
                    TMailButtonWidget(
                      text: AppLocalizations.of(context).downloadAll,
                      icon: imagePaths.icDownloadAll,
                      iconAlignment: TextDirection.rtl,
                      backgroundColor: Colors.transparent,
                      borderRadius: EmailAttachmentsStyles.buttonBorderRadius,
                      padding: EmailAttachmentsStyles.mobileButtonPadding,
                      textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
                        fontSize: EmailAttachmentsStyles.buttonTextSize,
                        color: EmailAttachmentsStyles.buttonTextColor,
                        fontWeight: EmailAttachmentsStyles.buttonFontWeight
                      ),
                      maxWidth: EmailAttachmentsStyles.buttonDownloadAllMaxWidth,
                      maxLines: 1,
                      mainAxisSize: MainAxisSize.min,
                      flexibleText: true,
                      onTapActionCallback: onTapDownloadAllButton,
                    ),
                ]
              ),
          ],
        ),
      );
    });
  }
}
