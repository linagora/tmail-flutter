import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/store_email_state_to_refresh_state.dart';

class StoreEmailStateToRefreshInteractor {
  final FCMRepository _fcmRepository;

  StoreEmailStateToRefreshInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(jmap.State newState) async* {
    try {
      yield Right<Failure, Success>(StoreEmailStateToRefreshLoading());
      await _fcmRepository.storeStateToRefresh(TypeName.emailType, newState);
      yield Right<Failure, Success>(StoreEmailStateToRefreshSuccess());
    } catch (e) {
      yield Left<Failure, Success>(StoreEmailStateToRefreshFailure(e));
    }
  }
}