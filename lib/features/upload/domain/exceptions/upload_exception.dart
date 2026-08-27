import 'package:core/domain/exceptions/app_base_exception.dart';

class DataResponseIsNullException extends AppBaseException {
  const DataResponseIsNullException([super.message]);

  @override
  String get exceptionName => 'DataResponseIsNullException';
}

class UploadFromUrlEndpointUnavailableException extends AppBaseException {
  const UploadFromUrlEndpointUnavailableException([super.message]);

  @override
  String get exceptionName => 'UploadFromUrlEndpointUnavailableException';
}

class DriveTransferTaskNotFoundException extends AppBaseException {
  const DriveTransferTaskNotFoundException([super.message]);

  @override
  String get exceptionName => 'DriveTransferTaskNotFoundException';
}

class UploadFailureToastContextMissingException extends AppBaseException {
  const UploadFailureToastContextMissingException([super.message]);

  @override
  String get exceptionName => 'UploadFailureToastContextMissingException';
}

class DriveDocumentNotAttachableException extends AppBaseException {
  const DriveDocumentNotAttachableException([super.message]);

  @override
  String get exceptionName => 'DriveDocumentNotAttachableException';
}

class DriveDownloadLinkMissingException extends AppBaseException {
  const DriveDownloadLinkMissingException([super.message]);

  @override
  String get exceptionName => 'DriveDownloadLinkMissingException';
}
