import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class ExternalAttachmentService {
  List<String> getLinkedFileHeaders(String composerId);
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
  List<String> getLinkedFileHeaders(String composerId) => const [];

  @override
  void clear(String composerId) {}
}
