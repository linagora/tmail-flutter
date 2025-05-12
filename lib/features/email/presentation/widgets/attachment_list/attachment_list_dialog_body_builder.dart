import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/attachment/attachment_list_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_list/attachment_list_action_button_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_list/attachment_list_bottom_sheet_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_list/attachment_list_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AttachmentListDialogBodyBuilder extends StatelessWidget {
  final BuildContext context;
  final ImagePaths imagePaths;
  final List<Attachment> attachments;
  final ScrollController scrollController;
  final double? widthDialog;
  final double? heightDialog;
  final OnDownloadAllButtonAction? onDownloadAllButtonAction;
  final OnDownloadAttachmentFileAction? onDownloadAttachmentFileAction;
  final OnViewAttachmentFileAction? onViewAttachmentFileAction;
  final OnCancelButtonAction? onCancelButtonAction;
  final OnCloseButtonAction? onCloseButtonAction;
  final String? singleEmailControllerTag;

  const AttachmentListDialogBodyBuilder({
    super.key,
    required this.context,
    required this.imagePaths,
    required this.attachments,
    required this.scrollController,
    this.widthDialog,
    this.heightDialog,
    this.onDownloadAllButtonAction,
    this.onDownloadAttachmentFileAction,
    this.onViewAttachmentFileAction,
    this.onCancelButtonAction,
    this.onCloseButtonAction,
    this.singleEmailControllerTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthDialog,
      height: heightDialog,
      decoration: AttachmentListStyles.dialogBodyDecoration,
      child: Column(
        children: [
          Container(
              padding: AttachmentListStyles.headerPadding,
              decoration: AttachmentListStyles.headerDecoration,
              child: Row(
                children: [
                  const SizedBox(width: 50),
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context).attachmentList,
                              style: AttachmentListStyles.titleTextStyle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AttachmentListStyles.titleSpace),
                          Flexible(
                            child: Text(
                              '${attachments.length} ${AppLocalizations.of(context).files}',
                              style: AttachmentListStyles.subTitleTextStyle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    )
                  ),
                  const SizedBox(width: 8),
                  TMailButtonWidget.fromIcon(
                    icon: imagePaths.icCircleClose,
                    onTapActionCallback: onCloseButtonAction,
                    iconSize: 28,
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.all(5),
                  ),
                  const SizedBox(width: 8)
                ],
              )
          ),
          Expanded(
            child: RawScrollbar(
              trackColor: AttachmentListStyles.scrollbarTrackColor,
              thumbColor: AttachmentListStyles.scrollbarThumbColor,
              radius: AttachmentListStyles.scrollbarThumbRadius,
              trackRadius: AttachmentListStyles.scrollbarTrackRadius,
              thickness: AttachmentListStyles.scrollbarThickness,
              thumbVisibility: true,
              trackVisibility: true,
              controller: scrollController,
              trackBorderColor: AttachmentListStyles.scrollbarTrackBorderColor,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.separated(
                  controller: scrollController,
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemCount: attachments.length,
                  itemBuilder: (context, index) {
                    return AttachmentListItemWidget(
                      attachment: attachments[index],
                      downloadAttachmentAction: onDownloadAttachmentFileAction,
                      viewAttachmentAction: onViewAttachmentFileAction,
                      singleEmailControllerTag: singleEmailControllerTag,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: AttachmentListStyles.separatorColor,
                    );
                  },
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onDownloadAllButtonAction != null)
                AttachmentListActionButtonBuilder(
                    name: AppLocalizations.of(context).downloadAll,
                    bgColor: AppColor.primaryColor,
                    textStyle: AttachmentListStyles.downloadAllButtonTextStyle.copyWith(
                      color: Colors.white,
                    ),
                    action: onDownloadAllButtonAction,
                ),
              if (onDownloadAllButtonAction != null && onCancelButtonAction != null)
                const SizedBox(width: AttachmentListStyles.buttonsSpaceBetween),
              if (onCancelButtonAction != null)
                AttachmentListActionButtonBuilder(
                    name: AppLocalizations.of(context).close,
                    bgColor: AttachmentListStyles.cancelButtonColor,
                    textStyle: AttachmentListStyles.cancelButtonTextStyle
                )
            ],
          ),
          const SizedBox(height: AttachmentListStyles.dialogBottomSpace)
        ],
      ),
    );
  }
}
