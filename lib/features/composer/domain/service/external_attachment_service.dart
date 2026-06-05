import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class ExternalAttachmentService {
  void clear(String composerId);
}

ExternalAttachmentService _instance = const _NoOpExternalAttachmentService();

void registerExternalAttachmentService(ExternalAttachmentService service) {
  _instance = service;
}

final externalAttachmentServiceProvider = Provider<ExternalAttachmentService>(
  (_) => _instance,
);

class _NoOpExternalAttachmentService implements ExternalAttachmentService {
  const _NoOpExternalAttachmentService();

  @override
  void clear(String composerId) {}
}
