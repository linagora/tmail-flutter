
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/app_dashboard/linagora_applications.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';

abstract class AppGridRepository {
  Future<LinagoraApplications> getLinagoraApplications(String path);

  Future<LinagoraEcosystem> getLinagoraEcosystem(String baseUrl);
}