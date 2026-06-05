import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';

sealed class DriveAttachmentState {
  final List<DriveDocument> attachments;
  const DriveAttachmentState({this.attachments = const []});
}

final class DriveAttachmentIdle extends DriveAttachmentState {
  const DriveAttachmentIdle({super.attachments});
}

final class DriveAttachmentFetchingIntent extends DriveAttachmentState {
  const DriveAttachmentFetchingIntent({super.attachments});
}

final class DriveIntentPending extends DriveAttachmentState {
  final WorkplaceIntent intent;
  const DriveIntentPending({required this.intent, super.attachments});
}

final class DriveAttachmentError extends DriveAttachmentState {
  final Object error;
  const DriveAttachmentError({required this.error, super.attachments});
}
