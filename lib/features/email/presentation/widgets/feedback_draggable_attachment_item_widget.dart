import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/text/middle_ellipsis_text.dart';
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
            child: MiddleEllipsisText(
              attachment.name ?? '',
              style: FeedbackDraggableAttachmentItemWidgetStyle.dotsLabelTextStyle,
            ),
          )
        ],
      ),
    );
  }
}