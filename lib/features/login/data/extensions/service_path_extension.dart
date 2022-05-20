
import 'package:core/core.dart';
import 'package:tmail_ui_user/features/login/data/network/endpoint.dart';

extension ServicePathExtension on ServicePath {
  String generateEndpointPath() {
    return path;
  }

  ServicePath generateOIDCPath(Uri baseUrl) {
    return ServicePath(baseUrl.origin + Endpoint.oidc + path);
  }

  ServicePath withQueryParameters(List<QueryParameter> queryParameters) {
    if (queryParameters.isEmpty) {
      return this;
    }
    return ServicePath('$path?${queryParameters
        .map((query) => '${query.queryName}=${query.queryValue}').join('&')}');
  }

  ServicePath withPathParameter([String? pathParameter]) {
    if (pathParameter == null || pathParameter.isEmpty) {
      return this;
    }

    return ServicePath('$path/$pathParameter');
  }
}