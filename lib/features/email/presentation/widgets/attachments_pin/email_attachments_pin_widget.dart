import 'package:core/presentation/action/action_callback_define.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/list_attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachments_pin/email_attachments_pin_body_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachments_pin/email_attachments_pin_header_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/draggable_attachment_item_widget.dart';

class EmailAttachmentsPinWidget extends StatefulWidget {
  final List<Attachment> attachments;
  final String? singleEmailControllerTag;
  final OnDragAttachmentStarted? onDragStarted;
  final OnDragAttachmentEnd? onDragEnd;
  final OnDownloadAttachmentFileAction? onDownloadAttachmentFileAction;
  final OnViewAttachmentFileAction? onViewAttachmentFileAction;
  final OnTapActionCallback? onDownloadAllAttachmentsAction;

  const EmailAttachmentsPinWidget({
    super.key,
    required this.attachments,
    this.singleEmailControllerTag,
    this.onDragStarted,
    this.onDragEnd,
    this.onDownloadAttachmentFileAction,
    this.onViewAttachmentFileAction,
    this.onDownloadAllAttachmentsAction,
  });

  @override
  State<EmailAttachmentsPinWidget> createState() =>
      _EmailAttachmentsPinWidgetState();
}

class _EmailAttachmentsPinWidgetState extends State<EmailAttachmentsPinWidget> {
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  bool _isCollapsed = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColor.colorShadowBgContentEmail,
            blurRadius: 24,
          ),
          BoxShadow(
            color: AppColor.colorShadowBgContentEmail,
            blurRadius: 2,
          ),
        ],
      ),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EmailAttachmentsPinHeaderWidget(
            countAttachments: widget.attachments.length,
            totalSizeAttachments: widget.attachments.totalSize,
            isCollapsed: _isCollapsed,
            imagePaths: _imagePaths,
            isMobile: _responsiveUtils.isMobile(context),
            onToggleExpandAction: _toggleExpand,
            onDownloadAllAttachmentsAction:
              widget.onDownloadAllAttachmentsAction,
          ),
          if (!_isCollapsed)
            EmailAttachmentsPinBodyWidget(
              attachments: widget.attachments,
              imagePaths: _imagePaths,
              responsiveUtils: _responsiveUtils,
              singleEmailControllerTag: widget.singleEmailControllerTag,
              onDragStarted: widget.onDragStarted,
              onDragEnd: widget.onDragEnd,
              downloadAttachmentAction: widget.onDownloadAttachmentFileAction,
              viewAttachmentAction: widget.onViewAttachmentFileAction,
            ),
        ],
      ),
    );
  }

  void _toggleExpand(bool newIsCollapsed) {
    if (mounted) {
      setState(() => _isCollapsed = newIsCollapsed);
    }
  }
}
