import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/destroy_firebase_registration_state.dart';

class DestroyFirebaseRegistrationInteractor {

  final FCMRepository _fcmRepository;

  DestroyFirebaseRegistrationInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(DestroyFirebaseRegistrationLoading());
      final registration = await _fcmRepository.getStoredFirebaseRegistration();
      await Future.wait([
        _fcmRepository.destroyFirebaseRegistration(registration.id!),
        _fcmRepository.deleteFirebaseRegistrationCache(),
      ], eagerError: true);
      yield Right<Failure, Success>(DestroyFirebaseRegistrationSuccess());
    } catch (e) {
      yield Left<Failure, Success>(DestroyFirebaseRegistrationFailure(e));
    }
  }
}