import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/destroy_firebase_registration_state.dart';

class RemoveFirebaseRegistrationInteractor {

  final FCMRepository _fcmRepository;

  RemoveFirebaseRegistrationInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, UserName userName) async* {
    try {
      yield Right<Failure, Success>(DestroyFirebaseRegistrationLoading());
      final registration = await _fcmRepository.getStoredFirebaseRegistration(accountId, userName);
      await Future.wait([
        _fcmRepository.destroyFirebaseRegistration(registration.id!),
        _fcmRepository.deleteFirebaseRegistrationCache(accountId, userName),
      ], eagerError: true);
      yield Right<Failure, Success>(DestroyFirebaseRegistrationSuccess());
    } catch (e) {
      yield Left<Failure, Success>(DestroyFirebaseRegistrationFailure(e));
    }
  }
}