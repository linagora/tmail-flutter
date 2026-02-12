
import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/login/data/extensions/service_path_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/endpoint.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/linagora_ecosystem_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/api_url_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_identifier.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';

class LinagoraEcosystemApi {
  final DioClient _dioClient;

  LinagoraEcosystemApi(this._dioClient);

  Future<LinagoraEcosystem> getLinagoraEcosystem(String baseUrl) async {
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
  }

  Future<PaywallUrlPattern> getPaywallUrl(String baseUrl) async {
    final linagoraEcosystem = await getLinagoraEcosystem(baseUrl);

    final paywallProperty =
        linagoraEcosystem.properties?[LinagoraEcosystemIdentifier.paywallURL];
    log('LinagoraEcosystemApi::getPaywallUrl: paywallProperty = $paywallProperty');

    if (paywallProperty is ApiUrlLinagoraEcosystem) {
      return PaywallUrlPattern(paywallProperty.value);
    }
    throw NotFoundPaywallUrl();
  }
}