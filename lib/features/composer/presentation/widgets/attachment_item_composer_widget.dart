import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:extended_text/extended_text.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/attachment_item_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/attachment_progress_loading_composer_widget.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';

typedef OnDeleteAttachmentAction = void Function(UploadTaskId uploadTaskId);

class AttachmentItemComposerWidget extends StatelessWidget with AppLoaderMixin {

  final _imagePaths = Get.find<ImagePaths>();

  final UploadFileState fileState;
  final double? maxWidth;
  final EdgeInsetsGeometry? itemMargin;
  final OnDeleteAttachmentAction? onDeleteAttachmentAction;
  final Widget? buttonAction;

  AttachmentItemComposerWidget({
    super.key,
    required this.fileState,
    this.maxWidth,
    this.itemMargin,
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
      padding: AttachmentItemComposerWidgetStyle.padding,
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
                      fileState.getIcon(_imagePaths),
                      width: AttachmentItemComposerWidgetStyle.iconSize,
                      height: AttachmentItemComposerWidgetStyle.iconSize,
                      fit: BoxFit.fill
                    ),
                    const SizedBox(width: AttachmentItemComposerWidgetStyle.space),
                    Expanded(
                      child: PlatformInfo.isCanvasKit
                        ? ExtendedText(
                            fileState.fileName,
                            maxLines: 1,
                            overflowWidget: const TextOverflowWidget(
                              position: TextOverflowPosition.middle,
                              child: Text(
                                '...',
                                style: AttachmentItemComposerWidgetStyle.dotsLabelTextStyle,
                              ),
                            ),
                            style: AttachmentItemComposerWidgetStyle.labelTextStyle,
                          )
                        : Text(
                            fileState.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AttachmentItemComposerWidgetStyle.labelTextStyle,
                          )
                    ),
                    const SizedBox(width: AttachmentItemComposerWidgetStyle.space),
                    Text(
                      filesize(fileState.fileSize),
                      style: AttachmentItemComposerWidgetStyle.sizeLabelTextStyle
                    ),
                  ],
                ),
                AttachmentProgressLoadingComposerWidget(
                  fileState: fileState,
                  padding: AttachmentItemComposerWidgetStyle.progressLoadingPadding,
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
            onTapActionCallback: () => onDeleteAttachmentAction?.call(fileState.uploadTaskId),
          )
        ],
      ),
    );
  }
}