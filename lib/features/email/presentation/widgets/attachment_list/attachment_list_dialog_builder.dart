import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/attachment/attachment_list_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_list/attachment_list_dialog_body_builder.dart';

typedef OnDownloadAttachmentFileAction = void Function(Attachment attachment);
typedef OnViewAttachmentFileAction = void Function(Attachment attachment);
typedef OnDownloadAllButtonAction = void Function();
typedef OnCancelButtonAction = void Function();
typedef OnCloseButtonAction = void Function();

class AttachmentListDialogBuilder extends StatelessWidget {

  final ImagePaths imagePaths;
  final List<Attachment> attachments;
  final ResponsiveUtils responsiveUtils;
  final ScrollController scrollController;

  final Color? backgroundColor;
  final double? widthDialog;
  final double? heightDialog;
  final OnDownloadAllButtonAction? onDownloadAllButtonAction;
  final OnDownloadAttachmentFileAction? onDownloadAttachmentFileAction;
  final OnViewAttachmentFileAction? onViewAttachmentFileAction;
  final OnCancelButtonAction? onCancelButtonAction;
  final OnCloseButtonAction? onCloseButtonAction;

  const AttachmentListDialogBuilder({
    Key? key,
    required this.imagePaths,
    required this.attachments,
    required this.responsiveUtils,
    required this.scrollController,
    this.backgroundColor,
    this.widthDialog,
    this.heightDialog,
    this.onDownloadAllButtonAction,
    this.onDownloadAttachmentFileAction,
    this.onViewAttachmentFileAction,
    this.onCancelButtonAction,
    this.onCloseButtonAction,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const ValueKey('attachment_list_dialog'),
      shape: AttachmentListStyles.shapeBorder,
      insetPadding: responsiveUtils.isDesktop(context)
        ? AttachmentListStyles.dialogPaddingWeb
        : AttachmentListStyles.dialogPaddingTablet,
      alignment: Alignment.center,
      backgroundColor: backgroundColor,
      child: AttachmentListDialogBodyBuilder(
        context: context,
        imagePaths: imagePaths,
        attachments: attachments,
        widthDialog: widthDialog,
        heightDialog: heightDialog,
        scrollController: scrollController,
        onDownloadAllButtonAction: onDownloadAllButtonAction,
        onDownloadAttachmentFileAction: onDownloadAttachmentFileAction,
        onViewAttachmentFileAction: onViewAttachmentFileAction,
        onCancelButtonAction: onCancelButtonAction,
        onCloseButtonAction: onCloseButtonAction,
      ),
    );
  }
}
