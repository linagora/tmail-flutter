import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/store_email_delivery_state.dart';

class StoreEmailDeliveryStateInteractor {
  final FCMRepository _fcmRepository;

  StoreEmailDeliveryStateInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, UserName userName, jmap.State newState) async* {
    try {
      yield Right<Failure, Success>(StoreEmailDeliveryStateLoading());
      await _fcmRepository.storeStateToRefresh(accountId, userName, TypeName.emailDelivery, newState);
      yield Right<Failure, Success>(StoreEmailDeliveryStateSuccess());
    } catch (e) {
      yield Left<Failure, Success>(StoreEmailDeliveryStateFailure(e));
    }
  }
}