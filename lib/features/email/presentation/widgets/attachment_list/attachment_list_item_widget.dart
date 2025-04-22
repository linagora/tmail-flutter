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
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/attachment/attachment_list_item_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';

class AttachmentListItemWidget extends StatelessWidget {

  final Attachment attachment;
  final OnDownloadAttachmentFileAction? downloadAttachmentAction;
  final OnViewAttachmentFileAction? viewAttachmentAction;
  final String? singleEmailControllerTag;

  final _imagePaths = Get.find<ImagePaths>();

  AttachmentListItemWidget({
    Key? key,
    required this.attachment,
    this.downloadAttachmentAction,
    this.viewAttachmentAction,
    this.singleEmailControllerTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final controller = Get.find<SingleEmailController>(tag: singleEmailControllerTag);
        final attachmentsViewState = controller.attachmentsViewState;
        bool isLoading = false;
        if (attachment.blobId != null) {
          isLoading = !EmailUtils.checkingIfAttachmentActionIsEnabled(
            attachmentsViewState[attachment.blobId!]);
        }

        return Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: isLoading ? null : () => (viewAttachmentAction?? downloadAttachmentAction)?.call(attachment),
            child: Padding(
              padding: AttachmentListItemWidgetStyle.contentPadding,
              child: Row(
                children: [
                  isLoading
                    ? const SizedBox(
                        width: AttachmentListItemWidgetStyle.iconSize,
                        height: AttachmentListItemWidgetStyle.iconSize,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : SvgPicture.asset(attachment.getIcon(_imagePaths),
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
                              clearType: TextOverflowClearType.clipRect,
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
                    onTapActionCallback: isLoading
                      ? null 
                      : () => downloadAttachmentAction?.call(attachment)
                  )
                ]
              ),
            ),
          ),
        );
      }
    );
  }
}