
import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/login/data/extensions/service_path_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/endpoint.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/linagora_ecosystem_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';

class LinagoraEcosystemApi {
  final DioClient _dioClient;

  LinagoraEcosystemApi(this._dioClient);

  Future<LinagoraEcosystem> getLinagoraEcosystem(String baseUrl) async {
    try {
      final result = await _dioClient.get(
        Endpoint.linagoraEcosystem.usingBaseUrl(baseUrl).generateEndpointPath(),
      );
      log('LinagoraEcosystemApi::getLinagoraEcosystem: $result');
      if (result is Map<String, dynamic>) {
        return LinagoraEcosystem.deserialize(result);
      } else if (result is String) {
        return LinagoraEcosystem.deserialize(jsonDecode(result));
      } else {
        throw NotFoundLinagoraEcosystem();
      }
    } catch (_) {
      throw NotFoundLinagoraEcosystem();
    }
  }
}