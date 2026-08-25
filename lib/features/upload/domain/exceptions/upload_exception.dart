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
