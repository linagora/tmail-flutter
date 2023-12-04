import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_stored_firebase_registration_state.dart';

class GetStoredFirebaseRegistrationInteractor {
  final FCMRepository _fcmRepository;

  GetStoredFirebaseRegistrationInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(GetStoredFirebaseRegistrationLoading());
      final registration = await _fcmRepository.getStoredFirebaseRegistration();
      yield Right<Failure, Success>(GetStoredFirebaseRegistrationSuccess(registration));
    } catch (e) {
      yield Left<Failure, Success>(GetStoredFirebaseRegistrationFailure(e));
    }
  }
}