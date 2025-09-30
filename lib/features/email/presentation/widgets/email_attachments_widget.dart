import 'package:core/presentation/action/action_callback_define.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/list_attachment_extension.dart';
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
  final bool isDisplayAllAttachments;
  final OnTapActionCallback? onTapDownloadAllButton;
  final String? singleEmailControllerTag;

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
    this.isDisplayAllAttachments = true,
    this.onTapDownloadAllButton,
    this.singleEmailControllerTag,
  });

  @override
  Widget build(BuildContext context) {
    final attachmentHeader = AttachmentsInfo(
      imagePaths: imagePaths,
      numberOfAttachments: attachments.length,
      totalSizeInfo: filesize(attachments.totalSize, 1),
      onTapDownloadAllButton: showDownloadAllAttachmentsButton
          ? onTapDownloadAllButton
          : null,
    );

    final isDesktop = responsiveUtils.isDesktop(context);
    final isMobile = responsiveUtils.isMobile(context);

    if (isMobile) {
      final attachmentRecord = _getDisplayedAndHiddenAttachment(
        isMobile,
        responsiveUtils.getDeviceWidth(context),
      );
      final displayedAttachments = attachmentRecord.displayedAttachments;
      final hiddenItemsCount = attachmentRecord.hiddenItemsCount;

      return Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 12,
          end: 12,
          bottom: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            attachmentHeader,
            Column(
              children: displayedAttachments.map((attachment) {
                return AttachmentItemWidget(
                  attachment: attachment,
                  imagePaths: imagePaths,
                  responsiveUtils: responsiveUtils,
                  margin: const EdgeInsets.only(top: 8),
                  downloadAttachmentAction: downloadAttachmentAction,
                  viewAttachmentAction: viewAttachmentAction,
                  singleEmailControllerTag: singleEmailControllerTag,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            if (hiddenItemsCount > 0)
              TMailButtonWidget.fromText(
                text: AppLocalizations.of(context).moreAttachments(
                  hiddenItemsCount,
                ),
                backgroundColor: Colors.transparent,
                borderRadius: 5,
                maxLines: 1,
                textStyle: ThemeUtils.textStyleM3TitleSmall,
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 5,
                ),
                margin: const EdgeInsetsDirectional.symmetric(horizontal: 8),
                onTapActionCallback: onTapShowAllAttachmentFile,
              )
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 16,
          end: 16,
          bottom: 28,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final attachmentRecord = _getDisplayedAndHiddenAttachment(
              isMobile,
              constraints.maxWidth,
            );
            final displayedAttachments = attachmentRecord.displayedAttachments;
            final hiddenItemsCount = attachmentRecord.hiddenItemsCount;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 12,
                    bottom: 28,
                  ),
                  child: attachmentHeader,
                ),
                Wrap(
                  spacing: 16,
                  runSpacing: isDisplayAllAttachments ? 16 : 0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...displayedAttachments.map((attachment) {
                      if (PlatformInfo.isWeb && isDesktop) {
                        return DraggableAttachmentItemWidget(
                          attachment: attachment,
                          imagePaths: imagePaths,
                          responsiveUtils: responsiveUtils,
                          onDragStarted: onDragStarted,
                          onDragEnd: onDragEnd,
                          downloadAttachmentAction: downloadAttachmentAction,
                          viewAttachmentAction: viewAttachmentAction,
                          singleEmailControllerTag: singleEmailControllerTag,
                        );
                      } else {
                        return AttachmentItemWidget(
                          attachment: attachment,
                          imagePaths: imagePaths,
                          responsiveUtils: responsiveUtils,
                          downloadAttachmentAction: downloadAttachmentAction,
                          viewAttachmentAction: viewAttachmentAction,
                          singleEmailControllerTag: singleEmailControllerTag,
                        );
                      }
                    }).toList(),
                    if (hiddenItemsCount > 0)
                      TMailButtonWidget.fromText(
                        text: '+ $hiddenItemsCount',
                        backgroundColor: Colors.transparent,
                        borderRadius: 5,
                        maxWidth: EmailUtils.desktopMoreButtonMaxWidth,
                        maxLines: 1,
                        textStyle: ThemeUtils.textStyleM3TitleSmall,
                        padding: const EdgeInsets.symmetric(
                          vertical: 3,
                          horizontal: 5,
                        ),
                        onTapActionCallback: onTapShowAllAttachmentFile,
                      ),
                  ],
                ),
              ],
            );
          }
        ),
      );
    }
  }

  ({List<Attachment> displayedAttachments, int hiddenItemsCount})
      _getDisplayedAndHiddenAttachment(bool isMobile, double maxWidth) {
    if (isDisplayAllAttachments) {
      return (displayedAttachments: attachments, hiddenItemsCount: 0);
    }

    final displayedAttachments = EmailUtils.getAttachmentDisplayed(
      maxWidth: maxWidth,
      attachments: attachments,
      isMobile: isMobile,
    );

    int hiddenItemsCount = attachments.length - displayedAttachments.length;
    if (hiddenItemsCount > 999) {
      hiddenItemsCount = 999;
    } else if (hiddenItemsCount < 0) {
      hiddenItemsCount = 0;
    }
    log('EmailAttachmentsWidget::_getDisplayedAndHiddenAttachment: Displayed: ${displayedAttachments.length}, Hidden: $hiddenItemsCount');
    return (
      displayedAttachments: displayedAttachments,
      hiddenItemsCount: hiddenItemsCount,
    );
  }
}
