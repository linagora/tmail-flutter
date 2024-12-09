
import 'package:core/data/constants/constant.dart';
import 'package:core/data/model/query/query_parameter.dart';
import 'package:core/data/network/config/service_path.dart';

extension ServicePathExtension on ServicePath {
  String generateEndpointPath() {
    return path;
  }

  ServicePath usingBaseUrl(String baseUrl) {
    String normalizedBaseUrl = baseUrl.endsWith(Constant.slashCharacter)
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

    String normalizedPath = path.startsWith(Constant.slashCharacter)
      ? path.substring(1)
      : path;

    return ServicePath('$normalizedBaseUrl${Constant.slashCharacter}$normalizedPath');
  }

  ServicePath withQueryParameters(List<QueryParameter> queryParameters) {
    if (queryParameters.isEmpty) {
      return this;
    }
    if (path.lastIndexOf(Constant.slashCharacter) == path.length - 1) {
      final newPath = path.substring(0, path.length - 1);

      return ServicePath('$newPath?${queryParameters
        .map((query) => '${query.queryName}=${query.queryValue}')
        .join(Constant.andCharacter)}');
    } else {
      return ServicePath('$path?${queryParameters
        .map((query) => '${query.queryName}=${query.queryValue}')
        .join(Constant.andCharacter)}');
    }
  }

  ServicePath withPathParameter(String? pathParameter) {
    if (pathParameter == null || pathParameter.isEmpty) {
      return this;
    }

    if (path.lastIndexOf(Constant.slashCharacter) == path.length - 1) {
      return ServicePath('$path$pathParameter');
    } else {
      return ServicePath('$path${Constant.slashCharacter}$pathParameter');
    }
  }
}