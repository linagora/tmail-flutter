import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/draggable_attachment_item_widget.dart';

class EmailAttachmentsPinBodyWidget extends StatelessWidget {
  final List<Attachment> attachments;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final String? singleEmailControllerTag;
  final OnDragAttachmentStarted? onDragStarted;
  final OnDragAttachmentEnd? onDragEnd;
  final OnDownloadAttachmentFileAction? downloadAttachmentAction;
  final OnViewAttachmentFileAction? viewAttachmentAction;

  const EmailAttachmentsPinBodyWidget({
    super.key,
    required this.attachments,
    required this.imagePaths,
    required this.responsiveUtils,
    this.singleEmailControllerTag,
    this.onDragStarted,
    this.onDragEnd,
    this.downloadAttachmentAction,
    this.viewAttachmentAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      constraints: const BoxConstraints(maxHeight: 150),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: attachments.map((attachment) {
            if (PlatformInfo.isWeb && responsiveUtils.isDesktop(context)) {
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
                width: responsiveUtils.isMobile(context)
                  ? double.infinity
                  : EmailUtils.desktopItemMaxWidth,
                downloadAttachmentAction: downloadAttachmentAction,
                viewAttachmentAction: viewAttachmentAction,
                singleEmailControllerTag: singleEmailControllerTag,
              );
            }
          }).toList(),
        ),
      ),
    );
  }
}
