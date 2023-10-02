
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:extended_text/extended_text.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/attachment/attachment_item_widget_style.dart';

typedef OnDownloadAttachmentFileActionClick = void Function(Attachment attachment);

class AttachmentItemWidget extends StatelessWidget {

  final Attachment attachment;
  final OnDownloadAttachmentFileActionClick? downloadAttachmentAction;

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  AttachmentItemWidget({
    Key? key,
    required this.attachment,
    this.downloadAttachmentAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AttachmentItemWidgetStyle.padding,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => downloadAttachmentAction?.call(attachment),
          customBorder: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AttachmentItemWidgetStyle.radius))
          ),
          child: Container(
            padding: AttachmentItemWidgetStyle.contentPadding,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(AttachmentItemWidgetStyle.radius)),
              border: Border.all(color: AttachmentItemWidgetStyle.borderColor),
            ),
            width: _responsiveUtils.isMobile(context)
              ? AttachmentItemWidgetStyle.mobileWidth
              : AttachmentItemWidgetStyle.width,
            height: AttachmentItemWidgetStyle.height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Row(children: [
                    SvgPicture.asset(
                      attachment.getIcon(_imagePaths),
                      width: AttachmentItemWidgetStyle.iconSize,
                      height: AttachmentItemWidgetStyle.iconSize,
                      fit: BoxFit.fill
                    ),
                    const SizedBox(width: AttachmentItemWidgetStyle.space),
                    Expanded(child: Column(
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
                              style: AttachmentItemWidgetStyle.dotsLabelTextStyle,
                            ),
                          ),
                          style: AttachmentItemWidgetStyle.labelTextStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          filesize(attachment.size?.value),
                          maxLines: 1,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          style: AttachmentItemWidgetStyle.sizeLabelTextStyle,
                        )
                      ]
                    ))
                  ]),
                ),
                Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      child: SvgPicture.asset(
                        _imagePaths.icDownloadAttachment,
                        width: AttachmentItemWidgetStyle.downloadIconSize,
                        height: AttachmentItemWidgetStyle.downloadIconSize,
                        colorFilter: AttachmentItemWidgetStyle.downloadIconColor.asFilter(),
                        fit: BoxFit.fill
                      ),
                      onTap: () => downloadAttachmentAction?.call(attachment)
                    ),
                  ),
                ),
              ]
            )
          ),
        ),
      ),
    );
  }
}