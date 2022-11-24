import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/type_name.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_email_state_to_refresh_state.dart';

class GetEmailStateToRefreshInteractor {
  final FCMRepository _fcmRepository;

  GetEmailStateToRefreshInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(GetEmailStateToRefreshLoading());
      final storedState = await _fcmRepository.getStateToRefresh(TypeName.emailType);
      yield Right<Failure, Success>(GetEmailStateToRefreshSuccess(storedState));
    } catch (e) {
      yield Left<Failure, Success>(GetEmailStateToRefreshFailure(e));
    }
  }
}