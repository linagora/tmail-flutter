import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';

class StartViewAttachmentForWeb extends StartDownloadAttachmentForWeb {
  StartViewAttachmentForWeb(super.taskId, super.attachment);
}

class ViewingAttachmentForWeb extends DownloadingAttachmentForWeb {
  ViewingAttachmentForWeb(
    super.taskId,
    super.attachment,
    super.progress,
    super.downloaded,
    super.total,
  );
}

class ViewAttachmentForWebSuccess extends DownloadAttachmentForWebSuccess {
  ViewAttachmentForWebSuccess(super.taskId, super.attachment, super.bytes);
}

class ViewAttachmentForWebFailure extends DownloadAttachmentForWebFailure {
  ViewAttachmentForWebFailure({super.taskId, super.exception});
}
