import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/attachment_item_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/attachment_progress_loading_composer_widget.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_status.dart';

typedef OnDeleteAttachmentAction = void Function(UploadTaskId uploadTaskId);

class AttachmentItemComposerWidget extends StatelessWidget with AppLoaderMixin {

  final _imagePaths = Get.find<ImagePaths>();

  final String fileIcon;
  final String fileName;
  final String fileSize;
  final UploadFileStatus uploadStatus;
  final double percentUploading;
  final UploadTaskId uploadTaskId;
  final double? maxWidth;
  final EdgeInsetsGeometry? itemMargin;
  final EdgeInsetsGeometry? itemPadding;
  final OnDeleteAttachmentAction? onDeleteAttachmentAction;
  final Widget? buttonAction;

  AttachmentItemComposerWidget({
    super.key,
    required this.fileIcon,
    required this.fileName,
    required this.fileSize,
    required this.uploadStatus,
    required this.percentUploading,
    required this.uploadTaskId,
    this.maxWidth,
    this.itemMargin,
    this.itemPadding,
    this.buttonAction,
    this.onDeleteAttachmentAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(AttachmentItemComposerWidgetStyle.radius)),
        border: Border.all(color: AttachmentItemComposerWidgetStyle.borderColor),
        color: AttachmentItemComposerWidgetStyle.backgroundColor
      ),
      width: AttachmentItemComposerWidgetStyle.width,
      padding: itemPadding ?? AttachmentItemComposerWidgetStyle.padding,
      margin: itemMargin,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      fileIcon,
                      width: AttachmentItemComposerWidgetStyle.iconSize,
                      height: AttachmentItemComposerWidgetStyle.iconSize,
                      fit: BoxFit.fill
                    ),
                    const SizedBox(width: AttachmentItemComposerWidgetStyle.space),
                    Expanded(
                      child: PlatformInfo.isCanvasKit
                        ? ExtendedText(
                            fileName,
                            maxLines: 1,
                            overflowWidget: TextOverflowWidget(
                              position: TextOverflowPosition.middle,
                              clearType: TextOverflowClearType.clipRect,
                              child: Text(
                                '...',
                                style: AttachmentItemComposerWidgetStyle.dotsLabelTextStyle,
                              ),
                            ),
                            style: AttachmentItemComposerWidgetStyle.labelTextStyle,
                          )
                        : Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AttachmentItemComposerWidgetStyle.labelTextStyle,
                          )
                    ),
                    const SizedBox(width: AttachmentItemComposerWidgetStyle.space),
                    Text(
                      fileSize,
                      style: AttachmentItemComposerWidgetStyle.sizeLabelTextStyle
                    ),
                  ],
                ),
                AttachmentProgressLoadingComposerWidget(
                  uploadStatus: uploadStatus,
                  percentUploading: percentUploading,
                )
              ],
            ),
          ),
          const SizedBox(width: AttachmentItemComposerWidgetStyle.space),
          TMailButtonWidget.fromIcon(
            icon: _imagePaths.icCancel,
            iconSize: AttachmentItemComposerWidgetStyle.deleteIconSize,
            borderRadius: AttachmentItemComposerWidgetStyle.deleteIconRadius,
            padding: AttachmentItemComposerWidgetStyle.deleteIconPadding,
            iconColor: AttachmentItemComposerWidgetStyle.deleteIconColor,
            onTapActionCallback: () => onDeleteAttachmentAction?.call(uploadTaskId),
          )
        ],
      ),
    );
  }
}