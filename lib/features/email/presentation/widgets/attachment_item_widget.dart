import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/container/tmail_container_widget.dart';
import 'package:core/presentation/views/text/middle_ellipsis_text.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

typedef OnDownloadAttachmentFileAction = void Function(Attachment attachment);
typedef OnViewAttachmentFileAction = void Function(Attachment attachment);

class AttachmentItemWidget extends StatelessWidget {

  final Attachment attachment;
  final ImagePaths imagePaths;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final OnDownloadAttachmentFileAction? downloadAttachmentAction;
  final OnViewAttachmentFileAction? viewAttachmentAction;
  final String? singleEmailControllerTag;

  const AttachmentItemWidget({
    Key? key,
    required this.attachment,
    required this.imagePaths,
    this.width,
    this.margin,
    this.downloadAttachmentAction,
    this.viewAttachmentAction,
    this.singleEmailControllerTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<SingleEmailController>(tag: singleEmailControllerTag);
      final attachmentsViewState = controller.attachmentsViewState;
      bool isLoading = false;
      if (attachment.blobId != null) {
        isLoading = !EmailUtils.checkingIfAttachmentActionIsEnabled(
            attachmentsViewState[attachment.blobId!]);
      }

      const loadingIndicator = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );

      final attachmentIcon = SvgPicture.asset(
        attachment.getIcon(imagePaths),
        width: 20,
        height: 20,
        fit: BoxFit.fill,
      );

      final attachmentTitleWithMiddleDots = MiddleEllipsisText(
        attachment.generateFileName(),
        style: ThemeUtils.textStyleM3LabelLarge(
          color: AppColor.m3SurfaceBackground,
        ),
      );

      final bodyItemWidget = Row(
        children: [
          isLoading ? loadingIndicator : attachmentIcon,
          const SizedBox(width: 8),
          Expanded(
            child: attachmentTitleWithMiddleDots,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8, end: 3),
            child: Text(
              filesize(attachment.size?.value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ThemeUtils.textStyleM3LabelSmall,
            ),
          ),
          TMailButtonWidget.fromIcon(
            icon: imagePaths.icDownloadAttachment,
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.all(5),
            iconColor: AppColor.primaryColor,
            iconSize: 20,
            onTapActionCallback:
                isLoading ? null : () => _onTapDownloadAction(attachment),
          )
        ],
      );

      return TMailContainerWidget(
        height: EmailUtils.attachmentItemHeight,
        borderRadius: 8,
        border: Border.all(color: AppColor.m3Tertiary70),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        backgroundColor: Colors.transparent,
        width: width,
        margin: margin,
        onTapActionCallback:
            isLoading ? null : () => _onViewOrDownloadAction(attachment),
        child: bodyItemWidget,
      );
    });
  }

  void _onTapDownloadAction(Attachment attachment) {
    downloadAttachmentAction?.call(attachment);
  }

  void _onViewOrDownloadAction(Attachment attachment) {
    (viewAttachmentAction ?? downloadAttachmentAction)?.call(attachment);
  }
}