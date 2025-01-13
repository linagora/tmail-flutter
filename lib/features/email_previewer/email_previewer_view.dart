
import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_preview_email_content_shared_state.dart';
import 'package:tmail_ui_user/features/email_previewer/email_previewer_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailPreviewerView extends GetWidget<EmailPreviewerController> {

  const EmailPreviewerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final viewState = controller.viewState.value;
        return viewState.fold(
          (failure) {
            if (viewState is GetPreviewEmailEMLContentSharedFailure) {
              return Center(
                child: Text(AppLocalizations.of(context).previewEmailFromEMLFileFailed),
              );
            } else {
              return const Center(
                child: CupertinoLoadingWidget(),
              );
            }
          },
          (success) {
            if (success is GetPreviewEmailEMLContentSharedSuccess) {
              return HtmlContentViewerOnWeb(
                widthContent: context.width,
                heightContent: context.height,
                contentHtml: success.previewEMLContent,
              );
            } else {
              return const Center(
                child: CupertinoLoadingWidget(),
              );
            }
        });
      }),
    );
  }
}