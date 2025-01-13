
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class EmailPreviewerDialogView extends StatelessWidget {

  final EMLPreviewer emlPreviewer;
  final OnMailtoDelegateAction onMailtoDelegateAction;
  final OnPreviewEMLDelegateAction onPreviewEMLDelegateAction;
  final OnDownloadAttachmentDelegateAction onDownloadAttachmentDelegateAction;

  const EmailPreviewerDialogView({
    super.key,
    required this.emlPreviewer,
    required this.onMailtoDelegateAction,
    required this.onPreviewEMLDelegateAction,
    required this.onDownloadAttachmentDelegateAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: HtmlContentViewer(
          contentHtml: emlPreviewer.content,
          initialWidth: context.width,
          direction: AppUtils.getCurrentDirection(context),
          onMailtoDelegateAction: onMailtoDelegateAction,
          onPreviewEMLDelegateAction: onPreviewEMLDelegateAction,
          onDownloadAttachmentDelegateAction: onDownloadAttachmentDelegateAction,
        ),
      ),
    );
  }
}