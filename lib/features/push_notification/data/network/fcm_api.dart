
import 'package:fcm/converter/firebase_registration_expired_time_nullable_converter.dart';
import 'package:fcm/method/set/firebase_registration_set_method.dart';
import 'package:fcm/method/set/firebase_registration_set_response.dart';
import 'package:fcm/method/get/firebase_registration_get_method.dart';
import 'package:fcm/method/get/firebase_registration_get_response.dart';
import 'package:fcm/model/device_client_id.dart';
import 'package:fcm/model/firebase_registration.dart';
import 'package:fcm/model/firebase_registration_id.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/update_token_expired_time_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/utils/fcm_constants.dart';

class FcmApi {

  final HttpClient _httpClient;

  FcmApi(this._httpClient);

  Future<FirebaseRegistration> getFirebaseRegistrationByDeviceId(DeviceClientId deviceId) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

    final firebaseRegistrationGetMethod = FirebaseRegistrationGetMethod();
    final firebaseRegistrationGetInvocation = requestBuilder.invocation(firebaseRegistrationGetMethod);
    final response = await (requestBuilder
        ..usings(firebaseRegistrationGetMethod.requiredCapabilities))
      .build()
      .execute();

    final getResponse = response.parse<FirebaseRegistrationGetResponse>(
      firebaseRegistrationGetInvocation.methodCallId,
      FirebaseRegistrationGetResponse.deserialize);

    final matchedFirebaseRegistration = getResponse?.list
      .where((fcmSub) => fcmSub.deviceClientId == deviceId)
      .toList();

    if (matchedFirebaseRegistration?.isNotEmpty == true) {
      return matchedFirebaseRegistration!.first;
    } else {
      throw NotFoundFirebaseRegistrationForDeviceException();
    }
  }

  Future<FirebaseRegistration> registerNewFirebaseRegistrationToken(RegisterNewTokenRequest newTokenRequest) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

    final firebaseRegistrationSetMethod = FirebaseRegistrationSetMethod()
      ..addCreate(
        newTokenRequest.createRequestId,
        newTokenRequest.firebaseRegistration
      );
    final firebaseRegistrationSetInvocation = requestBuilder.invocation(firebaseRegistrationSetMethod);
    final response = await (requestBuilder
        ..usings(firebaseRegistrationSetMethod.requiredCapabilities))
      .build()
      .execute();

    final firebaseRegistrationSetResponse = response.parse<FirebaseRegistrationSetResponse>(
      firebaseRegistrationSetInvocation.methodCallId,
      FirebaseRegistrationSetResponse.deserialize);

    final firebaseRegistration = firebaseRegistrationSetResponse?.created?[newTokenRequest.createRequestId];
    if (firebaseRegistration != null) {
      return firebaseRegistration;
    } else {
      throw NotFoundFirebaseRegistrationCreatedException();
    }
  }

  Future<void> destroyFirebaseRegistration(FirebaseRegistrationId registrationId) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

    final firebaseRegistrationSetMethod = FirebaseRegistrationSetMethod()..addDestroy({registrationId.id});
    final firebaseRegistrationSetInvocation = requestBuilder.invocation(firebaseRegistrationSetMethod);
    final response = await (requestBuilder
        ..usings(firebaseRegistrationSetMethod.requiredCapabilities))
      .build()
      .execute();

    final firebaseRegistrationSetResponse = response.parse<FirebaseRegistrationSetResponse>(
      firebaseRegistrationSetInvocation.methodCallId,
      FirebaseRegistrationSetResponse.deserialize);

    if (firebaseRegistrationSetResponse?.destroyed?.contains(registrationId.id) == true) {
      return;
    } else {
      throw NotFoundFirebaseRegistrationDestroyedException();
    }
  }

  Future<void> updateFirebaseRegistrationToken(UpdateTokenExpiredTimeRequest expiredTimeRequest) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

    final firebaseRegistrationSetMethod = FirebaseRegistrationSetMethod()
      ..addUpdates({
        expiredTimeRequest.firebaseRegistrationId.id: PatchObject({
          FcmConstants.firebaseRegistrationExpiredTimeProperty: const FirebaseRegistrationExpiredTimeNullableConverter().toJson(expiredTimeRequest.firebaseRegistrationExpiredTime)
        })
      });
    final firebaseRegistrationSetInvocation = requestBuilder.invocation(firebaseRegistrationSetMethod);
    final response = await (requestBuilder
        ..usings(firebaseRegistrationSetMethod.requiredCapabilities))
      .build()
      .execute();

    final firebaseRegistrationSetResponse = response.parse<FirebaseRegistrationSetResponse>(
      firebaseRegistrationSetInvocation.methodCallId,
      FirebaseRegistrationSetResponse.deserialize);

    if (firebaseRegistrationSetResponse?.updated?.containsKey(expiredTimeRequest.firebaseRegistrationId.id) == true) {
      return;
    } else {
      throw NotFoundFirebaseRegistrationUpdatedException();
    }
  }
}