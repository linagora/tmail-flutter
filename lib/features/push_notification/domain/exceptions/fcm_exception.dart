import 'package:core/domain/exceptions/app_base_exception.dart';

class NotSupportFCMException extends AppBaseException {
  const NotSupportFCMException([super.message]);

  @override
  String get exceptionName => 'NotSupportFCMException';
}

class NotLoadedFCMTokenException extends AppBaseException {
  const NotLoadedFCMTokenException([super.message]);

  @override
  String get exceptionName => 'NotLoadedFCMTokenException';
}

class NotFoundStateToRefreshException extends AppBaseException {
  const NotFoundStateToRefreshException([super.message]);

  @override
  String get exceptionName => 'NotFoundStateToRefreshException';
}

class NotFoundEmailDeliveryStateException extends AppBaseException {
  const NotFoundEmailDeliveryStateException([super.message]);

  @override
  String get exceptionName => 'NotFoundEmailDeliveryStateException';
}

class NotFoundFirebaseRegistrationForDeviceException extends AppBaseException {
  const NotFoundFirebaseRegistrationForDeviceException([super.message]);

  @override
  String get exceptionName => 'NotFoundFirebaseRegistrationForDeviceException';
}

class NotFoundFirebaseRegistrationCacheException extends AppBaseException {
  const NotFoundFirebaseRegistrationCacheException([super.message]);

  @override
  String get exceptionName => 'NotFoundFirebaseRegistrationCacheException';
}

class NotFoundEmailStateException extends AppBaseException {
  const NotFoundEmailStateException([super.message]);

  @override
  String get exceptionName => 'NotFoundEmailStateException';
}

class NotFoundNewReceiveEmailException extends AppBaseException {
  const NotFoundNewReceiveEmailException([super.message]);

  @override
  String get exceptionName => 'NotFoundNewReceiveEmailException';
}

class EmailStateNoChangeException extends AppBaseException {
  const EmailStateNoChangeException([super.message]);

  @override
  String get exceptionName => 'EmailStateNoChangeException';
}

class NotFoundFirebaseRegistrationCreatedException extends AppBaseException {
  const NotFoundFirebaseRegistrationCreatedException([super.message]);

  @override
  String get exceptionName => 'NotFoundFirebaseRegistrationCreatedException';
}

class NotFoundFirebaseRegistrationUpdatedException extends AppBaseException {
  const NotFoundFirebaseRegistrationUpdatedException([super.message]);

  @override
  String get exceptionName => 'NotFoundFirebaseRegistrationUpdatedException';
}

class NotFoundFirebaseRegistrationDestroyedException extends AppBaseException {
  const NotFoundFirebaseRegistrationDestroyedException([super.message]);

  @override
  String get exceptionName => 'NotFoundFirebaseRegistrationDestroyedException';
}
