import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/list_attachment_extension.dart';
import 'package:tmail_ui_user/features/base/widget/custom_scroll_behavior.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_attachments_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/draggable_attachment_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailAttachmentsWidget extends StatefulWidget {

  final List<Attachment> attachments;
  final OnDragAttachmentStarted? onDragStarted;
  final OnDragAttachmentEnd? onDragEnd;
  final OnDownloadAttachmentFileActionClick? downloadAttachmentAction;

  const EmailAttachmentsWidget({
    super.key,
    required this.attachments,
    this.onDragStarted,
    this.onDragEnd,
    this.downloadAttachmentAction
  });

  @override
  State<EmailAttachmentsWidget> createState() => _EmailAttachmentsWidgetState();
}

class _EmailAttachmentsWidgetState extends State<EmailAttachmentsWidget> {

  final _imagePaths = Get.find<ImagePaths>();

  bool _isDisplayAll = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EmailAttachmentsStyles.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(width: EmailAttachmentsStyles.headerSpace),
                    SvgPicture.asset(
                      _imagePaths.icAttachment,
                      width: EmailAttachmentsStyles.headerIconSize,
                      height: EmailAttachmentsStyles.headerIconSize,
                      colorFilter: EmailAttachmentsStyles.headerIconColor.asFilter(),
                      fit: BoxFit.fill
                    ),
                    const SizedBox(width: EmailAttachmentsStyles.headerSpace),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).titleHeaderAttachment(
                          widget.attachments.length,
                          filesize(widget.attachments.totalSize(), 1)
                        ),
                        style: const TextStyle(
                          fontSize: EmailAttachmentsStyles.headerTextSize,
                          fontWeight: EmailAttachmentsStyles.headerFontWeight,
                          color: EmailAttachmentsStyles.headerTextColor
                        )
                      )
                    ),
                    const SizedBox(width: EmailAttachmentsStyles.headerSpace),
                  ]
                )
              ),
              if (widget.attachments.length > 2)
                TMailButtonWidget(
                  text: _isDisplayAll
                    ? AppLocalizations.of(context).hide
                    : AppLocalizations.of(context).showAll,
                  backgroundColor: Colors.transparent,
                  borderRadius: EmailAttachmentsStyles.buttonBorderRadius,
                  padding: EmailAttachmentsStyles.buttonPadding,
                  textStyle: const TextStyle(
                    fontSize: EmailAttachmentsStyles.buttonTextSize,
                    color: EmailAttachmentsStyles.buttonTextColor,
                    fontWeight: EmailAttachmentsStyles.buttonFontWeight
                  ),
                  onTapActionCallback: () => setState(() => _isDisplayAll = !_isDisplayAll),
                )
            ],
          ),
          const SizedBox(height: EmailAttachmentsStyles.marginHeader),
          if (_isDisplayAll)
            Wrap(
              runSpacing: EmailAttachmentsStyles.listSpace,
              children: widget.attachments
                .map((attachment) {
                  if (PlatformInfo.isWeb) {
                    return DraggableAttachmentItemWidget(
                      attachment: attachment,
                      onDragStarted: widget.onDragStarted,
                      onDragEnd: widget.onDragEnd,
                      downloadAttachmentAction: widget.downloadAttachmentAction,
                    );
                  } else {
                    return AttachmentItemWidget(
                      attachment: attachment,
                      downloadAttachmentAction: widget.downloadAttachmentAction
                    );
                  }
                })
                .toList()
            )
          else
            SizedBox(
              height: EmailAttachmentsStyles.listHeight,
              child: ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.attachments.length,
                  itemBuilder: (context, index) {
                    if (PlatformInfo.isWeb) {
                      return DraggableAttachmentItemWidget(
                        attachment: widget.attachments[index],
                        onDragStarted: widget.onDragStarted,
                        onDragEnd: widget.onDragEnd,
                        downloadAttachmentAction: widget.downloadAttachmentAction
                      );
                    } else {
                      return AttachmentItemWidget(
                        attachment: widget.attachments[index],
                        downloadAttachmentAction: widget.downloadAttachmentAction
                      );
                    }
                  }
                ),
              )
            ),
        ],
      ),
    );
  }
}
