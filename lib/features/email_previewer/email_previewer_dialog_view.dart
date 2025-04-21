
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/presentation/views/html_viewer/ios_html_content_viewer_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class EmailPreviewerDialogView extends StatelessWidget {

  final EMLPreviewer emlPreviewer;
  final ImagePaths imagePaths;
  final OnMailtoDelegateAction onMailtoDelegateAction;
  final OnPreviewEMLDelegateAction onPreviewEMLDelegateAction;
  final OnDownloadAttachmentDelegateAction onDownloadAttachmentDelegateAction;

  const EmailPreviewerDialogView({
    super.key,
    required this.emlPreviewer,
    required this.imagePaths,
    required this.onMailtoDelegateAction,
    required this.onPreviewEMLDelegateAction,
    required this.onDownloadAttachmentDelegateAction,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isIOS) {
      return Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            topLeft: Radius.circular(16),
          ),
        ),
        insetPadding: EdgeInsets.zero,
        alignment: Alignment.center,
        backgroundColor: Colors.white,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(16),
              topLeft: Radius.circular(16),
            ),
          ),
          width: double.infinity,
          height: double.infinity,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SizedBox(
                height: 52,
                child: Row(
                  children: [
                    const Spacer(),
                    TMailButtonWidget.fromIcon(
                      icon: imagePaths.icComposerClose,
                      backgroundColor: Colors.transparent,
                      margin: const EdgeInsetsDirectional.only(end: 12),
                      onTapActionCallback: popBack,
                    )
                  ],
                ),
              ),
              const Divider(color: AppColor.colorDivider, height: 1),
              Expanded(
                child: IosHtmlContentViewerWidget(
                  contentHtml: emlPreviewer.content,
                  useDefaultFont: true,
                  direction: AppUtils().getCurrentDirection(context),
                  onMailtoDelegateAction: onMailtoDelegateAction,
                  onPreviewEMLDelegateAction: onPreviewEMLDelegateAction,
                  onDownloadAttachmentDelegateAction: onDownloadAttachmentDelegateAction,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: HtmlContentViewer(
            contentHtml: emlPreviewer.content,
            initialWidth: context.width,
            useDefaultFont: true,
            direction: AppUtils().getCurrentDirection(context),
            onMailtoDelegateAction: onMailtoDelegateAction,
            onPreviewEMLDelegateAction: onPreviewEMLDelegateAction,
            onDownloadAttachmentDelegateAction: onDownloadAttachmentDelegateAction,
          ),
        ),
      );
    }
  }
}