
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class EmailPreviewerDialogView extends StatelessWidget {

  final EMLPreviewer emlPreviewer;

  const EmailPreviewerDialogView({super.key, required this.emlPreviewer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: HtmlContentViewer(
          contentHtml: emlPreviewer.content,
          initialWidth: context.width,
          direction: AppUtils.getCurrentDirection(context),
        ),
      ),
    );
  }
}