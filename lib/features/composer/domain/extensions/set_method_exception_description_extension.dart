import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/core/error/error_type.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';

extension SetMethodExceptionDescriptionExtension on SetMethodException {
  String? getDescriptionFromErrorType(ErrorType errorType) {
    return mapErrors.values
        .firstWhereOrNull((setError) => setError.type == errorType)
        ?.description;
  }
}
