import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/container/tmail_container_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:extended_text/extended_text.dart';
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
  final OnDownloadAttachmentFileAction? downloadAttachmentAction;
  final OnViewAttachmentFileAction? viewAttachmentAction;

  const AttachmentItemWidget({
    Key? key,
    required this.attachment,
    required this.imagePaths,
    this.width,
    this.downloadAttachmentAction,
    this.viewAttachmentAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<SingleEmailController>();
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

      final attachmentTitleWithMiddleDots = ExtendedText(
        attachment.generateFileName(),
        maxLines: 1,
        overflowWidget: TextOverflowWidget(
          position: TextOverflowPosition.middle,
          clearType: TextOverflowClearType.clipRect,
          child: Text(
            "...",
            style: ThemeUtils.textStyleM3LabelLarge(
              color: AppColor.m3SurfaceBackground,
            ),
          ),
        ),
        style: ThemeUtils.textStyleM3LabelLarge(
          color: AppColor.m3SurfaceBackground,
        ),
      );

      final attachmentTitleWithEndDots = Text(
        attachment.generateFileName(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: ThemeUtils.textStyleM3LabelLarge(
          color: AppColor.m3SurfaceBackground,
        ),
      );

      final bodyItemWidget = Row(
        children: [
          isLoading ? loadingIndicator : attachmentIcon,
          const SizedBox(width: 8),
          Expanded(
            child: PlatformInfo.isCanvasKit
                ? attachmentTitleWithMiddleDots
                : attachmentTitleWithEndDots,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              filesize(attachment.size?.value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ThemeUtils.textStyleM3LabelSmall,
            ),
          ),
          TMailButtonWidget.fromIcon(
            icon: imagePaths.icFileDownload,
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.all(5),
            iconColor: AppColor.steelGrayA540,
            iconSize: 20,
            onTapActionCallback:
                isLoading ? null : () => _onTapDownloadAction(attachment),
          )
        ],
      );

      return TMailContainerWidget(
        height: 36,
        borderRadius: 8,
        border: Border.all(color: AppColor.m3Tertiary70),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        backgroundColor: Colors.transparent,
        width: width,
        margin: const EdgeInsets.only(top: 8),
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