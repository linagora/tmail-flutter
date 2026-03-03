import 'package:core/domain/exceptions/app_base_exception.dart';

class EmptyThreadDetailException extends AppBaseException {
  const EmptyThreadDetailException([super.message]);

  @override
  String get exceptionName => 'EmptyThreadDetailException';
}
