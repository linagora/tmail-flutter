
import 'dart:convert';

import 'package:core/core.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/network/endpoint.dart';
import 'package:tmail_ui_user/features/login/data/extensions/service_path_extension.dart';

class OIDCHttpClient {

  final DioClient _dioClient;

  OIDCHttpClient(this._dioClient);

  Future<OIDCResponse?> checkOIDCIsAvailable(OIDCRequest oidcRequest) async {
    final result = await _dioClient.get(
        Endpoint.webFinger
            .generateOIDCPath(Uri.parse(oidcRequest.baseUrl))
            .withQueryParameters([
              StringQueryParameter('resource', oidcRequest.resourceUrl),
              StringQueryParameter('rel', oidcRequest.relUrl),
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
}