import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundServerSettingsException extends AppBaseException {
  const NotFoundServerSettingsException([super.message]);

  @override
  String get exceptionName => 'NotFoundServerSettingsException';
}

class NotFoundSettingOptionException extends AppBaseException {
  const NotFoundSettingOptionException([super.message]);

  @override
  String get exceptionName => 'NotFoundSettingOptionException';
}

class CanNotUpdateServerSettingsException extends AppBaseException {
  const CanNotUpdateServerSettingsException([super.message]);

  @override
  String get exceptionName => 'CanNotUpdateServerSettingsException';
}
