import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundServerSettingsException extends AppBaseException {
  NotFoundServerSettingsException([super.message]);

  @override
  String get exceptionName => 'NotFoundServerSettingsException';
}

class NotFoundSettingOptionException extends AppBaseException {
  NotFoundSettingOptionException([super.message]);

  @override
  String get exceptionName => 'NotFoundSettingOptionException';
}

class CanNotUpdateServerSettingsException extends AppBaseException {
  CanNotUpdateServerSettingsException([super.message]);

  @override
  String get exceptionName => 'CanNotUpdateServerSettingsException';
}
