import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/delete_firebase_registration_cache_state.dart';

class DeleteFirebaseRegistrationCacheInteractor {
  final AccountRepository _accountRepository;
  final FCMRepository _fcmRepository;

  DeleteFirebaseRegistrationCacheInteractor(this._accountRepository, this._fcmRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(DeleteFirebaseRegistrationCacheLoading());
      final currentAccount = await _accountRepository.getCurrentAccount();
      await _fcmRepository.deleteFirebaseRegistrationCache(currentAccount.accountId!, currentAccount.userName!);
      yield Right<Failure, Success>(DeleteFirebaseRegistrationCacheSuccess());
    } catch (e) {
      yield Left<Failure, Success>(DeleteFirebaseRegistrationCacheFailure(e));
    }
  }
}