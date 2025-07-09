import 'package:core/presentation/action/action_callback_define.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
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
    return LayoutBuilder(builder: (context, constraints) {
      final attachmentRecord = _getDisplayedAndHiddenAttachment(
        context,
        constraints.maxWidth,
      );

      final attachmentHeader = AttachmentsInfo(
        imagePaths: imagePaths,
        numberOfAttachments: attachments.length,
        totalSizeInfo: filesize(attachments.totalSize, 1),
        responsiveUtils: responsiveUtils,
        onTapShowAllAttachmentFile: onTapShowAllAttachmentFile,
        onTapDownloadAllButton: showDownloadAllAttachmentsButton
          ? onTapDownloadAllButton
          : null,
      );

      late Widget attachmentWidget;

      if (responsiveUtils.isMobile(context)) {
        attachmentWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
              child: attachmentHeader,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
              child: Column(
                children: attachmentRecord.displayedAttachments.map((attachment) {
                  return AttachmentItemWidget(
                    attachment: attachment,
                    imagePaths: imagePaths,
                    downloadAttachmentAction: downloadAttachmentAction,
                    viewAttachmentAction: viewAttachmentAction,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            if (attachmentRecord.hiddenItemsCount > 0 &&
                showDownloadAllAttachmentsButton)
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    TMailButtonWidget.fromText(
                      text: AppLocalizations.of(context).moreAttachments(
                        attachmentRecord.hiddenItemsCount,
                      ),
                      backgroundColor: Colors.transparent,
                      borderRadius: 5,
                      maxWidth: 120,
                      maxLines: 1,
                      textStyle: ThemeUtils.textStyleM3TitleSmall,
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 5,
                      ),
                      onTapActionCallback: onTapShowAllAttachmentFile,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: TMailButtonWidget(
                              text: AppLocalizations.of(context).archiveAndDownload,
                              icon: imagePaths.icDownloadAll,
                              iconSize: 20,
                              iconColor: AppColor.steelGrayA540,
                              iconAlignment: TextDirection.rtl,
                              backgroundColor: Colors.transparent,
                              borderRadius: 5,
                              mainAxisSize: MainAxisSize.min,
                              maxLines: 1,
                              flexibleText: true,
                              padding: const EdgeInsets.symmetric(
                                vertical: 3,
                                horizontal: 5,
                              ),
                              textStyle: ThemeUtils.textStyleBodyBody1().copyWith(
                                color: AppColor.steelGray400,
                              ),
                              onTapActionCallback: onTapDownloadAllButton,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else if (attachmentRecord.hiddenItemsCount > 0)
              TMailButtonWidget.fromText(
                text: AppLocalizations.of(context).moreAttachments(
                  attachmentRecord.hiddenItemsCount,
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
            else if (showDownloadAllAttachmentsButton)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: TMailButtonWidget(
                      text: AppLocalizations.of(context).archiveAndDownload,
                      icon: imagePaths.icDownloadAll,
                      iconSize: 20,
                      iconColor: AppColor.steelGrayA540,
                      iconAlignment: TextDirection.rtl,
                      backgroundColor: Colors.transparent,
                      borderRadius: 5,
                      mainAxisSize: MainAxisSize.min,
                      maxLines: 1,
                      flexibleText: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 5,
                      ),
                      margin: const EdgeInsetsDirectional.symmetric(horizontal: 8),
                      textStyle: ThemeUtils.textStyleBodyBody1().copyWith(
                        color: AppColor.steelGray400,
                      ),
                      onTapActionCallback: onTapDownloadAllButton,
                    ),
                  ),
                ],
              ),
          ],
        );
      } else {
        attachmentWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
              child: attachmentHeader,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: attachmentRecord.displayedAttachments.map((attachment) {
                  if (responsiveUtils.isDesktop(context)) {
                    return DraggableAttachmentItemWidget(
                      attachment: attachment,
                      imagePaths: imagePaths,
                      onDragStarted: onDragStarted,
                      onDragEnd: onDragEnd,
                      downloadAttachmentAction: downloadAttachmentAction,
                      viewAttachmentAction: viewAttachmentAction,
                    );
                  } else {
                    return AttachmentItemWidget(
                      attachment: attachment,
                      imagePaths: imagePaths,
                      width: 260,
                      downloadAttachmentAction: downloadAttachmentAction,
                      viewAttachmentAction: viewAttachmentAction,
                    );
                  }
                }).toList(),
              ),
            ),
          ],
        );
      }

      return Padding(
        padding: const EdgeInsetsDirectional.only(top: 12, bottom: 24),
        child: attachmentWidget,
      );
    });
  }

  ({List<Attachment> displayedAttachments, int hiddenItemsCount})
      _getDisplayedAndHiddenAttachment(BuildContext context, double maxWidth) {
    const itemSpace = 8.0;
    const itemHorizontalPadding = 24;
    final maxWidthDesktop = maxWidth - itemHorizontalPadding - itemSpace * 2;

    final displayedAttachments = EmailUtils.getAttachmentDisplayed(
      context: context,
      maxWidth: maxWidthDesktop,
      platformIsMobile: PlatformInfo.isMobile,
      attachments: attachments,
      responsiveUtils: responsiveUtils,
    );

    int hiddenItemsCount = attachments.length - displayedAttachments.length;
    if (hiddenItemsCount > 999) {
      hiddenItemsCount = 999;
    } else if (hiddenItemsCount < 0) {
      hiddenItemsCount = 0;
    }

    return (
      displayedAttachments: displayedAttachments,
      hiddenItemsCount: hiddenItemsCount,
    );
  }
}
