import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:extended_text/extended_text.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/attachment/attachment_list_item_widget_styles.dart';

typedef OnDownloadAttachmentFileActionClick = void Function(Attachment attachment);

class AttachmentListItemWidget extends StatelessWidget {

  final Attachment attachment;
  final OnDownloadAttachmentFileActionClick? downloadAttachmentAction;

  final _imagePaths = Get.find<ImagePaths>();

  AttachmentListItemWidget({
    Key? key,
    required this.attachment,
    this.downloadAttachmentAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => downloadAttachmentAction?.call(attachment),
        child: Padding(
          padding: AttachmentListItemWidgetStyle.contentPadding,
          child: Row(
            children: [
              SvgPicture.asset(
                attachment.getIcon(_imagePaths),
                width: AttachmentListItemWidgetStyle.iconSize,
                height: AttachmentListItemWidgetStyle.iconSize,
                fit: BoxFit.fill
              ),
              const SizedBox(width: AttachmentListItemWidgetStyle.space),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (PlatformInfo.isCanvasKit)
                      ExtendedText(
                        (attachment.name ?? ''),
                        maxLines: 1,
                        overflowWidget: const TextOverflowWidget(
                          position: TextOverflowPosition.middle,
                          child: Text(
                            "...",
                            style: AttachmentListItemWidgetStyle.dotsLabelTextStyle,
                          ),
                        ),
                        style: AttachmentListItemWidgetStyle.labelTextStyle,
                      )
                    else
                     Text(
                        (attachment.name ?? ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AttachmentListItemWidgetStyle.labelTextStyle,
                      ),
                    const SizedBox(height: AttachmentListItemWidgetStyle.fileTitleBottomSpace),
                    Text(
                      filesize(attachment.size?.value),
                      maxLines: 1,
                      overflow: CommonTextStyle.defaultTextOverFlow,
                      softWrap: CommonTextStyle.defaultSoftWrap,
                      style: AttachmentListItemWidgetStyle.sizeLabelTextStyle,
                    )
                  ]
                )
              ),
              const SizedBox(width: AttachmentListItemWidgetStyle.space),
              TMailButtonWidget.fromIcon(
                icon: _imagePaths.icDownloadAttachment,
                backgroundColor: Colors.transparent,
                onTapActionCallback: () => downloadAttachmentAction?.call(attachment)
              )
            ]
          ),
        ),
      ),
    );
  }
}