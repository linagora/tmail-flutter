
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

typedef OnDownloadAttachmentFileActionClick = void Function(Attachment attachment);
typedef OnExpandAttachmentActionClick = void Function();

class AttachmentFileTileBuilder extends StatelessWidget{

  final Attachment _attachment;
  final OnDownloadAttachmentFileActionClick? onDownloadAttachmentFileActionClick;

  const AttachmentFileTileBuilder(
    this._attachment, {
    Key? key,
    this.onDownloadAttachmentFileActionClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();
    final responsiveUtils = Get.find<ResponsiveUtils>();

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onDownloadAttachmentFileActionClick?.call(_attachment),
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.attachmentFileBorderColor),
              color: Colors.transparent),
            width: responsiveUtils.isMobile(context) ? 224 : 250,
            height: 60,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Row(children: [
                    SvgPicture.asset(
                        _attachment.getIcon(imagePaths),
                        width: 44,
                        height: 44,
                        fit: BoxFit.fill),
                    const SizedBox(width: 8),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExtendedText(
                          (_attachment.name ?? ''),
                          maxLines: 1,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          overflowWidget: TextOverflowWidget(
                            position: Directionality.maybeOf(context) == TextDirection.rtl
                              ? TextOverflowPosition.start
                              : TextOverflowPosition.end,
                            child: const Text(
                              "...",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.attachmentFileNameColor,
                                fontWeight: FontWeight.normal
                              ),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColor.attachmentFileNameColor,
                            fontWeight: FontWeight.normal
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          filesize(_attachment.size?.value),
                          maxLines: 1,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColor.attachmentFileSizeColor,
                            fontWeight: FontWeight.normal),
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
                        imagePaths.icDownloadAttachment,
                        width: 24,
                        height: 24,
                        colorFilter: AppColor.primaryColor.asFilter(),
                        fit: BoxFit.fill),
                      onTap: () => onDownloadAttachmentFileActionClick?.call(_attachment)
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