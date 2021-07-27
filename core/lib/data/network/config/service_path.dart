class ServicePath {
  final String path;

  ServicePath(this.path);
}

extension ServicePathExtension on ServicePath {
  String generateEndpointPath() {
    return '$path';
  }

  String generateAuthenticationUrl(Uri? baseUrl) {
    if (baseUrl == null) {
      return generateEndpointPath();
    } else {
      return baseUrl.origin + generateEndpointPath();
    }
  }
}