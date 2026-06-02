import 'package:drive_attachment/drive_attachment/domain/entity/drive_attachment.dart';
import 'package:drive_attachment/drive_attachment/domain/entity/drive_intent.dart';

sealed class DriveAttachmentState {
  final List<DriveAttachment> attachments;
  const DriveAttachmentState({this.attachments = const []});
}

final class DriveAttachmentIdle extends DriveAttachmentState {
  const DriveAttachmentIdle({super.attachments});
}

final class DriveAttachmentFetchingIntent extends DriveAttachmentState {
  const DriveAttachmentFetchingIntent({super.attachments});
}

final class DriveIntentPending extends DriveAttachmentState {
  final DriveIntent intent;
  const DriveIntentPending({required this.intent, super.attachments});
}

final class DriveAttachmentError extends DriveAttachmentState {
  final Object error;
  const DriveAttachmentError({required this.error, super.attachments});
}
