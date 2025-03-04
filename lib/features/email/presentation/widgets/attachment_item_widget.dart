import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
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
import 'package:tmail_ui_user/features/email/presentation/styles/attachment/attachment_item_widget_style.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

typedef OnDownloadAttachmentFileAction = void Function(Attachment attachment);
typedef OnViewAttachmentFileAction = void Function(Attachment attachment);

class AttachmentItemWidget extends StatelessWidget {

  final Attachment attachment;
  final OnDownloadAttachmentFileAction? downloadAttachmentAction;
  final OnViewAttachmentFileAction? viewAttachmentAction;

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  AttachmentItemWidget({
    Key? key,
    required this.attachment,
    this.downloadAttachmentAction,
    this.viewAttachmentAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final controller = Get.find<SingleEmailController>();
        final attachmentsViewState = controller.attachmentsViewState;
        bool isLoading = false;
        if (attachment.blobId != null) {
          isLoading = !EmailUtils.checkingIfAttachmentActionIsEnabled(
            attachmentsViewState[attachment.blobId!]);
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : () => (viewAttachmentAction ?? downloadAttachmentAction)?.call(attachment),
            customBorder: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AttachmentItemWidgetStyle.radius))
            ),
            child: Container(
              padding: AttachmentItemWidgetStyle.contentPadding,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(AttachmentItemWidgetStyle.radius)),
                border: Border.all(color: AttachmentItemWidgetStyle.borderColor),
              ),
              width: AttachmentItemWidgetStyle.getMaxWidthItem(
                platformIsMobile: PlatformInfo.isMobile,
                responsiveIsMobile: _responsiveUtils.isMobile(context),
                responsiveIsTablet: _responsiveUtils.isTablet(context),
                responsiveIsTabletLarge: _responsiveUtils.isTabletLarge(context),
              ),
              child: Row(
                children: [
                  isLoading
                    ? const SizedBox(
                        width: AttachmentItemWidgetStyle.iconSize,
                        height: AttachmentItemWidgetStyle.iconSize,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : SvgPicture.asset(attachment.getIcon(_imagePaths),
                        width: AttachmentItemWidgetStyle.iconSize,
                        height: AttachmentItemWidgetStyle.iconSize,
                        fit: BoxFit.fill
                      ),
                  const SizedBox(width: AttachmentItemWidgetStyle.space),
                  Expanded(
                    child: PlatformInfo.isCanvasKit
                      ? ExtendedText(
                          (attachment.name ?? ''),
                          maxLines: 1,
                          overflowWidget: const TextOverflowWidget(
                            position: TextOverflowPosition.middle,
                            clearType: TextOverflowClearType.clipRect,
                            child: Text(
                              "...",
                              style: AttachmentItemWidgetStyle.dotsLabelTextStyle,
                            ),
                          ),
                          style: AttachmentItemWidgetStyle.labelTextStyle,
                        )
                      : Text(
                          (attachment.name ?? ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AttachmentItemWidgetStyle.labelTextStyle,
                        )
                  ),
                  const SizedBox(width: AttachmentItemWidgetStyle.space),
                  Text(
                    filesize(attachment.size?.value),
                    maxLines: 1,
                    style: AttachmentItemWidgetStyle.sizeLabelTextStyle,
                  ),
                  TMailButtonWidget.fromIcon(
                    icon: _imagePaths.icDownloadAttachment,
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.all(5),
                    iconSize: AttachmentItemWidgetStyle.downloadIconSize,
                    onTapActionCallback: isLoading
                      ? null 
                      : () => downloadAttachmentAction?.call(attachment)
                  )
                ]
              )
            ),
          ),
        );
      }
    );
  }
}