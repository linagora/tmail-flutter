import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_handler.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_enabled_notifier.dart';

class DriveAttachmentEcosystemHandler implements LinagoraEcosystemHandler {
  @override
  void onEcosystemLoaded(LinagoraEcosystem ecosystem) {
    appProviderContainer
        .read(driveAttachmentEnabledProvider.notifier)
        .setEnabled(ecosystem.driveAttachmentConfig?.enabled);
  }

  @override
  void onEcosystemCleared() {
    appProviderContainer
        .read(driveAttachmentEnabledProvider.notifier)
        .setEnabled(null);
  }
}
