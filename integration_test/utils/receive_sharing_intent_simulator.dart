import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// EventChannel `receive_sharing_intent` uses to stream content shared into the
/// app while it is running. Pushing an event onto it simulates the OS delivering
/// an external share, so the app's real `getMediaStream()` wiring runs end to end
/// (stream -> EmailReceiveManager -> MailboxDashBoardController handler).
const String _sharingMediaEventChannel = 'receive_sharing_intent/events-media';

/// Builds one shared-media entry in the JSON shape the plugin decodes
/// (see `SharedMediaFile.fromMap`). `type` is a [SharedMediaType] value string
/// such as `text`, `image`, `file`, `url` or `mailto`.
Map<String, dynamic> sharedMediaMap({
  required String path,
  required String type,
  String? mimeType,
}) => {
  'path': path,
  'type': type,
  if (mimeType != null) 'mimeType': mimeType,
};

/// Emits a shared-media event as if an external app shared [mediaList] to us.
///
/// The plugin streams a JSON string per event and decodes it back into
/// `List<SharedMediaFile>`, so the payload is wrapped in a standard success
/// envelope and delivered through the app's already-registered channel listener.
Future<void> emitSharedMediaEvent(List<Map<String, dynamic>> mediaList) async {
  final envelope =
      const StandardMethodCodec().encodeSuccessEnvelope(jsonEncode(mediaList));
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(_sharingMediaEventChannel, envelope, (_) {});
}
