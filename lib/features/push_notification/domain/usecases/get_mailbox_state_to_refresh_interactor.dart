import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/type_name.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_mailbox_state_to_refresh_state.dart';

class GetMailboxStateToRefreshInteractor {
  final FCMRepository _fcmRepository;

  GetMailboxStateToRefreshInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(GetMailboxStateToRefreshLoading());
      final storedState = await _fcmRepository.getStateToRefresh(TypeName.mailboxType);
      yield Right<Failure, Success>(GetMailboxStateToRefreshSuccess(storedState));
    } catch (e) {
      yield Left<Failure, Success>(GetMailboxStateToRefreshFailure(e));
    }
  }
}