import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/firebase_registration.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/store_firebase_registration_state.dart';

class StoreFirebaseRegistrationInteractor {
  final FCMRepository _fcmRepository;

  StoreFirebaseRegistrationInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(FirebaseRegistration firebaseRegistration) async* {
    try {
      yield Right<Failure, Success>(StoreFirebaseRegistrationLoading());
      await _fcmRepository.storeFirebaseRegistration(firebaseRegistration);
      yield Right<Failure, Success>(StoreFirebaseRegistrationSuccess());
    } catch (e) {
      yield Left<Failure, Success>(StoreFirebaseRegistrationFailure(e));
    }
  }
}