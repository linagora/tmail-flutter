
import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/login/data/extensions/service_path_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/endpoint.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/cache/linagora_ecosystem_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/linagora_ecosystem_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/api_url_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_identifier.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';

class LinagoraEcosystemApi {
  final DioClient _dioClient;

  LinagoraEcosystemApi(this._dioClient);

  Future<LinagoraEcosystem> getLinagoraEcosystem(String baseUrl) async {
    final cachedEcosystem = LinagoraEcosystemCache().getCachedEcosystem(baseUrl);
    if (cachedEcosystem != null) {
      log('LinagoraEcosystemApi::getLinagoraEcosystem: Using cached data');
      return cachedEcosystem;
    }

    final result = await _dioClient.get(
      Endpoint.linagoraEcosystem.usingBaseUrl(baseUrl).generateEndpointPath(),
    );
    log('LinagoraEcosystemApi::getLinagoraEcosystem: $result');
    
    LinagoraEcosystem ecosystem;
    if (result is Map<String, dynamic>) {
      ecosystem = LinagoraEcosystem.deserialize(result);
    } else if (result is String) {
      ecosystem = LinagoraEcosystem.deserialize(jsonDecode(result));
    } else {
      throw NotFoundLinagoraEcosystem();
    }

    LinagoraEcosystemCache().cacheEcosystem(ecosystem, baseUrl);
    
    return ecosystem;
  }

  Future<PaywallUrlPattern> getPaywallUrl(String baseUrl) async {
    LinagoraEcosystem? linagoraEcosystem;

    try {
      linagoraEcosystem = await getLinagoraEcosystem(baseUrl);
    } catch (exception) {
      if (exception is NotFoundLinagoraEcosystem) {
         throw NotFoundPaywallUrl();
      }
      rethrow;
    }

    final paywallProperty =
        linagoraEcosystem.properties?[LinagoraEcosystemIdentifier.paywallURL] as ApiUrlLinagoraEcosystem?;
    log('LinagoraEcosystemApi::getPaywallUrl: paywallProperty = $paywallProperty');

    if (paywallProperty == null) {
      throw NotFoundPaywallUrl();
    } else {
      return PaywallUrlPattern(paywallProperty.value);
    }
  }

  Future<String?> getScribePromptUrl(String baseUrl) async {
    LinagoraEcosystem? linagoraEcosystem;
    
    try {
      linagoraEcosystem = await getLinagoraEcosystem(baseUrl);
    } catch (exception) {
      if (exception is NotFoundLinagoraEcosystem) {
        return null;
      }
      rethrow;
    }

    final scribePromptProperty =
        linagoraEcosystem.properties?[LinagoraEcosystemIdentifier.scribePromptUrl] as ApiUrlLinagoraEcosystem?;
    log('LinagoraEcosystemApi::getScribePromptUrl: scribePromptProperty = $scribePromptProperty');

    return scribePromptProperty?.value;
  }
}