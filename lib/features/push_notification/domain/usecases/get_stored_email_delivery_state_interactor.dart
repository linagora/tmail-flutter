import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/type_name.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_stored_email_delivery_state.dart';

class GetStoredEmailDeliveryStateInteractor {
  final FCMRepository _fcmRepository;

  GetStoredEmailDeliveryStateInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(GetStoredEmailDeliveryStateLoading());
      final storedState = await _fcmRepository.getStateToRefresh(TypeName.emailDelivery);
      yield Right<Failure, Success>(GetStoredEmailDeliveryStateSuccess(storedState));
    } catch (e) {
      yield Left<Failure, Success>(GetStoredEmailDeliveryStateFailure(e));
    }
  }
}