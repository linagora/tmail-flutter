import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/destroy_firebase_registration_state.dart';

class RemoveFirebaseRegistrationInteractor {

  final FCMRepository _fcmRepository;

  RemoveFirebaseRegistrationInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(PersonalAccount currentAccount) async* {
    try {
      yield Right<Failure, Success>(DestroyFirebaseRegistrationLoading());
      final registration = await _fcmRepository.getStoredFirebaseRegistration(
        currentAccount.accountId!,
        currentAccount.userName!);

      await Future.wait([
        _fcmRepository.destroyFirebaseRegistration(registration.id!),
        _fcmRepository.deleteFirebaseRegistrationCache(
          currentAccount.accountId!,
          currentAccount.userName!),
      ], eagerError: true);

      yield Right<Failure, Success>(DestroyFirebaseRegistrationSuccess(currentAccount));
    } catch (e) {
      yield Left<Failure, Success>(DestroyFirebaseRegistrationFailure(
        exception: e,
        currentAccount: currentAccount));
    }
  }
}