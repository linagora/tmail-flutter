import 'dart:convert';

import '../entity/drive_document.dart';

WorkplaceIntentMessage parseDriveIntentMessage(String intentId, String raw) {
  final map = jsonDecode(raw) as Map<String, dynamic>;
  final type = map['type'] as String? ?? '';
  return switch (type) {
    _ when type == 'intent-$intentId:ready' => const WorkplaceIntentReadyMessage(),
    _ when type == 'intent-$intentId:done' => WorkplaceIntentDoneMessage.fromJson(map),
    _ when type == 'intent-$intentId:error' => const WorkplaceIntentErrorMessage(),
    _ when type == 'intent-$intentId:cancel' => const WorkplaceIntentCancelMessage(),
    _ => WorkplaceIntentUnknownMessage(type),
  };
}

sealed class WorkplaceIntentMessage {
  const WorkplaceIntentMessage();

  factory WorkplaceIntentMessage.parse(String intentId, String raw) =>
      parseDriveIntentMessage(intentId, raw);
}

final class WorkplaceIntentReadyMessage extends WorkplaceIntentMessage {
  const WorkplaceIntentReadyMessage();
}

final class WorkplaceIntentErrorMessage extends WorkplaceIntentMessage {
  const WorkplaceIntentErrorMessage();
}

final class WorkplaceIntentCancelMessage extends WorkplaceIntentMessage {
  const WorkplaceIntentCancelMessage();
}

final class WorkplaceIntentUnknownMessage extends WorkplaceIntentMessage {
  final String type;
  const WorkplaceIntentUnknownMessage(this.type);
}

final class WorkplaceIntentDoneMessage extends WorkplaceIntentMessage {
  final List<DriveDocument> documents;
  const WorkplaceIntentDoneMessage(this.documents);

  factory WorkplaceIntentDoneMessage.fromJson(Map<String, dynamic> json) =>
      WorkplaceIntentDoneMessage(
        (json['document'] as List? ?? [])
            .map((e) => DriveDocument.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
