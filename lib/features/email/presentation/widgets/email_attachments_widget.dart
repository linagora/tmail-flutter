import 'package:core/presentation/action/action_callback_define.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
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
  final OnTapActionCallback? onTapHideAllAttachments;
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
    this.onTapHideAllAttachments,
    this.showDownloadAllAttachmentsButton = false,
    this.isDisplayAllAttachments = false,
    this.onTapDownloadAllButton,
    this.singleEmailControllerTag,
  });

  @override
  Widget build(BuildContext context) {
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

    bool isMobileResponsive = responsiveUtils.isMobile(context);

    if (isMobileResponsive) {
      final attachmentRecord = _getDisplayedAndHiddenAttachment(
        context,
        isMobileResponsive,
        responsiveUtils.getDeviceWidth(context),
      );

      final displayedAttachments = isDisplayAllAttachments
          ? attachments
          : attachmentRecord.displayedAttachments;
      final hiddenItemsCount = isDisplayAllAttachments
          ? 0
          : attachmentRecord.hiddenItemsCount;

      return Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 16,
          end: 16,
          bottom: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            attachmentHeader,
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 4),
              child: Column(
                children: displayedAttachments.map((attachment) {
                  return AttachmentItemWidget(
                    attachment: attachment,
                    imagePaths: imagePaths,
                    margin: const EdgeInsets.only(
                      top: EmailUtils.attachmentItemSpacing,
                    ),
                    width: EmailUtils.desktopItemMaxWidth,
                    downloadAttachmentAction: downloadAttachmentAction,
                    viewAttachmentAction: viewAttachmentAction,
                    singleEmailControllerTag: singleEmailControllerTag,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: EmailUtils.attachmentItemSpacing),
            if (hiddenItemsCount > 0)
              SizedBox(
                height: EmailUtils.attachmentItemHeight,
                child: ConfirmDialogButton(
                  icon: imagePaths.icAttachment,
                  iconSize: 16,
                  iconColor: AppColor.steelGrayA540,
                  label: AppLocalizations.of(context).showMoreAttachmentButton(
                    hiddenItemsCount,
                  ),
                  textStyle: ThemeUtils.textStyleBodyBody1(
                    color: AppColor.steelGray400,
                  ),
                  radius: 5,
                  onTapAction: onTapShowAllAttachmentFile,
                ),
              ),
            if (isDisplayAllAttachments)
              SizedBox(
                height: EmailUtils.attachmentItemHeight,
                child: ConfirmDialogButton(
                  icon: imagePaths.icAttachment,
                  iconSize: 16,
                  iconColor: AppColor.steelGrayA540,
                  label: AppLocalizations.of(context).hideAttachmentButton(
                    attachmentRecord.hiddenItemsCount,
                  ),
                  textStyle: ThemeUtils.textStyleBodyBody1(
                    color: AppColor.steelGray400,
                  ),
                  radius: 5,
                  onTapAction: onTapHideAllAttachments,
                ),
              ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 8,
          end: 8,
          top: 12,
          bottom: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
              child: attachmentHeader,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 12,
                end: 12,
                top: 12,
              ),
              child: LayoutBuilder(
                  builder: (context, constraints) {
                    final attachmentRecord = _getDisplayedAndHiddenAttachment(
                      context,
                      isMobileResponsive,
                      constraints.maxWidth,
                    );
                    final displayedAttachments = isDisplayAllAttachments
                        ? attachments
                        : attachmentRecord.displayedAttachments;
                    final hiddenItemsCount = isDisplayAllAttachments
                        ? 0
                        : attachmentRecord.hiddenItemsCount;

                    return Wrap(
                      spacing: EmailUtils.attachmentItemSpacing,
                      runSpacing: isDisplayAllAttachments
                          ? EmailUtils.attachmentItemSpacing
                          : 0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ...displayedAttachments.map((attachment) {
                          if (PlatformInfo.isWeb &&
                              responsiveUtils.isDesktop(context)) {
                            return DraggableAttachmentItemWidget(
                              attachment: attachment,
                              imagePaths: imagePaths,
                              width: EmailUtils.desktopItemMaxWidth,
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
                              width: EmailUtils.desktopItemMaxWidth,
                              downloadAttachmentAction: downloadAttachmentAction,
                              viewAttachmentAction: viewAttachmentAction,
                              singleEmailControllerTag: singleEmailControllerTag,
                            );
                          }
                        }).toList(),
                        if (hiddenItemsCount > 0)
                          SizedBox(
                            height: EmailUtils.attachmentItemHeight,
                            child: ConfirmDialogButton(
                              icon: imagePaths.icAttachment,
                              iconSize: 16,
                              iconColor: AppColor.steelGrayA540,
                              label: AppLocalizations.of(context).showMoreAttachmentButton(
                                hiddenItemsCount,
                              ),
                              textStyle: ThemeUtils.textStyleBodyBody1(
                                color: AppColor.steelGray400,
                              ),
                              radius: 5,
                              onTapAction: onTapShowAllAttachmentFile,
                            ),
                          ),
                        if (isDisplayAllAttachments)
                          SizedBox(
                            height: EmailUtils.attachmentItemHeight,
                            child: ConfirmDialogButton(
                              icon: imagePaths.icAttachment,
                              iconSize: 16,
                              iconColor: AppColor.steelGrayA540,
                              label: AppLocalizations.of(context).hideAttachmentButton(
                                attachmentRecord.hiddenItemsCount,
                              ),
                              textStyle: ThemeUtils.textStyleBodyBody1(
                                color: AppColor.steelGray400,
                              ),
                              radius: 5,
                              onTapAction: onTapHideAllAttachments,
                            ),
                          ),
                      ],
                    );
                  }
              ),
            ),
          ],
        ),
      );
    }
  }

  ({List<Attachment> displayedAttachments, int hiddenItemsCount})
      _getDisplayedAndHiddenAttachment(
    BuildContext context,
    bool isMobile,
    double maxWidth,
  ) {
    final showMoreButtonMaxWidth = EmailUtils.estimateTextWidth(
      context: context,
      text: AppLocalizations.of(context).showMoreAttachmentButton(999),
      textStyle: ThemeUtils.textStyleBodyBody1(
        color: AppColor.steelGray400,
      ),
      locale: Localizations.localeOf(context),
    );

    final displayedAttachments = EmailUtils.getAttachmentDisplayed(
      maxWidth: maxWidth,
      attachments: attachments,
      isMobile: isMobile,
      showMoreButtonMaxWidth: showMoreButtonMaxWidth,
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
