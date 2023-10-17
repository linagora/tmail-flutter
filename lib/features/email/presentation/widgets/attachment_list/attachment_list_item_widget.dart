
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
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
      color: Colors.transparent,
      child: InkWell(
        onTap: () => downloadAttachmentAction?.call(attachment),
        child: Container(
          padding: AttachmentListItemWidgetStyle.contentPadding,
          height: AttachmentListItemWidgetStyle.height,
          child: Stack(
            children: [
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      attachment.getIcon(_imagePaths),
                      width: AttachmentListItemWidgetStyle.iconSize,
                      height: AttachmentListItemWidgetStyle.iconSize,
                      fit: BoxFit.fill
                    ),
                    const SizedBox(width: AttachmentListItemWidgetStyle.space),
                    Expanded(
                      child: Padding(
                        padding: AttachmentListItemWidgetStyle.fileTitlePadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ExtendedText(
                              (attachment.name ?? ''),
                              maxLines: 1,
                              overflow: CommonTextStyle.defaultTextOverFlow,
                              softWrap: CommonTextStyle.defaultSoftWrap,
                              overflowWidget: TextOverflowWidget(
                                position: Directionality.maybeOf(context) == TextDirection.rtl
                                  ? TextOverflowPosition.start
                                  : TextOverflowPosition.end,
                                child: const Text(
                                  "...",
                                  style: AttachmentListItemWidgetStyle.dotsLabelTextStyle,
                                ),
                              ),
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
                        ),
                      )
                    )
                  ]
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: AttachmentListItemWidgetStyle.downloadIconPadding,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      child: SvgPicture.asset(
                        _imagePaths.icDownloadAttachment,
                        width: AttachmentListItemWidgetStyle.downloadIconSize,
                        height: AttachmentListItemWidgetStyle.downloadIconSize,
                        colorFilter: AttachmentListItemWidgetStyle.downloadIconColor.asFilter(),
                        fit: BoxFit.fill
                      ),
                      onTap: () => downloadAttachmentAction?.call(attachment)
                    ),
                  ),
                ),
              ),
            ]
          )
        ),
      ),
    );
  }
}