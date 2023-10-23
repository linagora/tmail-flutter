import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/email/attachment.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/attachment/attachment_list_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_list/attachment_list_action_button_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_list/attachment_list_bottom_sheet_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_list/attachment_list_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AttachmentListBottomSheetBodyBuilder extends StatelessWidget {
  final ImagePaths imagePaths;
  final List<Attachment> attachments;
  final double statusBarHeight;
  final ScrollController scrollController;
  final OnDownloadAllButtonAction? onDownloadAllButtonAction;
  final OnDownloadAttachmentFileAction? onDownloadAttachmentFileAction;
  final OnCancelButtonAction? onCancelButtonAction;
  final OnCloseButtonAction? onCloseButtonAction;

  const AttachmentListBottomSheetBodyBuilder({
    super.key,
    required this.imagePaths,
    required this.attachments,
    required this.statusBarHeight,
    required this.scrollController,
    this.onDownloadAllButtonAction,
    this.onDownloadAttachmentFileAction,
    this.onCancelButtonAction,
    this.onCloseButtonAction,
  });

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: SafeArea(
        top: true,
        bottom: false,
        left: false,
        right: false,
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Padding(
            padding: EdgeInsets.only(top: statusBarHeight),
            child: ClipRRect(
              borderRadius: AttachmentListStyles.modalRadius,
              child: Scaffold(
                appBar: AppBar(
                  leading: const SizedBox.shrink(),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context).attachmentList,
                        style: AttachmentListStyles.titleTextStyle
                      ),
                      const SizedBox(width: AttachmentListStyles.titleSpace),
                      Text(
                        '${attachments.length} ${AppLocalizations.of(context).files}',
                        style: AttachmentListStyles.subTitleTextStyle
                      ),
                    ],
                  ),
                  centerTitle: true,
                  actions: [
                    GestureDetector(
                      child: Padding(
                        padding: AttachmentListStyles.closeButtonPadding,
                        child: SvgPicture.asset(imagePaths.icCircleClose),
                      ),
                      onTapDown: (_) {
                        onCloseButtonAction?.call();
                      },
                    )
                  ],
                ),
                body: Container(
                  decoration: AttachmentListStyles.dialogBodyDecorationMobile,
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: AttachmentListStyles.listAreaPaddingMobile,
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
                      Padding(
                        padding: AttachmentListStyles.actionButtonsRowPadding,
                        child: Row(
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
                      ),
                      const SizedBox(height: AttachmentListStyles.dialogBottomSpace)
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ),
    );
  }
}
