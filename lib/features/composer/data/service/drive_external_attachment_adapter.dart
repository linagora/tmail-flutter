import 'package:drive_attachment/drive_attachment/presentation/notifier/drive_attachment_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/composer/domain/service/external_attachment_service.dart';

class DriveExternalAttachmentAdapter implements ExternalAttachmentService {
  final ProviderContainer _container;

  DriveExternalAttachmentAdapter(this._container);

  @override
  List<String> getLinkedFileHeaders(String composerId) {
    return _container
        .read(driveAttachmentProvider(composerId))
        .attachments
        .map((a) => a.linkedFileHeader)
        .toList();
  }

  @override
  void clear(String composerId) {
    _container.read(driveAttachmentProvider(composerId).notifier).clear();
  }
}
