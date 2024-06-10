import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/attachment_item_composer_widget_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/attachment_progress_loading_composer_widget_style.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_status.dart';

class AttachmentProgressLoadingComposerWidget extends StatelessWidget {

  final UploadFileStatus uploadStatus;
  final double percentUploading;

  const AttachmentProgressLoadingComposerWidget({
    super.key,
    required this.uploadStatus,
    required this.percentUploading,
  });

  @override
  Widget build(BuildContext context) {
    switch (uploadStatus) {
      case UploadFileStatus.waiting:
        return const Padding(
          padding: AttachmentItemComposerWidgetStyle.progressLoadingPadding,
          child: LinearProgressIndicator(
            color: AttachmentProgressLoadingComposerWidgetStyle.progressColor,
            minHeight: AttachmentProgressLoadingComposerWidgetStyle.height,
            backgroundColor: AttachmentProgressLoadingComposerWidgetStyle.backgroundColor,
          ),
        );
      case UploadFileStatus.uploading:
        return Padding(
          padding: AttachmentItemComposerWidgetStyle.progressLoadingPadding,
          child: LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight:AttachmentProgressLoadingComposerWidgetStyle.height,
            percent: percentUploading > 1.0
              ? 1.0
              : percentUploading,
            barRadius: const Radius.circular(AttachmentProgressLoadingComposerWidgetStyle.radius),
            backgroundColor: AttachmentProgressLoadingComposerWidgetStyle.backgroundColor,
            progressColor: AttachmentProgressLoadingComposerWidgetStyle.progressColor,
          ),
        );
      case UploadFileStatus.uploadFailed:
      case UploadFileStatus.succeed:
        return const SizedBox.shrink();
    }
  }
}
