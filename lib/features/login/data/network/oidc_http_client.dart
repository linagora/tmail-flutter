
import 'dart:convert';

import 'package:core/data/model/query/query_parameter.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/app_logger.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:tmail_ui_user/features/login/data/extensions/service_path_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/features/login/data/network/endpoint.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_error.dart';

class OIDCHttpClient {

  final DioClient _dioClient;

  OIDCHttpClient(this._dioClient);

  Future<OIDCResponse?> checkOIDCIsAvailable(OIDCRequest oidcRequest) async {
    final result = await _dioClient.get(
        Endpoint.webFinger
            .generateOIDCPath(Uri.parse(oidcRequest.baseUrl))
            .withQueryParameters([
              StringQueryParameter('resource', oidcRequest.resourceUrl),
              StringQueryParameter('rel', OIDCRequest.relUrl),
            ])
            .generateEndpointPath()
    );
    log('OIDCHttpClient::checkOIDCIsAvailable(): RESULT: $result');
    if (result is Map<String, dynamic>) {
      return OIDCResponse.fromJson(result);
    } else {
      return OIDCResponse.fromJson(jsonDecode(result));
    }
  }

  Future<OIDCConfiguration> getOIDCConfiguration(OIDCResponse oidcResponse) async {
    if (oidcResponse.links.isEmpty) {
      throw CanNotFoundOIDCAuthority();
    }
    log('OIDCHttpClient::getOIDCConfiguration(): href: ${oidcResponse.links[0].href}');
    return OIDCConfiguration(
      authority: oidcResponse.links[0].href.toString(),
      clientId: OIDCConstant.clientId,
      scopes: OIDCConstant.oidcScope
    );
  }
}