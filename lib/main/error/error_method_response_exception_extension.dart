
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';

extension ErrorMethodResponseExceptionExtension on ErrorMethodResponseException {
  String get errorMessage {
    if (errorResponse is ErrorMethodResponse) {
      return (errorResponse as ErrorMethodResponse).description?.trim() ?? '';
    }
    return '';
  }
}