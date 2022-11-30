import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/store_mailbox_state_to_refresh_state.dart';

class StoreMailboxStateToRefreshInteractor {
  final FCMRepository _fcmRepository;

  StoreMailboxStateToRefreshInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(jmap.State newState) async* {
    try {
      yield Right<Failure, Success>(StoreMailboxStateToRefreshLoading());
      await _fcmRepository.storeStateToRefresh(TypeName.mailboxType, newState);
      yield Right<Failure, Success>(StoreMailboxStateToRefreshSuccess());
    } catch (e) {
      yield Left<Failure, Success>(StoreMailboxStateToRefreshFailure(e));
    }
  }
}