import 'package:core/domain/exceptions/app_base_exception.dart';

class AIApiException extends AppBaseException {
  final int? statusCode;

  const AIApiException(super.message, {this.statusCode});

  @override
  String get exceptionName => 'AIApiException';

  @override
  String toString() {
    final statusPart = statusCode != null ? ' (status code: $statusCode)' : '';
    return '$exceptionName: $message$statusPart';
  }
}

class AIApiNotAvailableException extends AIApiException {
  const AIApiNotAvailableException() : super('AI API is not available');

  @override
  String get exceptionName => 'AIApiNotAvailableException';
}

class AIApiEmptyResponseException extends AIApiException {
  const AIApiEmptyResponseException() : super('AI API returned empty response');

  @override
  String get exceptionName => 'AIApiEmptyResponseException';
}

class GenerateAITextInteractorIsNotRegisteredException extends AIApiException {
  const GenerateAITextInteractorIsNotRegisteredException()
      : super('GenerateAITextInteractor is not registered');

  @override
  String get exceptionName =>
      'GenerateAITextInteractorIsNotRegisteredException';
}
