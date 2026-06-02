import 'dart:convert';

import 'package:drive_attachment/drive_attachment/domain/entity/drive_document.dart';

DriveIntentMessage parseDriveIntentMessage(String intentId, String raw) {
  final map = jsonDecode(raw) as Map<String, dynamic>;
  final type = map['type'] as String? ?? '';
  return switch (type) {
    _ when type == 'intent-$intentId:ready' => const DriveIntentReadyMessage(),
    _ when type == 'intent-$intentId:done' => DriveIntentDoneMessage.fromJson(map),
    _ when type == 'intent-$intentId:error' => const DriveIntentErrorMessage(),
    _ when type == 'intent-$intentId:cancel' => const DriveIntentCancelMessage(),
    _ => DriveIntentUnknownMessage(type),
  };
}

sealed class DriveIntentMessage {
  const DriveIntentMessage();

  factory DriveIntentMessage.parse(String intentId, String raw) =>
      parseDriveIntentMessage(intentId, raw);
}

final class DriveIntentReadyMessage extends DriveIntentMessage {
  const DriveIntentReadyMessage();
}

final class DriveIntentErrorMessage extends DriveIntentMessage {
  const DriveIntentErrorMessage();
}

final class DriveIntentCancelMessage extends DriveIntentMessage {
  const DriveIntentCancelMessage();
}

final class DriveIntentUnknownMessage extends DriveIntentMessage {
  final String type;
  const DriveIntentUnknownMessage(this.type);
}

final class DriveIntentDoneMessage extends DriveIntentMessage {
  final List<DriveDocument> documents;
  const DriveIntentDoneMessage(this.documents);

  factory DriveIntentDoneMessage.fromJson(Map<String, dynamic> json) =>
      DriveIntentDoneMessage(
        (json['document'] as List? ?? [])
            .map((e) => DriveDocument.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

final class DriveIntentParseException implements Exception {
  final String raw;
  const DriveIntentParseException(this.raw);

  @override
  String toString() => 'DriveIntentParseException: failed to parse "$raw"';
}
