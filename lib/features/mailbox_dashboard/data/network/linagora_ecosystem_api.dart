
import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/login/data/extensions/service_path_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/endpoint.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/linagora_ecosystem_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';

class LinagoraEcosystemApi {
  final DioClient _dioClient;

  LinagoraEcosystemApi(this._dioClient);

  Future<LinagoraEcosystem> getLinagoraEcosystem(String baseUrl) async {
    final result = await _dioClient.get(
      Endpoint.linagoraEcosystem.usingBaseUrl(baseUrl).generateEndpointPath(),
    );
    log('LinagoraEcosystemApi::getLinagoraEcosystem: responseType = ${result.runtimeType}');
    return _deserializeResponse(result);
  }

  Future<PaywallUrlPattern> getPaywallUrl(String baseUrl) async {
    final result = await _dioClient.get(
      Endpoint.linagoraEcosystem.usingBaseUrl(baseUrl).generateEndpointPath(),
    );
    log('LinagoraEcosystemApi::getPaywallUrl: responseType = ${result.runtimeType}');

    final linagoraEcosystem = _deserializeResponse(result);
    final paywallUrlTemplate = linagoraEcosystem.paywallUrlTemplate;
    log('LinagoraEcosystemApi::getPaywallUrl: hasPaywallUrlTemplate = ${paywallUrlTemplate != null}');

    if (paywallUrlTemplate == null) {
      throw NotFoundPaywallUrl();
    }
    return PaywallUrlPattern(paywallUrlTemplate);
  }

  LinagoraEcosystem _deserializeResponse(dynamic response) {
    final decodedResponse = response is String ? jsonDecode(response) : response;
    if (decodedResponse is! Map<String, dynamic>) {
      throw NotFoundLinagoraEcosystem();
    }
    return LinagoraEcosystem.deserialize(decodedResponse);
  }
}
