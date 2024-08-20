class CannotCreatePublicAssetException implements Exception {
  const CannotCreatePublicAssetException();
}

class PublicAssetQuotaExceededException implements Exception {
  const PublicAssetQuotaExceededException({required this.message});

  final String? message;
}

class CannotDestroyPublicAssetException implements Exception {
  const CannotDestroyPublicAssetException();
}

class CannotUpdatePublicAssetException implements Exception {
  const CannotUpdatePublicAssetException();
}