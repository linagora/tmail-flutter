class OAuthAuthorizationError {
  static const String serverError = 'server_error'; // HTTP 500 error code
  static const String temporarilyUnavailable =
      'temporarily_unavailable'; // HTTP 503 error code

  final String error;
  final String? errorDescription;

  const OAuthAuthorizationError({
    required this.error,
    this.errorDescription,
  });

  static OAuthAuthorizationError fromErrorCode(
    String error, {
    String? errorDescription,
  }) {
    switch (error) {
      case serverError:
        return ServerError(errorDescription: errorDescription);
      case temporarilyUnavailable:
        return TemporarilyUnavailable(errorDescription: errorDescription);
      default:
        return OAuthAuthorizationError(
          error: error,
          errorDescription: errorDescription,
        );
    }
  }
}

class ServerError extends OAuthAuthorizationError {
  const ServerError({super.errorDescription})
      : super(error: OAuthAuthorizationError.serverError);
}

class TemporarilyUnavailable extends OAuthAuthorizationError {
  const TemporarilyUnavailable({super.errorDescription})
      : super(error: OAuthAuthorizationError.temporarilyUnavailable);
}
