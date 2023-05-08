import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/delete_email_state_to_refresh_state.dart';

class DeleteEmailStateToRefreshInteractor {
  final FCMRepository _fcmRepository;

  DeleteEmailStateToRefreshInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, UserName userName) async* {
    try {
      yield Right<Failure, Success>(DeleteEmailStateToRefreshLoading());
      await _fcmRepository.deleteStateToRefresh(accountId, userName, TypeName.emailType);
      yield Right<Failure, Success>(DeleteEmailStateToRefreshSuccess());
    } catch (e) {
      yield Left<Failure, Success>(DeleteEmailStateToRefreshFailure(e));
    }
  }
}