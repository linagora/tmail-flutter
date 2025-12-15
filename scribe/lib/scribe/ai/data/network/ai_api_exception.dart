class AIApiException implements Exception {
  final String message;
  final int? statusCode;

  AIApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'AIApiException: $message (status code: $statusCode)';
    }
    return 'AIApiException: $message';
  }
}

class AIApiNotAvailableException extends AIApiException {
  AIApiNotAvailableException() : super('AI API is not available');
}

class AIApiEmptyResponseException extends AIApiException {
  AIApiEmptyResponseException() : super('AI API returned empty response');
}
