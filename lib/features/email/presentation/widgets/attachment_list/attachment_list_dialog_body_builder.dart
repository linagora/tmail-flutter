import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/attachment/attachment_list_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_list/attachment_list_action_button_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_list/attachment_list_dialog_builder.dart';
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
  final OnCancelButtonAction? onCancelButtonAction;
  final OnCloseButtonAction? onCloseButtonAction;

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
    this.onCancelButtonAction,
    this.onCloseButtonAction
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                      AppLocalizations.of(context).attachmentList,
                      style: AttachmentListStyles.titleTextStyle
                  ),
                  const SizedBox(width: AttachmentListStyles.titleSpace),
                  Text(
                      '${attachments.length} ${AppLocalizations.of(context).files}',
                      style: AttachmentListStyles.subTitleTextStyle
                  ),
                  if (onCloseButtonAction != null)
                    const Spacer(),
                  buildIconWeb(
                    icon: SvgPicture.asset(imagePaths.icCircleClose),
                    onTap: () {
                      onCloseButtonAction!.call();
                    },
                  ),
                ],
              )
          ),
          Expanded(
            child: Padding(
              padding: AttachmentListStyles.listAreaPadding,
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
                child: Padding(
                  padding: AttachmentListStyles.listItemPadding,
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
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Padding(
                          padding: AttachmentListStyles.separatorPadding,
                          child: Divider(
                            height: AttachmentListStyles.separatorHeight,
                            color: AttachmentListStyles.separatorColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onDownloadAllButtonAction != null)
                AttachmentListActionButtonBuilder(
                    name: AppLocalizations.of(context).downloadAll,
                    bgColor: AttachmentListStyles.downloadAllButtonColor,
                    textStyle: AttachmentListStyles.downloadAllButtonTextStyle
                ),
              if (onDownloadAllButtonAction != null && onCancelButtonAction != null)
                const SizedBox(width: AttachmentListStyles.buttonsSpaceBetween),
              if (onCancelButtonAction != null)
                AttachmentListActionButtonBuilder(
                    name: AppLocalizations.of(context).close,
                    bgColor: AttachmentListStyles.cancelButtonColor,
                    borderColor: AttachmentListStyles.cancelButtonBorderColor,
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
