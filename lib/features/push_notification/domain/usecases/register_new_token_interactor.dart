
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/register_new_token_state.dart';

class RegisterNewTokenInteractor {

  final FCMRepository _fcmRepository;

  RegisterNewTokenInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(RegisterNewTokenRequest newTokenRequest) async* {
    try {
      yield Right<Failure, Success>(RegisterNewTokenLoading());
      final firebaseSubscription = await _fcmRepository.registerNewToken(newTokenRequest);
      yield Right<Failure, Success>(RegisterNewTokenSuccess(firebaseSubscription));
    } catch (e) {
      yield Left<Failure, Success>(RegisterNewTokenFailure(e));
    }
  }
}