import 'package:core/domain/exceptions/app_base_exception.dart';

class DownloadAttachmentInteractorIsNull extends AppBaseException {
  DownloadAttachmentInteractorIsNull([super.message]);

  @override
  String get exceptionName => 'DownloadAttachmentInteractorIsNull';
}

class CapabilityDownloadAllNotSupportedException extends AppBaseException {
  CapabilityDownloadAllNotSupportedException([super.message]);

  @override
  String get exceptionName => 'CapabilityDownloadAllNotSupportedException';
}

class DownloadUrlIsNullException extends AppBaseException {
  DownloadUrlIsNullException([super.message]);

  @override
  String get exceptionName => 'DownloadUrlIsNullException';
}
