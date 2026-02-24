import 'package:core/domain/exceptions/app_base_exception.dart';

class ThreadDetailOverloadException extends AppBaseException {
  ThreadDetailOverloadException([super.message]);

  @override
  String get exceptionName => 'ThreadDetailOverloadException';
}
