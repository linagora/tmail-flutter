import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/attachment/feedback_draggable_attachment_item_widget_style.dart';

class FeedbackDraggableAttachmentItemWidget extends StatelessWidget {

  final Attachment attachment;

  final _imagePaths = Get.find<ImagePaths>();

  FeedbackDraggableAttachmentItemWidget({
    super.key,
    required this.attachment
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(FeedbackDraggableAttachmentItemWidgetStyle.radius)),
        ),
        color: FeedbackDraggableAttachmentItemWidgetStyle.backgroundColor,
        shadows: FeedbackDraggableAttachmentItemWidgetStyle.shadows
      ),
      constraints: const BoxConstraints(
        maxWidth: FeedbackDraggableAttachmentItemWidgetStyle.maxWidth
      ),
      padding: FeedbackDraggableAttachmentItemWidgetStyle.padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            attachment.getIcon(_imagePaths),
            width: FeedbackDraggableAttachmentItemWidgetStyle.iconSize,
            height: FeedbackDraggableAttachmentItemWidgetStyle.iconSize,
            fit: BoxFit.fill
          ),
          const SizedBox(width: FeedbackDraggableAttachmentItemWidgetStyle.space),
          Flexible(
            child: PlatformInfo.isCanvasKit
              ? DefaultTextStyle(
                  style: FeedbackDraggableAttachmentItemWidgetStyle.labelTextStyle,
                  child: ExtendedText(
                    attachment.name ?? '',
                    maxLines: 1,
                    overflowWidget: TextOverflowWidget(
                      position: TextOverflowPosition.middle,
                      clearType: TextOverflowClearType.clipRect,
                      child: Text(
                        '...',
                        style: FeedbackDraggableAttachmentItemWidgetStyle.dotsLabelTextStyle,
                      ),
                    ),
                  ),
                )
              : Text(
                  attachment.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FeedbackDraggableAttachmentItemWidgetStyle.labelTextStyle,
                ),
          )
        ],
      ),
    );
  }
}