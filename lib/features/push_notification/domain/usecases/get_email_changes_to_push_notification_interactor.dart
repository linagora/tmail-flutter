import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_email_changes_state.dart';

class GetEmailChangesToPushNotificationInteractor {
  final FCMRepository _fcmRepository;

  GetEmailChangesToPushNotificationInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    jmap.State currentState,
    {
      Properties? propertiesCreated,
      Properties? propertiesUpdated
    }
  ) async* {
    try {
      yield Right<Failure, Success>(GetEmailChangesToPushNotificationLoading());

      final emailsResponse = await _fcmRepository.getEmailChangesToPushNotification(
        accountId,
        currentState,
        propertiesCreated: propertiesCreated,
        propertiesUpdated: propertiesUpdated);

      final presentationEmailList = emailsResponse.emailList
        ?.map((email) => email.toPresentationEmail())
        .toList() ?? List.empty();

      yield Right<Failure, Success>(GetEmailChangesToPushNotificationSuccess(presentationEmailList));
    } catch (e) {
      yield Left<Failure, Success>(GetEmailChangesToPushNotificationFailure(e));
    }
  }
}