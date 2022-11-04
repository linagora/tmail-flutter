
import 'package:core/data/model/query/query_parameter.dart';
import 'package:core/data/network/config/service_path.dart';

extension ServicePathExtension on ServicePath {
  String generateEndpointPath() {
    return path;
  }

  ServicePath generateOIDCPath(Uri baseUrl) {
    return ServicePath(baseUrl.toString() + path);
  }

  ServicePath withQueryParameters(List<QueryParameter> queryParameters) {
    if (queryParameters.isEmpty) {
      return this;
    }
    return ServicePath('$path?${queryParameters
        .map((query) => '${query.queryName}=${query.queryValue}').join('&')}');
  }

  ServicePath withPathParameter(String? pathParameter) {
    if (pathParameter == null || pathParameter.isEmpty) {
      return this;
    }

    if (path.lastIndexOf('/') == path.length - 1) {
      return ServicePath('$path$pathParameter');
    } else {
      return ServicePath('$path/$pathParameter');
    }
  }
}