import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/type_name.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/delete_mailbox_state_to_refresh_state.dart';

class DeleteMailboxStateToRefreshInteractor {
  final FCMRepository _fcmRepository;

  DeleteMailboxStateToRefreshInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(DeleteMailboxStateToRefreshLoading());
      await _fcmRepository.deleteStateToRefresh(TypeName.mailboxType);
      yield Right<Failure, Success>(DeleteMailboxStateToRefreshSuccess());
    } catch (e) {
      yield Left<Failure, Success>(DeleteMailboxStateToRefreshFailure(e));
    }
  }
}