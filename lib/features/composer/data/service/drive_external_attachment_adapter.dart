import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/composer/domain/service/external_attachment_service.dart';

class DriveExternalAttachmentAdapter implements ExternalAttachmentService {
  final ProviderContainer _container;

  DriveExternalAttachmentAdapter(this._container);

  @override
  void clear(String composerId) {
    _container.read(driveAttachmentProvider(composerId).notifier).clear();
  }
}
