
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/app_dashboard/linagora_applications.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';

abstract class AppGridDatasource {
  Future<LinagoraApplications> getLinagoraApplicationsFromEnvironment(String path);

  Future<LinagoraEcosystem> getLinagoraEcosystem(String baseUrl);
}