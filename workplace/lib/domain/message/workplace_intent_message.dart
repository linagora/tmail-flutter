import 'dart:convert';
import 'dart:developer' as dev;

import '../entity/drive_document.dart';

WorkplaceIntentMessage parseWorkplaceIntentMessage(String intentId, String raw) {
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
      parseWorkplaceIntentMessage(intentId, raw);
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

  factory WorkplaceIntentDoneMessage.fromJson(Map<String, dynamic> json) {
    final raw = json['document'] as List? ?? [];
    final documents = <DriveDocument>[];
    for (final e in raw) {
      final doc = _tryParseDocument(e);
      if (doc != null) documents.add(doc);
    }
    return WorkplaceIntentDoneMessage(documents);
  }

  static DriveDocument? _tryParseDocument(dynamic e) {
    try {
      final doc = DriveDocument.fromJson(e as Map<String, dynamic>);
      if (doc.size < 0) {
        dev.log('driveIntent: skipping doc ${doc.id} with negative size ${doc.size}', name: 'workplace');
        return null;
      }
      final url = doc.sharingLink ?? doc.downloadLink;
      if (url != null && url.scheme != 'https' && url.scheme != 'http') {
        dev.log('driveIntent: skipping doc ${doc.id} with invalid url scheme ${url.scheme}', name: 'workplace');
        return null;
      }
      return doc;
    } catch (err) {
      dev.log('driveIntent: skipping malformed document entry: $err', name: 'workplace');
      return null;
    }
  }
}
