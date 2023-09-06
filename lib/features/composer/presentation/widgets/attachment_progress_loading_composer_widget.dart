import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/attachment_progress_loading_composer_widget_style.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_status.dart';

class AttachmentProgressLoadingComposerWidget extends StatelessWidget {

  final UploadFileState fileState;
  final EdgeInsetsGeometry? padding;

  const AttachmentProgressLoadingComposerWidget({
    super.key,
    required this.fileState,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    switch (fileState.uploadStatus) {
      case UploadFileStatus.waiting:
        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: const LinearProgressIndicator(
            color: AttachmentProgressLoadingComposerWidgetStyle.progressColor,
            minHeight: AttachmentProgressLoadingComposerWidgetStyle.height,
            backgroundColor: AttachmentProgressLoadingComposerWidgetStyle.backgroundColor,
          ),
        );
      case UploadFileStatus.uploading:
        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight:AttachmentProgressLoadingComposerWidgetStyle.height,
            percent: fileState.percentUploading > 1.0
              ? 1.0
              : fileState.percentUploading,
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
