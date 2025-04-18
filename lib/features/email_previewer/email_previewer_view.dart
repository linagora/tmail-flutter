
import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_preview_email_eml_content_shared_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_preview_eml_content_in_memory_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/preview_email_from_eml_file_state.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/email_previewer/download_attachment_loading_bar.dart';
import 'package:tmail_ui_user/features/email_previewer/email_previewer_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class EmailPreviewerView extends GetWidget<EmailPreviewerController> {

  const EmailPreviewerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Obx(() {
            final viewState = controller.emlContentViewState.value;
            return viewState.fold(
              (failure) => Center(
                child: Text(AppLocalizations.of(context).previewEmailFromEMLFileFailed),
              ),
              (success) {
                if (success is GetPreviewEmailEMLContentSharedSuccess) {
                  return _buildEMLPreviewerWidget(context, success.emlPreviewer);
                } else if (success is GetPreviewEMLContentInMemorySuccess) {
                  return _buildEMLPreviewerWidget(context, success.emlPreviewer);
                } else if (success is PreviewEmailFromEmlFileSuccess) {
                  return _buildEMLPreviewerWidget(context, success.emlPreviewer);
                } else {
                  return const Center(
                    child: CupertinoLoadingWidget(),
                  );
                }
            });
          }),
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: Obx(() => DownloadAttachmentLoadingBar(
              viewState: controller.downloadAttachmentState.value,
            )),
          )
        ],
      ),
    );
  }

  Widget _buildEMLPreviewerWidget(BuildContext context, EMLPreviewer emlPreviewer) {
    return HtmlContentViewerOnWeb(
      widthContent: context.width,
      heightContent: context.height,
      contentHtml: emlPreviewer.content,
      direction: AppUtils.getCurrentDirection(context),
      onClickHyperLinkAction: controller.onClickHyperLink,
    );
  }
}