import 'package:core/domain/exceptions/app_base_exception.dart';

class NotSupportFCMException extends AppBaseException {
  NotSupportFCMException([super.message]);

  @override
  String get exceptionName => 'NotSupportFCMException';
}

class NotLoadedFCMTokenException extends AppBaseException {
  NotLoadedFCMTokenException([super.message]);

  @override
  String get exceptionName => 'NotLoadedFCMTokenException';
}

class NotFoundStateToRefreshException extends AppBaseException {
  NotFoundStateToRefreshException([super.message]);

  @override
  String get exceptionName => 'NotFoundStateToRefreshException';
}

class NotFoundEmailDeliveryStateException extends AppBaseException {
  NotFoundEmailDeliveryStateException([super.message]);

  @override
  String get exceptionName => 'NotFoundEmailDeliveryStateException';
}

class NotFoundFirebaseRegistrationForDeviceException extends AppBaseException {
  NotFoundFirebaseRegistrationForDeviceException([super.message]);

  @override
  String get exceptionName => 'NotFoundFirebaseRegistrationForDeviceException';
}

class NotFoundFirebaseRegistrationCacheException extends AppBaseException {
  NotFoundFirebaseRegistrationCacheException([super.message]);

  @override
  String get exceptionName => 'NotFoundFirebaseRegistrationCacheException';
}

class NotFoundEmailStateException extends AppBaseException {
  NotFoundEmailStateException([super.message]);

  @override
  String get exceptionName => 'NotFoundEmailStateException';
}

class NotFoundNewReceiveEmailException extends AppBaseException {
  NotFoundNewReceiveEmailException([super.message]);

  @override
  String get exceptionName => 'NotFoundNewReceiveEmailException';
}

class EmailStateNoChangeException extends AppBaseException {
  EmailStateNoChangeException([super.message]);

  @override
  String get exceptionName => 'EmailStateNoChangeException';
}

class NotFoundFirebaseRegistrationCreatedException extends AppBaseException {
  NotFoundFirebaseRegistrationCreatedException([super.message]);

  @override
  String get exceptionName => 'NotFoundFirebaseRegistrationCreatedException';
}

class NotFoundFirebaseRegistrationUpdatedException extends AppBaseException {
  NotFoundFirebaseRegistrationUpdatedException([super.message]);

  @override
  String get exceptionName => 'NotFoundFirebaseRegistrationUpdatedException';
}

class NotFoundFirebaseRegistrationDestroyedException extends AppBaseException {
  NotFoundFirebaseRegistrationDestroyedException([super.message]);

  @override
  String get exceptionName => 'NotFoundFirebaseRegistrationDestroyedException';
}
