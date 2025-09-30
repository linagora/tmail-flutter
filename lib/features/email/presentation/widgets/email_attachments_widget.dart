import 'package:core/presentation/action/action_callback_define.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
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
import 'package:tmail_ui_user/features/email/presentation/widgets/more_attachments_button.dart';

class EmailAttachmentsWidget extends StatefulWidget {

  final List<Attachment> attachments;
  final OnDragAttachmentStarted? onDragStarted;
  final OnDragAttachmentEnd? onDragEnd;
  final OnDownloadAttachmentFileAction? downloadAttachmentAction;
  final OnViewAttachmentFileAction? viewAttachmentAction;
  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
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
    this.showDownloadAllAttachmentsButton = false,
    this.isDisplayAllAttachments = false,
    this.onTapDownloadAllButton,
    this.singleEmailControllerTag,
  });

  @override
  State<EmailAttachmentsWidget> createState() => _EmailAttachmentsWidgetState();
}

class _EmailAttachmentsWidgetState extends State<EmailAttachmentsWidget> {

  bool _isShowAllAttachments = false;

  @override
  void initState() {
    super.initState();
    _isShowAllAttachments = widget.isDisplayAllAttachments;
  }

  @override
  Widget build(BuildContext context) {
    final attachmentHeader = AttachmentsInfo(
      imagePaths: widget.imagePaths,
      numberOfAttachments: widget.attachments.length,
      totalSizeInfo: filesize(widget.attachments.totalSize, 1),
      onTapDownloadAllButton: widget.showDownloadAllAttachmentsButton
          ? widget.onTapDownloadAllButton
          : null,
    );

    final isDesktop = widget.responsiveUtils.isDesktop(context);
    final isMobile = widget.responsiveUtils.isMobile(context);

    if (isMobile) {
      final attachmentRecord = _getDisplayedAndHiddenAttachment(
        isMobile,
        widget.responsiveUtils.getDeviceWidth(context),
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
                  imagePaths: widget.imagePaths,
                  responsiveUtils: widget.responsiveUtils,
                  margin: const EdgeInsets.only(top: 8),
                  downloadAttachmentAction: widget.downloadAttachmentAction,
                  viewAttachmentAction: widget.viewAttachmentAction,
                  singleEmailControllerTag: widget.singleEmailControllerTag,
                );
              }).toList(),
            ),
            if (hiddenItemsCount > 0)
              MoreAttachmentsButton(
                remainingAttachments: hiddenItemsCount,
                imagePaths: widget.imagePaths,
                isMobile: isMobile,
                margin: const EdgeInsets.only(top: 8),
                onShowAllAttachmentsAction: _showAllAttachmentAction,
              ),
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
                  runSpacing: _isShowAllAttachments ? 16 : 0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...displayedAttachments.map((attachment) {
                      if (PlatformInfo.isWeb && isDesktop) {
                        return DraggableAttachmentItemWidget(
                          attachment: attachment,
                          imagePaths: widget.imagePaths,
                          responsiveUtils: widget.responsiveUtils,
                          onDragStarted: widget.onDragStarted,
                          onDragEnd: widget.onDragEnd,
                          downloadAttachmentAction: widget.downloadAttachmentAction,
                          viewAttachmentAction: widget.viewAttachmentAction,
                          singleEmailControllerTag: widget.singleEmailControllerTag,
                        );
                      } else {
                        return AttachmentItemWidget(
                          attachment: attachment,
                          imagePaths: widget.imagePaths,
                          responsiveUtils: widget.responsiveUtils,
                          downloadAttachmentAction: widget.downloadAttachmentAction,
                          viewAttachmentAction: widget.viewAttachmentAction,
                          singleEmailControllerTag: widget.singleEmailControllerTag,
                        );
                      }
                    }).toList(),
                    if (hiddenItemsCount > 0)
                      MoreAttachmentsButton(
                        remainingAttachments: hiddenItemsCount,
                        imagePaths: widget.imagePaths,
                        isMobile: isMobile,
                        onShowAllAttachmentsAction: _showAllAttachmentAction,
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
    if (_isShowAllAttachments) {
      return (displayedAttachments: widget.attachments, hiddenItemsCount: 0);
    }

    final displayedAttachments = EmailUtils.getAttachmentDisplayed(
      maxWidth: maxWidth,
      attachments: widget.attachments,
      isMobile: isMobile,
    );

    int hiddenItemsCount = widget.attachments.length - displayedAttachments.length;
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

  void _showAllAttachmentAction() {
    if (mounted) {
      setState(() => _isShowAllAttachments = true);
    }
  }

  @override
  void dispose() {
    _isShowAllAttachments = false;
    super.dispose();
  }
}
