
import 'dart:convert';
import 'dart:io';

import 'package:core/data/model/query/query_parameter.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/app_logger.dart';
import 'package:get/get_connect/http/src/exceptions/exceptions.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:model/oidc/response/oidc_discovery_response.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:tmail_ui_user/features/login/data/extensions/service_path_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/features/login/data/network/endpoint.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/login_exception.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_error.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:dio/dio.dart' show DioError;

class OIDCHttpClient {

  final DioClient _dioClient;

  OIDCHttpClient(this._dioClient);

  Future<OIDCResponse> checkOIDCIsAvailable(OIDCRequest oidcRequest) async {
    try {
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
    } on FormatException catch (exception) {
      log('checkOIDCIsAvailable(): error while parsing server response (JSON expected): ${exception.message}');
      throw InvalidOIDCResponseException();
    } on DioError catch (exception) {
      if (exception.error is HandshakeException) {
        throw exception.error!;
      } else if (exception.error is SocketException) {
        throw exception.error!;
      } else if (exception.response?.statusCode == 401) {
        throw UnauthorizedException();
      } else if (exception.response?.statusCode == 404) {
        throw CanNotFoundOIDCLinks();
      }
      throw CanRetryOIDCException();
    } catch (_) {
      throw CanRetryOIDCException();
    }
  }

  Future<OIDCConfiguration> getOIDCConfiguration(OIDCResponse oidcResponse) async {
    if (oidcResponse.links.isEmpty) {
      throw CanNotFoundOIDCAuthority();
    }
    final authority = oidcResponse.links[0].href.toString();
    final isTWP = authority == AppConfig.saasRegistrationUrl;
    log('OIDCHttpClient::getOIDCConfiguration():authority: $authority');
    return OIDCConfiguration(
      authority: authority,
      clientId: OIDCConstant.clientId,
      scopes: AppConfig.oidcScopes,
      isTWP: isTWP,
    );
  }

  Future<OIDCDiscoveryResponse> discoverOIDC(OIDCConfiguration configuration) async {
    final result = await _dioClient.get(configuration.discoveryUrl);
    log('OIDCHttpClient::discoverOIDC(): RESULT: $result');
    if (result is Map<String, dynamic>) {
      return OIDCDiscoveryResponse.fromJson(result);
    } else {
      return OIDCDiscoveryResponse.fromJson(jsonDecode(result));
    }
  }
}