import 'package:core/domain/exceptions/app_base_exception.dart';

class OAuthAuthorizationError extends AppBaseException {
  static const String serverError = 'server_error'; // HTTP 500 error code
  static const String temporarilyUnavailable =
      'temporarily_unavailable'; // HTTP 503 error code

  final String error;

  const OAuthAuthorizationError({
    required this.error,
    String? errorDescription,
  }) : super(errorDescription);

  @override
  String get exceptionName => 'OAuthAuthorizationError';

  @override
  String toString() {
    if (message != null && message!.isNotEmpty) {
      return '$exceptionName(code: $error): $message';
    }
    return '$exceptionName(code: $error)';
  }

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
  const ServerError({String? errorDescription})
      : super(
          error: OAuthAuthorizationError.serverError,
          errorDescription: errorDescription,
        );

  @override
  String get exceptionName => 'ServerError';
}

class TemporarilyUnavailable extends OAuthAuthorizationError {
  const TemporarilyUnavailable({String? errorDescription})
      : super(
          error: OAuthAuthorizationError.temporarilyUnavailable,
          errorDescription: errorDescription,
        );

  @override
  String get exceptionName => 'TemporarilyUnavailable';
}
